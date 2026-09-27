import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

import '../../core/config.dart';

class CustomVideoUpload extends StatefulWidget {
  final String? videoUrl;
  final ValueChanged<String?> onVideoChanged;
  final String? uploadEndpoint;

  const CustomVideoUpload({
    super.key,
    required this.videoUrl,
    required this.onVideoChanged,
    this.uploadEndpoint,
  });

  @override
  State<CustomVideoUpload> createState() => _CustomVideoUploadState();
}

class _CustomVideoUploadState extends State<CustomVideoUpload> {
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vidéo du témoignage (optionnel)',
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
              if (widget.videoUrl != null && widget.videoUrl!.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.videoUrl!.split('/').last,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => widget.onVideoChanged(null),
                        child: const Icon(Icons.close, color: Colors.white70, size: 18),
                      ),
                    ],
                  ),
                ),
              ElevatedButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadVideo,
                icon: _isUploading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.video_call_outlined),
                label: Text(_isUploading
                    ? 'Upload en cours...'
                    : (widget.videoUrl != null ? 'Remplacer la vidéo' : 'Ajouter une vidéo')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade200,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 45),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Formats supportés: MP4, MOV, WEBM',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickAndUploadVideo() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final extension = file.name.split('.').last.toLowerCase();

        if (!['mp4', 'mov', 'webm'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Veuillez sélectionner une vidéo (MP4, MOV, WEBM)'),
                backgroundColor: Colors.orange,
              ),
            );
          }
          return;
        }

        setState(() => _isUploading = true);

        String? uploadedUrl;
        if (file.bytes != null) {
          uploadedUrl = await _uploadBytesToServer(file.bytes!, file.name);
        } else if (file.path != null) {
          uploadedUrl = await _uploadToServer(File(file.path!));
        }

        if (uploadedUrl != null && mounted) {
          widget.onVideoChanged(uploadedUrl);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vidéo uploadée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('La vidéo n\'a pas pu être uploadée'),
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
        setState(() => _isUploading = false);
      }
    }
  }


  Future<String?> _uploadToServer(File videoFile) async {
    // Utiliser le bon endpoint pour les vidéos
    String uploadUrl = widget.uploadEndpoint ?? ApiConfig.uploadVideo;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(
        await http.MultipartFile.fromPath(
          'video', // <-- CHANGÉ: 'video' au lieu de 'image'
          videoFile.path,
        ),
      );

      var response = await request.send().timeout(const Duration(seconds: 60));
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(responseData);
        if (jsonResponse['success'] == true) {
          return jsonResponse['url'];
        }
      }
      return null;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }

  Future<String?> _uploadBytesToServer(List<int> bytes, String fileName) async {
    // Utiliser le bon endpoint pour les vidéos
    String uploadUrl = widget.uploadEndpoint ?? ApiConfig.uploadVideo;

    try {
      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.files.add(
        http.MultipartFile.fromBytes(
          'video', // <-- CHANGÉ: 'video' au lieu de 'image'
          bytes,
          filename: fileName,
        ),
      );

      var response = await request.send().timeout(const Duration(seconds: 60));
      var responseData = await response.stream.bytesToString();
      var jsonResponse = json.decode(responseData);

      if (jsonResponse['success'] == true) {
        return jsonResponse['url'];
      }
      return null;
    } catch (e) {
      print('❌ Upload error: $e');
      return null;
    }
  }


}
