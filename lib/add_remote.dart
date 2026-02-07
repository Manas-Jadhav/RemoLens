import 'package:flutter/material.dart';
import 'dart:io';
import 'package:remote_finder_app/widgets/image_picker_widget.dart';
import 'package:remote_finder_app/main.dart';
import 'package:remote_finder_app/tflite_service.dart';
import 'package:remote_finder_app/segmentation_service.dart';

class Add_Remote_Page extends StatefulWidget {
  const Add_Remote_Page({super.key});

  @override
  State<Add_Remote_Page> createState() => _Add_Remote_PageState();
}

class _Add_Remote_PageState extends State<Add_Remote_Page> {
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _rackController = TextEditingController();

  bool _isLoading = false; // <--- NEW: Loading state variable

  final List<String> type_of_remote = [
    'Old TV(Box)',
    'Smart TV',
    'Android TV',
    'Home Theater',
    'China TV'
  ];

  String _selectedType = "Smart TV";
  File? _selectedImage;

  final TfliteService _tfliteService = TfliteService();
  final SegmentationService _segmentationService = SegmentationService();

  @override
  void dispose() {
    _brandController.dispose();
    _priceController.dispose();
    _rackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Remote'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ImagePickerWidget(
                shouldAutoOpen: true,
                onImageSelected: (File imageFromChild) {
                  setState(() {
                    _selectedImage = imageFromChild;
                  });
                },
              ),
              const SizedBox(height: 30),
              if (_selectedImage != null)
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: width * 0.07, vertical: height * 0.02),
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                    border: (Border.all(color: Colors.grey)),
                  ),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _brandController,
                        decoration: const InputDecoration(
                          labelText: "Brand Name",
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(fontSize: 22, color: Colors.blueGrey[900]),
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        controller: _rackController,
                        decoration: const InputDecoration(
                          labelText: "Rack Number",
                          border: OutlineInputBorder(),
                        ),
                        style: TextStyle(fontSize: 22, color: Colors.blueGrey[900]),
                      ),
                      SizedBox(height: height * 0.03),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          prefixText: '₹ ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.currency_rupee),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: height * 0.03),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey, width: 3),
                        ),
                        child: DropdownButton<String>(
                          padding: EdgeInsets.symmetric(
                              horizontal: width * 0.05, vertical: height * 0.005),
                          value: _selectedType,
                          style: (TextStyle(fontSize: 22, color: Colors.blueGrey[900])),
                          items: type_of_remote.map((String type) {
                            return DropdownMenuItem<String>(value: type, child: Text(type));
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue!;
                            });
                          },
                        ),
                      ),
                      SizedBox(height: height * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                                side: const BorderSide(color: Colors.red, width: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15)),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blueGrey[900],
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(width: width * 0.05),
                          TextButton(
                            onPressed: _isLoading ? null : () async { // <--- Disable button when loading
                              if (_selectedImage == null) return;

                              setState(() => _isLoading = true); // <--- START LOADING

                              try {
                                // 1. AI Processing
                                _selectedImage = await _segmentationService.autoCropImage(_selectedImage!);
                                List<double> featureVector = await _tfliteService.generateEmbedding(_selectedImage!);

                                String brandName = _brandController.text;
                                String rackNumber = _rackController.text;
                                int price = int.tryParse(_priceController.text) ?? 0;

                                // 2. Storage Upload
                                final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                                await supabase.storage.from('remote-images').upload(fileName, _selectedImage!);

                                // 3. Database Save
                                final imageUrl = supabase.storage.from('remote-images').getPublicUrl(fileName);

                                Map<String, dynamic> remoteData = {
                                  'brand': brandName,
                                  'category': _selectedType,
                                  'image_url': imageUrl,
                                  'embedding': featureVector,
                                  'price': price,
                                  'rack_no': rackNumber
                                };

                                await supabase.from('remotes').insert(remoteData);

                                // 4. Success UI
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Remote saved successfully!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pop(context);
                                }
                              } catch (e) {
                                // 5. Error UI
                                print("Error saving: $e");
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error: $e"),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                // 6. STOP LOADING (Even if it fails)
                                if (mounted) setState(() => _isLoading = false);
                              }
                            },
                            style: TextButton.styleFrom(
                              side: BorderSide(
                                  color: _isLoading ? Colors.grey : Colors.green,
                                  width: 2
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green)
                            )
                                : Text(
                              "Save Remote",
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.blueGrey[900],
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}