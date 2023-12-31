import 'dart:io';

import 'package:flutter/material.dart';
import 'package:contacts_app/controllers/crud_services.dart';
import 'package:image_picker/image_picker.dart';

class UpdateContact extends StatefulWidget {
  const UpdateContact({
    Key? key,
    required this.docID,
    required this.name,
    required this.phone,
    required this.email,
    required this.imageUrl,
  }) : super(key: key);

  final String docID, name, phone, email, imageUrl;

  @override
  State<UpdateContact> createState() => _UpdateContactState();
}

class _UpdateContactState extends State<UpdateContact> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _imageUrl;
  String? _actualImage;
  bool _imageChanged = false; // Add this variable to track if the image has changed

  @override
  void initState() {
    _emailController.text = widget.email;
    _phoneController.text = widget.phone;
    _nameController.text = widget.name;
    _imageUrl = widget.imageUrl;
    _actualImage = widget.imageUrl;

    super.initState();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageUrl = pickedFile.path;
        _imageChanged = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Contact")),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Add a button to pick an image
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text("Pick Image"),
                ),
                if (_imageUrl != null)
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageChanged
                        ? Image.file(File(_imageUrl!)).image
                        : File(_imageUrl!).existsSync()
                        ? Image.file(File(_imageUrl!)).image
                        : Image.network(_imageUrl!).image,
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: TextFormField(
                    validator: (value) =>
                    value!.isEmpty ? "Enter any name" : null,
                    controller: _nameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Name"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Phone"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .9,
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      label: Text("Email"),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 65,
                  width: MediaQuery.of(context).size.width * .9,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        if (_imageChanged) {
                          // Upload new image and get URL
                          String imageUrl =
                          await CRUDService().uploadImage(_imageUrl!);
                          // Update contact with new image URL
                          await CRUDService().updateContact(
                            _nameController.text,
                            _phoneController.text,
                            _emailController.text,
                            widget.docID,
                            imageUrl: imageUrl,
                          );
                        } else {
                          // Update contact without changing the image
                          await CRUDService().updateContact(
                            _nameController.text,
                            _phoneController.text,
                            _emailController.text,
                            widget.docID,
                            imageUrl: _actualImage,
                          );
                        }
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Update",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 65,
                  width: MediaQuery.of(context).size.width * .9,
                  child: OutlinedButton(
                    onPressed: () {
                      CRUDService().deleteContact(widget.docID);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontSize: 16),
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
