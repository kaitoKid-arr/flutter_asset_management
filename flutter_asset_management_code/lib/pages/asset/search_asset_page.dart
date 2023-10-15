import 'dart:convert';

import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_asset_management_code/config/app_constant.dart';
import 'package:flutter_asset_management_code/models/asset_model.dart';
import 'package:http/http.dart' as http;

class SearchAsset extends StatefulWidget {
  const SearchAsset({super.key});

  @override
  State<SearchAsset> createState() => _SearchAssetState();
}

class _SearchAssetState extends State<SearchAsset> {
  List<AssetModel> assets = [];

  final editSearch = TextEditingController();

  void searchAssets() async {
    if (editSearch.text == '') return;

    assets.clear();
    setState(() {});

    Uri url = Uri.parse(
      '${AppConstant.baseUrl}/asset/search.php',
    );
    try {
      final response = await http.post(url, body: {
        'search': editSearch.text,
      });
      DMethod.printResponse(response);

      Map respBody = jsonDecode(response.body);
      bool success = respBody['success'] ?? false;
      if (success) {
        List data = respBody['data'];
        assets = data.map((e) => AssetModel.fromJson(e)).toList();
      }
         
      setState(() {});
    } catch (e) {
      DMethod.printTitle('catch', e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.purple[100],
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: editSearch,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Search here..',
              isDense: true,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              searchAssets();
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: assets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Empty'),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.refresh,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 72),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: assets.length,
              itemBuilder: (BuildContext context, int index) {
                AssetModel item = assets[index];
                return Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            '${AppConstant.baseUrl}/image/${item.image}',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        item.name,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Text(
                        item.type,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
