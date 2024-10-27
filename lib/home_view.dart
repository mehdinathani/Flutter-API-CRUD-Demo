import 'dart:convert';

import 'package:apigetdemo/data_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Future<List<postModel>> getData() async {
    var url = Uri.https("jsonplaceholder.typicode.com", "/posts");
    var jsonResponse;
    List<postModel> allData = [];
    var response = await http.get(url);
    if (response.statusCode == 200) {
      jsonResponse = jsonDecode(response.body);
      for (var i in jsonResponse) {
        allData.add(postModel.fromJson(i));
      }
    }

    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          FutureBuilder(
            future: getData(),
            builder: (BuildContext context,
                AsyncSnapshot<List<postModel>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      var item = snapshot.data![index];
                      return ListTile(
                        title: Text(item.title!),
                      );
                    },
                  ),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          )
        ],
      ),
    );
  }
}
