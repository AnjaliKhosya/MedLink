import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class AddDocumentPage extends StatefulWidget {
  @override
  _AddDocumentPageState createState() => _AddDocumentPageState();
}

class _AddDocumentPageState extends State<AddDocumentPage> {
  List<PlatformFile>? _selectedFiles;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickMedia() async {
    // Show a dialog to choose between file picker or camera
    final choice = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Media"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text("Select Files"),
                onTap: () {
                  Navigator.of(context).pop(0); // Choose file picker
                },
              ),
              ListTile(
                title: Text("Take Photo"),
                onTap: () {
                  Navigator.of(context).pop(1); // Choose camera
                },
              ),
            ],
          ),
        );
      },
    );

    if (choice != null) {
      if (choice == 0) {
        // File picker option
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.custom,
          allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
        );

        if (result != null) {
          setState(() {
            _selectedFiles = result.files;
          });
        }
      } else if (choice == 1) {
        // Camera option
        final XFile? photo = await _imagePicker.pickImage(source: ImageSource.camera);
        if (photo != null) {
          setState(() {
            final int filesize = File(photo.path).lengthSync();
            _selectedFiles = [
              PlatformFile(
                size: filesize,
                name: photo.name,
                path: photo.path,
                bytes: File(photo.path).readAsBytesSync(),
              ),
            ];
          });
        }
      }
    }
  }

  Future<void> _submit() async {
    final groupName = _groupController.text.trim();

    if (_selectedFiles != null && groupName.isNotEmpty) {
      final storageRef = FirebaseStorage.instance.ref().child("meddocuments/$groupName");

      for (PlatformFile file in _selectedFiles!) {
        final fileBytes = file.bytes;
        final fileName = file.name;

        try {
          final fileRef = storageRef.child(fileName);

          if (fileBytes != null) {
            await fileRef.putData(fileBytes);
          } else if (file.path != null) {
            await fileRef.putFile(File(file.path!));
          }

          print("Uploaded: $fileName");
        } catch (e) {
          print("Error uploading $fileName: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to upload $fileName")),
          );
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Documents uploaded successfully.")),
      );

      setState(() {
        _selectedFiles = null;
        _groupController.clear();
        _descriptionController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload documents and enter group name")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF96B7AE),
      appBar: AppBar(
        title: Text(
          "Add Medical Documents",
          style: TextStyle(
            color: Colors.teal[800],
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF96B7AE),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Container(
            width: 500,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Upload Documents",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal[800],
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: Icon(Icons.add),
                  label: Text("Select File or Take Photo"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _pickMedia,
                ),
                if (_selectedFiles != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      "${_selectedFiles!.length} files selected",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ),
                SizedBox(height: 25),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description / Key Points",
                    prefixIcon: Icon(Icons.description),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _groupController,
                  decoration: InputDecoration(
                    labelText: "Group Name (e.g., Myself, Mother)",
                    prefixIcon: Icon(Icons.group),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text("Upload Documents", style: TextStyle(fontSize: 16)),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
