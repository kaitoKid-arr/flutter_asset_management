import 'dart:convert';

import 'package:d_info/d_info.dart';
import 'package:d_method/d_method.dart';
import 'package:flutter/material.dart';
import 'package:flutter_asset_management_code/config/app_constant.dart';
import 'package:flutter_asset_management_code/pages/asset/homepage.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatelessWidget {
  LoginPage({super.key});
  final editUsername = TextEditingController();
  final editPassword = TextEditingController();
  final formkey = GlobalKey<FormState>();

  login(BuildContext context) {
    bool isValid = formkey.currentState!.validate();
    if (isValid) {
      // Validated
      Uri url = Uri.parse(
        '${AppConstant.baseUrl}/user/login.php',
      );
      http.post(url, body: {
        'username': editUsername.text,
        'password': editPassword.text,
      }).then((response) {
        DMethod.printResponse(response);

        Map respbody = jsonDecode(response.body);

        bool success = respbody['success'] ?? false;
        if (success) {
          DInfo.toastSuccess('Login Success');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          DInfo.toastError('Login Failed');
        }
      }).catchError((onError) {
        DInfo.toastError('Something error');
        DMethod.printTitle('Catch Error', onError.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -60,
            left: -60,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.purple[300],
            ),
          ),
          Positioned(
            bottom: -90,
            right: -60,
            child: CircleAvatar(
              radius: 120,
              backgroundColor: Colors.purple[300],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            child: Icon(
              Icons.scatter_plot,
              size: 90,
              color: Colors.purple[400],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: formkey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppConstant.appName.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          color: Colors.purple[700],
                        ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    controller: editUsername,
                    validator: (value) => value == '' ? "Don't empty" : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      hintText: 'Username',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: editPassword,
                    obscureText: true,
                    validator: (value) => value == '' ? "Don't empty" : null,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      isDense: true,
                      hintText: 'Password',
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      login(context);
                    },
                    child: const Text(
                      'Login',
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
