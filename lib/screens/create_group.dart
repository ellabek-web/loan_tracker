import 'package:flutter/material.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final TextEditingController _controller = TextEditingController();

  void _submitGroup() {
    final name = _controller.text.trim();
    if (name.isNotEmpty) {
      Navigator.pop(context, name); // send back to GroupBody
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Group")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: "Enter group name",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitGroup,
              child: const Text("OK"),
            ),
          ],
        ),
      ),
    );
  }
}
