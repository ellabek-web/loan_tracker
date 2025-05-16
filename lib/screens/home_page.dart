import 'package:flutter/material.dart';
import 'custom_drawer.dart';
import 'group_body.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _groups = [];

  void _navigateAndCreateGroup() async {
    final newGroupName = await context.push<String>('/create-group');
    if (newGroupName != null && newGroupName.isNotEmpty) {
      setState(() {
        _groups.add(newGroupName);
      });
    }
  }

  void _openGroup(String groupName) {
    context.go('/group?name=$groupName');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateAndCreateGroup,
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _groups.isEmpty
            ? const Center(child: Text("No groups created yet"))
            : ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  final group = _groups[index];
                  return ListTile(
                    title: Text(group),
                    onTap: () => _openGroup(group),
                  );
                },
              ),
      ),
    );
  }
}
