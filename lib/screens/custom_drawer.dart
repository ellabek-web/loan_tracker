import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // backgroundColor: Colors.grey[300],
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(
                'assets/images/baba.jpg',
              ), // r0eplace with your asset
            ),
            const SizedBox(height: 10),
            const Text(
              'kibre Ab',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text('+1 11229382748'),
            const Text('example@gmail.com'),
            const SizedBox(height: 30),
            
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Notifications'),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Notifications'),
                      content: const Text('No notifications.'),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop(); // Close the dialog
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.goNamed('login');
              },
            ),
          ],
        ),
      ),
    );
  }
}
