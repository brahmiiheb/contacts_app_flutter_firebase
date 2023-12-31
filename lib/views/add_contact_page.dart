import 'package:flutter/material.dart';
import 'package:contacts_app/controllers/crud_services.dart';
import 'package:image_picker/image_picker.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  String? _imageUrl;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    //final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String imageUrl = await CRUDService().uploadImage(pickedFile.path);
      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Contact")),
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
                    backgroundImage: NetworkImage(_imageUrl!),
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
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        CRUDService().addNewContacts(
                          _nameController.text,
                          _phoneController.text,
                          _emailController.text,
                          _imageUrl!,
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text(
                      "Create",
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
