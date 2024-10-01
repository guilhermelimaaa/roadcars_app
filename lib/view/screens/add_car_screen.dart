import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddCarScreen extends StatefulWidget {
  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _carImage;
  String? _carImageUrl;

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _carImage = File(pickedImage.path);
      });
    }
  }

  Future<String?> _uploadCarImageToStorage(String carId) async {
    if (_carImage == null) return null;

    try {
      Reference storageRef = _storage.ref().child('carImages/$carId.jpg');
      UploadTask uploadTask = storageRef.putFile(_carImage!);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return null;
    }
  }

  Future<void> _addCar() async {
    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference carDoc = await _firestore.collection('cars').add({
          'brand': _brandController.text,
          'model': _modelController.text,
          'year': _yearController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        _carImageUrl = await _uploadCarImageToStorage(carDoc.id);

        if (_carImageUrl != null) {
          await carDoc.update({
            'imageUrl': _carImageUrl,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Carro adicionado com sucesso!')),
        );
        Navigator.pop(context);

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar carro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Adicionar Carro para Venda'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCar,
        child: Icon(Icons.save),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _brandController,
                    decoration: InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a marca do carro';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    decoration: InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o modelo do carro';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o ano do carro';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o preço do carro';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma descrição para o carro';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          _carImage != null ? FileImage(_carImage!) : null,
                      child: _carImage == null ? Icon(Icons.camera_alt, size: 50) : null,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addCar,
                    icon: Icon(Icons.add),
                    label: Text('Adicionar Carro'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
