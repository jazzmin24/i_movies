import 'package:flutter/material.dart';

class DetailedView extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final String location;

  DetailedView({
    required this.image,
    required this.title,
    required this.description,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detailed View'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(image),
          SizedBox(height: 20),
          Text(
            'Title: $title',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text('Description: $description', style: TextStyle(fontSize: 16)),
          Text('Location: $location', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}




