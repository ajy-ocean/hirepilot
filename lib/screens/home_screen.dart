import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../providers/theme_provider.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _jdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Force UI frame refreshes on local state mutation typing updates
    _jdController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(
      () {},
    ); // Explicitly forces the frame to re-evaluate the button's enabled condition
  }

  @override
  void dispose() {
    _jdController.removeListener(_onTextChanged); // Clean cleanup step
    _jdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiProvider = context.watch<AIProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'HirePilot',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
          ),
          if (aiProvider.hasData)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _jdController.clear();
                aiProvider.reset();
              },
            ),
        ],
      ),
      body: aiProvider.isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Crunching alignment vectors... Please wait."),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // File Uploader Area Card
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.description,
                            size: 48,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            aiProvider.hasData
                                ? aiProvider.fileName
                                : "No Resume Uploaded",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () => aiProvider.pickDocument(),
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              aiProvider.hasData
                                  ? "Change Document"
                                  : "Upload Resume (PDF/TXT)",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Job Description Input Frame
                  const Text(
                    "Target Job Description",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _jdController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText:
                          "Paste target job description parameters here to match compatibility scores...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Action Confirmation Trigger Button
                  if (aiProvider.error != null) ...[
                    Text(
                      aiProvider.error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        (!aiProvider.hasData ||
                            _jdController.text.trim().isEmpty)
                        ? null
                        : () async {
                            final success = await aiProvider
                                .analyzeResumeWithJD(_jdController.text);
                            if (success && mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ResultsScreen(),
                                ),
                              );
                            }
                          },
                    child: const Text(
                      "Execute Alignment Analysis",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
