import 'dart:convert';

import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_asset_management_code/config/app_constant.dart';
import 'package:flutter_asset_management_code/models/asset_model.dart';
import 'package:flutter_asset_management_code/pages/asset/create_asset_page.dart';
import 'package:flutter_asset_management_code/pages/user/login_page.dart';
import 'package:http/http.dart' as http;

import 'search_asset_page.dart';
import 'update_asset_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<AssetModel> assets = [];

  void readAssets() async {
    assets.clear();
    setState(() {});

    Uri url = Uri.parse(
      '${AppConstant.baseUrl}/asset/read.php',
    );
    try {
      final response = await http.get(url);
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
  void initState() {
    readAssets();
    super.initState();
  }

  void showMenuItem(AssetModel item) {
    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: Text(item.name),
            children: [
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UpdateAssetPage(
                        oldAsset: item,
                      ),
                    ),
                  ).then((value) => readAssets());
                },
                horizontalTitleGap: 0,
                leading: const Icon(
                  Icons.edit,
                  color: Colors.blue,
                ),
                title: const Text('Update'),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                  deleteAsset(item);
                },
                horizontalTitleGap: 0,
                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                title: const Text('Delete'),
              ),
            ],
          );
        });
  }

  void deleteAsset(AssetModel item) async {
    bool? yes = await DInfo.dialogConfirmation(
      context,
      'Delete',
      'Are you sure want to delete ${item.name}?',
    );
    if (yes ?? false) {
      Uri url = Uri.parse(
        '${AppConstant.baseUrl}/asset/delete.php',
      );
      try {
        final response = await http.post(url, body: {
          'id': item.id,
          'image': item.image,
        });
        DMethod.printResponse(response);

        Map respBody = jsonDecode(response.body);
        bool success = respBody['success'] ?? false;
        if (success) {
          DInfo.toastSuccess('Success Delete Asset');
          readAssets(); // Refresh data list asset
        } else {
          DInfo.toastError('Failed Delete Asset');
        }
      } catch (e) {
        DMethod.printTitle('catch', e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PopupMenuButton(
          icon: const Icon(Icons.logout),
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem(
              value: 'logout',
              child: Text('Logout'),
            )
          ],
        ),
        title: const Text(AppConstant.appName),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchAsset()),
              );
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
          : RefreshIndicator(
              onRefresh: () async {
                readAssets();
              },
              child: GridView.builder(
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
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
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
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(4),
                              child: InkWell(
                                onTap: () {
                                  showMenuItem(item);
                                },
                                splashColor: Colors.purpleAccent,
                                borderRadius: BorderRadius.circular(4),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Icon(Icons.more_vert),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateAssetPage()),
          ).then((value) => readAssets());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
