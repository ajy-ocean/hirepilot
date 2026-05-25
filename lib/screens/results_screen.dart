import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import 'interview_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analysis = context.read<AIProvider>().analysisResult;

    if (analysis == null) {
      return const Scaffold(body: Center(child: Text("Missing Data Object Artifacts Found.")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ATS Optimization Diagnostics')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Donut/Radial score visualization simulation framework block
            Center(
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 8),
                ),
                alignment: Alignment.center,
                child: Text(
                  "${analysis.atsScore}%",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text("Simulated Market Match Index Score", style: TextStyle(color: Colors.grey))),
            const SizedBox(height: 24),

            // Identified Market Competency Gaps List Frame block
            _buildSectionHeader(context, "Identified Gaps Matrix"),
            ...analysis.identifiedGaps.map((gap) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(leading: const Icon(Icons.warning_amber, color: Colors.orange), title: Text(gap)),
                )),
            const SizedBox(height: 20),

            // Concrete Action Step Execution List Frame block
            _buildSectionHeader(context, "Strategic Action Advancements"),
            ...analysis.improvements.map((tip) => Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(leading: const Icon(Icons.check_circle_outline, color: Colors.green), title: Text(tip)),
                )),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const InterviewScreen()));
              },
              icon: const Icon(Icons.forum),
              label: const Text("Launch AI Interview Training Core"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
      ),
    );
  }
}