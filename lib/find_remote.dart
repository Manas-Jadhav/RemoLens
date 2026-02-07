import 'dart:io';
import 'package:flutter/material.dart';
import 'package:remote_finder_app/main.dart'; // For 'supabase'
import 'package:remote_finder_app/tflite_service.dart';
import 'package:remote_finder_app/segmentation_service.dart';
import 'package:remote_finder_app/widgets/image_picker_widget.dart';
import 'package:remote_finder_app/remote_details.dart';

class FindRemotePage extends StatefulWidget {
  const FindRemotePage({super.key});

  @override
  State<FindRemotePage> createState() => _FindRemotePageState();
}

class _FindRemotePageState extends State<FindRemotePage> {
  File? _selectedImage;
  bool _isSearching = false;
  List<Map<String, dynamic>> _searchResults = []; // To store the found remotes

  final TfliteService _tfliteService = TfliteService();
  final SegmentationService _segmentationService = SegmentationService();

  void _searchForRemote(File image) async {
    setState(() {
      _isSearching = true;
      _searchResults = []; // Clear previous results
    });

    try {
      // 1. Auto-Crop (Optional, but recommended for accuracy)
      File? croppedImage = await _segmentationService.autoCropImage(image);
      File imageToProcess = croppedImage ?? image;

      // 2. Generate Vector
      List<double> vector = await _tfliteService.generateEmbedding(imageToProcess);

      // 3. Call Supabase Search Function
      final List<dynamic> response = await supabase.rpc(
        'match_remotes', // The name of your SQL function
        params: {
          'query_embedding': vector,
          'match_threshold': 0.80, // 60% similarity or higher
          'match_count': 5,        // Top 5 results
        },
      );


      setState(() {
        _searchResults = List<Map<String, dynamic>>.from(response);
      });

    } catch (e) {
      print('Error searching: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Remote'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // const SizedBox(height: 20),

            // 1. Reusable Image Picker
            ImagePickerWidget(
              shouldAutoOpen: true,
              onImageSelected: (image) {
                setState(() {
                  _selectedImage = image;
                });
                // Automatically start searching as soon as image is picked
                _searchForRemote(image);
              },
            ),

            const SizedBox(height: 30),

            // 2. Loading Indicator
            if (_isSearching)
              const CircularProgressIndicator()

            // 3. Results List
            else if (_searchResults.isNotEmpty)
              ListView.builder(
                shrinkWrap: true, // Important for nested lists
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final remote = _searchResults[index];
                  final similarity = (remote['similarity'] * 100).toStringAsFixed(1);

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>Remote_Details_Page(remoteData: remote)));
                      },
                      leading: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.network(
                            remote['image_url'],
                            fit: BoxFit.cover
                        ),
                      ),
                      title: Text(remote['brand'] ?? 'Unknown Brand'),
                      subtitle: Text('${remote['category']} • $similarity% Match'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
                  );
                },
              )
            else if (_selectedImage != null)
                const Text("No matching remotes found.", style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      )
    );
  }
}