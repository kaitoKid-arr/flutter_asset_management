import 'dart:convert';
import 'dart:typed_data';

import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import '../../config/app_constant.dart';

class CreateAssetPage extends StatefulWidget {
  CreateAssetPage({super.key});

  @override
  State<CreateAssetPage> createState() => _CreateAssetPageState();
}

class _CreateAssetPageState extends State<CreateAssetPage> {
  final formKey = GlobalKey<FormState>();
  final editName = TextEditingController();

  List<String> types = [
    'Mage',
    'Tank',
    'Assasin',
    'Marskman',
    'Support',
    'Other',
  ];

  String type = 'Support';
  String? imageName;
  Uint8List? imageByte;

  pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      // If has a data
      imageName = picked.name;
      imageByte = await picked.readAsBytes();
      setState(() {});
    }
    DMethod.printBasic('imageName = $imageName');
  }

  save() async {
    bool isValidInput = formKey.currentState!.validate();

    // If not valid, stop/return
    if (!isValidInput) return;

    // If valid, go on

    // If not have image, stop/return
    if (imageByte == null) {
      DInfo.toastError('Image is empty');
      return;
    }

    // If have an image, go on
    Uri url = Uri.parse(
      '${AppConstant.baseUrl}/asset/create.php',
    );
    try {
      final response = await http.post(url, body: {
        'name': editName.text,
        'type': type,
        'image': imageName,
        'base64code': base64Encode(imageByte as List<int>),
      });
      DMethod.printResponse(response);

      Map respBody = jsonDecode(response.body);
      bool success = respBody['success'] ?? false;
      if (success) {
        DInfo.toastSuccess('Success Create New Asset');
        Navigator.pop(context);
      } else {
        DInfo.toastError('Failed Create New Asset');
      }
    } catch (e) {
      DMethod.printTitle('catch', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Asset'),
        centerTitle: true,
      ),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              DInput(
                controller: editName,
                title: 'Name',
                hint: 'Type something',
                fillColor: Colors.white,
                radius: BorderRadius.circular(10),
                validator: (input) => input == '' ? "Don't empty" : null,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16),
                  // isDense: true,
                ),
                value: type,
                icon: Icon(Icons.keyboard_arrow_down),
                items: types.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    type = value;
                  }
                },
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 8,
              ),
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  child: imageByte == null
                      ? Text('Empty')
                      : Image.memory(
                          imageByte!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                ),
              ),
              ButtonBar(
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.camera);
                    },
                    icon: Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {
                      pickImage(ImageSource.gallery);
                    },
                    icon: Icon(Icons.image),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                onPressed: () => save(),
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
