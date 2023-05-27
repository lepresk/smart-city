import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:smart_city/constant.dart';
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

  Position? _currentPosition;
  String? _currentPositionString;
  bool _postionFetching = false;
  String? _selectedVideo;
  List<String> _images = [];

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

    ImageSource imageSource =
        source == "gallery" ? ImageSource.gallery : ImageSource.camera;

    final imagePicked = await picker.pickImage(
      source: imageSource,
    );
    if (imagePicked != null) {
      setState(() {
        _images.add(imagePicked.path);
      });
    }
  }

  void _pickVideo() async {
    String? source = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ajouter une vidéo"),
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

    ImageSource imageSource =
        source == "gallery" ? ImageSource.gallery : ImageSource.camera;

    final imagePicked = await picker.pickVideo(
      source: imageSource,
    );

    if (imagePicked != null) {
      setState(() {
        _selectedVideo = imagePicked.path;
      });
    }
  }

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      SnackBar snackBar =
          const SnackBar(content: Text("Veuillez activer le GPS"));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        SnackBar snackBar =
            const SnackBar(content: Text("Veuillez accorder la permission!"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      SnackBar snackBar = const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    setState(() {
      _postionFetching = true;
    });

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final location = await Geolocator.getCurrentPosition();
    _currentPosition = location;
    await _reverseGeocodePosition();
    setState(() {
      _postionFetching = false;
    });
  }

  Future<void> _reverseGeocodePosition() async {
    double latittude = _currentPosition!.latitude;
    double longitude = _currentPosition!.longitude;

    try {
      var url = Uri.parse(
          "https://eu1.locationiq.com/v1/reverse?key=$locationIqToken&lat=$latittude&lon=$longitude&format=json");
      var response = await http.get(url);
      Map<String, dynamic> json = jsonDecode(response.body);
      setState(() {
        _currentPositionString = json["display_name"];
      });
    } catch (e) {
      print(e);
    }
  }

  Widget _renderImageGrid() {
    return GridView.builder(
      shrinkWrap: true,
      itemCount: _images.length + 1,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        if (index == _images.length) {
          return GestureDetector(
            onTap: () {
              _pickImage();
            },
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Text("Ajouter une image"),
            ),
          );
        }

        String path = _images[index];

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
          ),
          child: Stack(
            children: [
              Image.file(
                File(path),
              ),
              Positioned(
                top: 3,
                right: 3,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _images.remove(path);
                    });
                  },
                  child: Icon(Icons.cancel),
                ),
              )
            ],
          ),
        );
      },
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text("Images *"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey),
                  ),
                  padding: EdgeInsets.all(_images.isNotEmpty ? 10 : 24),
                  alignment: Alignment.center,
                  child: _images.isEmpty
                      ? const Text("Cliquer pour ajouter une image")
                      : _renderImageGrid(),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Vidéo"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () {
                  _pickVideo();
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: _selectedVideo == null
                      ? const Text("Cliquer pour ajouter une vidéo")
                      : Text(_selectedVideo!),
                ),
              ),
              const SizedBox(height: 16),
              const Text("Votre position"),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _postionFetching ? null : _determinePosition,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.my_location),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _currentPosition == null
                            ? const Text("Cliquer pour la géolocalisation")
                            : Text("Votre position : $_currentPositionString"),
                      ),
                      if (_postionFetching)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                    ],
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
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
              
                  },
                  child: const Text("Signaler"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
