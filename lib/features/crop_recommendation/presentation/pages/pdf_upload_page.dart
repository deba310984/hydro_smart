import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';

class PdfUploadPage extends StatefulWidget {
  const PdfUploadPage({super.key});

  @override
  State<PdfUploadPage> createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  bool isLoading = false;
  String? selectedFileName;
  List<dynamic> extractedCrops = [];
  String? errorMessage;

  Future<void> _pickAndUploadPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;

        setState(() {
          selectedFileName = file.name;
          isLoading = true;
          errorMessage = null;
          extractedCrops = [];
        });

        // Create multipart form data
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path!),
        });

        final dio = Dio();
        final response = await dio.post(
          ApiConfig.uploadCropPdf,
          data: formData,
        );

        if (response.statusCode == 200) {
          final data = response.data as Map;
          setState(() {
            extractedCrops = data['data']['crops'] ?? [];
            isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Extracted ${extractedCrops.length} crops'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: ${e.toString()}';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Crop Data PDF'),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Upload Crop PDF',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a PDF containing crop information\n(Temperature, pH, Days, Yield)',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (selectedFileName != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.blue),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Selected: $selectedFileName',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _pickAndUploadPdf,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          isLoading ? 'Processing...' : 'Pick & Upload PDF',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (extractedCrops.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Extracted Crops (${extractedCrops.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: extractedCrops.length,
                itemBuilder: (context, index) {
                  final crop = extractedCrops[index] as Map;
                  final emoji = crop['emoji'] ?? '🌱';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      crop['crop_name'] ?? 'Unknown',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Difficulty: ${crop['difficulty_level'] ?? 'N/A'}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                _InfoRow(
                                  '📅 Days to Harvest',
                                  '${crop['days_to_harvest']} days',
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  '💰 Profit Margin',
                                  '${crop['profit_margin']}%',
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  '📊 Yield',
                                  '${crop['yield_per_sqm']} kg/m²',
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  '🌡️ Temperature',
                                  '${crop['temperature_range']['min']}-${crop['temperature_range']['max']}°C',
                                ),
                                const SizedBox(height: 8),
                                _InfoRow(
                                  '🧪 pH Range',
                                  '${crop['ph_range']['min']}-${crop['ph_range']['max']}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Confidence: ${((crop['confidence_score'] ?? 0) * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13)),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ],
    );
  }
}
