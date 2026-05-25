import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';

class InterviewScreen extends StatelessWidget {
  const InterviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analysis = context.read<AIProvider>().analysisResult;

    if (analysis == null) {
      return const Scaffold(body: Center(child: Text("Missing Data Object Artifacts Found.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mock Technical Preparation')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: analysis.mockInterview.length,
        itemBuilder: (context, index) {
          final item = analysis.mockInterview[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ExpansionTile(
              leading: CircleAvatar(child: Text("${index + 1}")),
              title: Text(
                item.question,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Evaluation Rationale:",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.objectiveReasoning,
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}