class AnalysisResponse {
  final int atsScore;
  final List<String> identifiedGaps;
  final List<String> improvements;
  final List<InterviewQuestion> mockInterview;

  AnalysisResponse({
    required this.atsScore,
    required this.identifiedGaps,
    required this.improvements,
    required this.mockInterview,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      atsScore: json['atsScore'] ?? 0,
      identifiedGaps: List<String>.from(json['identifiedGaps'] ?? []),
      improvements: List<String>.from(json['improvements'] ?? []),
      mockInterview: (json['mockInterview'] as List? ?? [])
          .map((item) => InterviewQuestion.fromJson(item))
          .toList(),
    );
  }
}

class InterviewQuestion {
  final String question;
  final String objectiveReasoning;

  InterviewQuestion({required this.question, required this.objectiveReasoning});

  factory InterviewQuestion.fromJson(Map<String, dynamic> json) {
    return InterviewQuestion(
      question: json['question'] ?? '',
      objectiveReasoning: json['objectiveReasoning'] ?? '',
    );
  }
}