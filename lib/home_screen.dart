// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_prediction/prediction_provider.dart';
import 'package:provider/provider.dart';

bool isVisible = false;

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker picker = ImagePicker();
  XFile imageFile = XFile('');

  // Future<void> _getImage(BuildContext context) async {
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     Uint8List imageBytes = await pickedFile.readAsBytes();
  //     _predictImage(context, imageBytes);
  //   }
  // }

  void takePhoto() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    print("Hello: ${pickedFile?.path}");

    if (pickedFile != null) {
      setState(() {
        imageFile = pickedFile;
        isVisible = true;
        // _predictImage(context, imageFile.path);
      });
    }
  }

  Future<void> _predictImage(BuildContext context, String image) async {
    const String apiUrl = 'http://192.168.1.104:8000/predict';
    print(apiUrl);
    // Replace 'YOUR_API_ENDPOINT' with the actual endpoint for prediction
    try {
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Add the image file
      if (image != '') {
        request.files.add(http.MultipartFile(
          'imagefile',
          http.ByteStream(Stream.castFrom(File(image).openRead())),
          await File(image).length(),
          filename: 'image.jpg', // Set your desired filename here
        ));
      }
      // Send the request and get the response
      final response = await request.send();

      // Handle the API response
      if (response.statusCode == 200) {
        final String responseBody = await response.stream.bytesToString();

        // Parse the JSON response
        final Map<String, dynamic> data = jsonDecode(responseBody);
        print(data);
        String name = data['name'];
        double accuracy = data['accuracy'];

        context.read<PredictionProvider>().setPrediction(name, accuracy);
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception
      print('Exception: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Prediction App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: ClipRect(
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Center(
                    child: isVisible
                        ? Image.file(
                            File(imageFile.path),
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain, // Maintain aspect ratio
                          )
                        : const Icon(
                            Icons.image,
                            size: 50,
                          ),
                  ),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => takePhoto(),
              child: const Text('Select Image'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (imageFile.path != '') {
                  _predictImage(context, imageFile.path);
                } else {
                  print("No image selected");
                }
              },
              // Replace Uint8List(0) with the actual image bytes after selection
              child: const Text('Predict'),
            ),
            const SizedBox(height: 16),
            Consumer<PredictionProvider>(
              builder: (context, provider, child) {
                return Column(
                  children: [
                    Text('Prediction: ${provider.name}'),
                    Text('Accuracy: ${provider.accuracy.toStringAsFixed(2)}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
