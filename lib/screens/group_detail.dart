import 'package:flutter/material.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupName;
  const GroupDetailPage({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(groupName)),
      body: Center(child: Text("Welcome to $groupName group!")),
    );
  }
}
