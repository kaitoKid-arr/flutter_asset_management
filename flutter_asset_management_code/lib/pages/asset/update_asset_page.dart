// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:typed_data';

import 'package:d_info/d_info.dart';
import 'package:d_input/d_input.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../config/app_constant.dart';
import '../../models/asset_model.dart';

class UpdateAssetPage extends StatefulWidget {
  const UpdateAssetPage({
    Key? key,
    required this.oldAsset,
  }) : super(key: key);

  final AssetModel oldAsset;

  @override
  State<UpdateAssetPage> createState() => _UpdateAssetPageState();
}

class _UpdateAssetPageState extends State<UpdateAssetPage> {
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

    // If have an image, go on
    Uri url = Uri.parse(
      '${AppConstant.baseUrl}/asset/update.php',
    );
    try {
      final response = await http.post(url, body: {
        'id': widget.oldAsset.id,
        'name': editName.text,
        'type': type,
        'old_image': widget.oldAsset.image,
        'new_image': imageName ?? widget.oldAsset.image,
        'new_base64code':
            imageByte == null ? '' : base64Encode(imageByte as List<int>),
      });
      DMethod.printResponse(response);

      Map respBody = jsonDecode(response.body);
      bool success = respBody['success'] ?? false;
      if (success) {
        DInfo.toastSuccess('Success Update Asset');
        Navigator.pop(context);
      } else {
        DInfo.toastError('Failed Update Asset');
      }
    } catch (e) {
      DMethod.printTitle('catch', e.toString());
    }
  }

  @override
  void initState() {
    editName.text = widget.oldAsset.name;
    type = widget.oldAsset.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Asset'),
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
                      ? Image.network(
                          '${AppConstant.baseUrl}/image/${widget.oldAsset.image}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
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
