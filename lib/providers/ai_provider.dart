import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/analysis_response.dart';

class AIProvider extends ChangeNotifier {
  // Target Key Injection
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  String _fileName = "";
  String _extractedText = "";
  bool _isLoading = false;
  AnalysisResponse? _analysisResult;
  String? _error;

  String get fileName => _fileName;
  bool get isLoading => _isLoading;
  AnalysisResponse? get analysisResult => _analysisResult;
  String? get error => _error;
  bool get hasData => _extractedText.isNotEmpty;

  /// Handles local file picking and transparent text conversion extraction
  Future<void> pickDocument() async {
    _error = null;
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        _isLoading = true;
        notifyListeners();

        PlatformFile file = result.files.single;
        _fileName = file.name;
        Uint8List fileBytes = file.bytes!;

        if (file.extension == 'pdf') {
          final PdfDocument document = PdfDocument(inputBytes: fileBytes);
          _extractedText = PdfTextExtractor(document).extractText();
          document.dispose();
        } else {
          _extractedText = utf8.decode(fileBytes);
        }

        if (_extractedText.trim().isEmpty) {
          throw Exception(
            "Could not extract legible text content from document.",
          );
        }
      }
    } catch (e) {
      _error = "File Extraction Failure: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Dispatches strict System Context & extracted texts directly to Gemini
  Future<bool> analyzeResumeWithJD(String jobDescription) async {
    if (_extractedText.isEmpty) {
      _error = "Please upload a valid resume payload first.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _apiKey,
        generationConfig: GenerationConfig(temperature: 0.2),
      );

      final systemContextPrompt =
          """
      You are an expert technical recruiter and Applicant Tracking System (ATS) evaluator. 
      Analyze the following Resume Text against the provided Job Description (JD).
      
      You MUST respond ONLY with a valid JSON object matching this exact schema layout without any introductory conversational pleasantries:
      {
        "atsScore": 85,
        "identifiedGaps": ["Missing skill A", "Lacks experience in B"],
        "improvements": ["Actionable step 1", "Rewrite experience item X"],
        "mockInterview": [
          {
            "question": "Specific interview question targeting matching elements or gaps",
            "objectiveReasoning": "Why this specific question matters based on the provided JD and Resume."
          }
        ]
      }
      
      Resume Data:
      $_extractedText
      
      Target Job Description:
      $jobDescription
      """;

      final response = await model.generateContent([
        Content.text(systemContextPrompt),
      ]);
      String? cleanText = response.text;

      if (cleanText == null)
        throw Exception("Empty sequence response from AI.");

      // CLEANING MECHANISM: Strips markdown code blocks formatting strings safely
      cleanText = cleanText.trim();
      if (cleanText.startsWith('```')) {
        // Look for the first opening brackets and final closing brackets
        final int firstBracket = cleanText.indexOf('{');
        final int lastBracket = cleanText.lastIndexOf('}');
        if (firstBracket != -1 && lastBracket != -1) {
          cleanText = cleanText.substring(firstBracket, lastBracket + 1);
        }
      }

      final Map<String, dynamic> parsedJson = json.decode(cleanText);
      _analysisResult = AnalysisResponse.fromJson(parsedJson);
      return true;
    } catch (e) {
      _error = "API Processing Error: ${e.toString()}";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _fileName = "";
    _extractedText = "";
    _analysisResult = null;
    _error = null;
    notifyListeners();
  }
}
