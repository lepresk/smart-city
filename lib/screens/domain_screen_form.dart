import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_city/models/domain.dart';

List<String> _categories = [
  "",
  "Policie",
  "Gendarmerie",
  "Sapeur pompier",
];

class DomainScreenForm extends StatefulWidget {
  final Domain domain;
  const DomainScreenForm({super.key, required this.domain});

  @override
  State<DomainScreenForm> createState() => _DomainScreenFormState();
}

class _DomainScreenFormState extends State<DomainScreenForm> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _selectedImage;
  String _selectedCategory = "";

  final ImagePicker picker = ImagePicker();

  void _pickImage() async {
    String? source = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter une image"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop("gallery");
                },
                child: Text("Seléctioner depuis la galerie"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop("camera");
                },
                child: Text("Ouvrir la camera"),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    ImageSource imageSource = source == "gallery" ? ImageSource.gallery : ImageSource.camera;

    final imagePicked = await picker.pickImage(
      source: imageSource,
    );
    if (imagePicked != null) {
      setState(() {
        _selectedImage = imagePicked.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.domain.name),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom et prénom',
                ),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Numéro de téléphone",
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Catégorie",
                ),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? '';
                  });
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: _selectedImage == null
                      ? const Text("Cliquer pour ajouter une image")
                      : Image.file(
                          File(_selectedImage!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: "Description",
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                minLines: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
