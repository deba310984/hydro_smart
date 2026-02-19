import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'subsidy_controller.dart';

class SubsidyScreen extends ConsumerWidget {
  const SubsidyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subsidyAsync = ref.watch(subsidyStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Government Subsidies"),
        centerTitle: true,
      ),
      body: subsidyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Error: $e")),
        data: (subsidies) {
          if (subsidies.isEmpty) {
            return const Center(child: Text("No Subsidies Available"));
          }

          return ListView.builder(
            itemCount: subsidies.length,
            itemBuilder: (context, index) {
              final scheme = subsidies[index];

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        scheme.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(scheme.description),
                      const SizedBox(height: 8),
                      Text(
                        "Subsidy: ${scheme.subsidyPercentage}%",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                      const SizedBox(height: 8),
                      Text("Eligibility: ${scheme.eligibility}"),
                      if (scheme.documentsRequired.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text(
                          "Documents Required:",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        ...scheme.documentsRequired
                            .map((doc) => Text("• $doc",
                                style: const TextStyle(fontSize: 12)))
                            .toList(),
                      ],
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Application for '${scheme.title}' submitted!",
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text("Apply"),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
