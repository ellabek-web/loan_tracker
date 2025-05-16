import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'group_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        // backgroundColor: Colors.grey[300],
        elevation: 0,
        title: const Text('account',  ),
        // leading: Builder(
        //   builder: (context) => IconButton(
        //     icon: const Icon(Icons.menu,),
        //     onPressed: () => Scaffold.of(context).openDrawer(),
        //   ),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, ),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      // backgroundColor: Colors.white,
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: GroupBody(),
      ),
    );
  }
}
