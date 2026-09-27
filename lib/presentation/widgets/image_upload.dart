import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import '../../core/config.dart';
import 'image_compress.dart';

class CustomImageUpload extends StatefulWidget {
  final List<String> imageUrls;
  final Function(List<String>) onImagesChanged;
  final String? uploadEndpoint;
  final String label;

  const CustomImageUpload({
    super.key,
    required this.imageUrls,
    required this.onImagesChanged,
    this.uploadEndpoint,
    this.label = 'Photos',
  });

  @override
  State<CustomImageUpload> createState() => _CustomImageUploadState();
}

class _CustomImageUploadState extends State<CustomImageUpload> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontFamily: 'Inter', 
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Column(
            children: [
              // Display existing images
              if (widget.imageUrls.isNotEmpty)
                Text(
                  'Glissez une photo pour changer l\'ordre. La première photo est celle affichée en premier.',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              if (widget.imageUrls.isNotEmpty) const SizedBox(height: 8),
              if (widget.imageUrls.isNotEmpty)
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.imageUrls.length,
                    itemBuilder: (context, index) {
                      return DragTarget<int>(
                        onWillAcceptWithDetails: (details) => details.data != index,
                        onAcceptWithDetails: (details) {
                          final fromIndex = details.data;
                          final newList = List<String>.from(widget.imageUrls);
                          final moved = newList.removeAt(fromIndex);
                          newList.insert(index, moved);
                          widget.onImagesChanged(newList);
                        },
                        builder: (context, candidateData, rejectedData) {
                          final isTargeted = candidateData.isNotEmpty;
                          return AnimatedScale(
                            scale: isTargeted ? 1.05 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Draggable<int>(
                              data: index,
                              feedback: Material(
                                color: Colors.transparent,
                                child: _buildImageTile(index),
                              ),
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: _buildImageTile(index),
                              ),
                              child: _buildImageTile(index),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              if (widget.imageUrls.isNotEmpty) const SizedBox(height: 12),

              // Button for adding images
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadImages,
                icon: _isUploading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.add_photo_alternate),
                label: Text(_isUploading ? 'Upload en cours...' : 'Ajouter des photos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),

              const SizedBox(height: 8),
              Text(
                'Formats supportés: JPG, PNG, WEBP',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageTile(int index) {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(widget.imageUrls[index]),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (index == 0)
          Positioned(
            bottom: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Principale',
                style: TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
          ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              final newList = List<String>.from(widget.imageUrls);
              newList.removeAt(index);
              widget.onImagesChanged(newList);
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadImages() async {
    try {
      // Simple file picker without any restrictions first to test
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any, // Use any type first to test
      );

      if (result != null && result.files.isNotEmpty) {
        // Filter only image files
        final imageFiles = result.files.where((file) {
          final extension = file.name.split('.').last.toLowerCase();
          return ['jpg', 'jpeg', 'png', 'webp', 'gif'].contains(extension);
        }).toList();

        if (imageFiles.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez sélectionner des images (JPG, PNG, WEBP)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() {
          _isUploading = true;
        });

        List<String> uploadedUrls = [];

        // Upload each file
        for (var file in imageFiles) {
          String? uploadedUrl;

          // Check if we're on web or desktop
          // For web, file.path is not available, use bytes
          // For desktop, we can use path
          if (file.bytes != null) {
            // Web platform or bytes available
            uploadedUrl = await _uploadBytesToServer(file.bytes!, file.name);
          } else if (file.path != null) {
            // Desktop platform
            uploadedUrl = await _uploadToServer(File(file.path!));
          }

          if (uploadedUrl != null) {
            uploadedUrls.add(uploadedUrl);
          }
        }

        if (uploadedUrls.isNotEmpty && mounted) {
          widget.onImagesChanged([...widget.imageUrls, ...uploadedUrls]);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${uploadedUrls.length} image(s) uploadée(s) avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Aucune image n\'a pu être uploadée'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<String?> _uploadToServer(File imageFile) async {
    String uploadUrl =
        widget.uploadEndpoint ?? ApiConfig.uploadImage;
    try {
      final compressed = await compressImageBytes(await imageFile.readAsBytes());

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(
        http.MultipartFile.fromBytes('image', compressed, filename: 'photo.jpg'),
      );

      // Ajouter un timeout
      var response = await request.send().timeout(const Duration(seconds: 30));
      var responseData = await response.stream.bytesToString();


      if (response.statusCode == 200) {
        try {
          var jsonResponse = json.decode(responseData);
          if (jsonResponse['success'] == true) {
            print('✅ Upload success: ${jsonResponse['url']}');
            return jsonResponse['url'];
          } else {
            print('❌ Upload error: ${jsonResponse['message']}');
            // Afficher l'erreur à l'utilisateur
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Upload failed: ${jsonResponse['message']}'), backgroundColor: Colors.red),
              );
            }
            return null;
          }
        } catch (e) {
          print('❌ JSON parse error: $e');
          print('Raw response: $responseData');
          return null;
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Upload exception: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload error: $e'), backgroundColor: Colors.red),
        );
      }
      return null;
    }
  }

  // For web platform support
  Future<String?> _uploadBytesToServer(List<int> bytes, String fileName) async {
    String uploadUrl = widget.uploadEndpoint ?? ApiConfig.uploadImage;
    try {
      final compressed = await compressImageBytes(Uint8List.fromList(bytes));
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          compressed,
          filename: 'photo.jpg',
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      print('Upload response: $responseData');

      if (jsonResponse['success'] == true) {
        return jsonResponse['url'];
      } else {
        print('Upload error: ${jsonResponse['message']}');
        return null;
      }
    } catch (e) {
      print('Upload exception: $e');
      return null;
    }
  }
}