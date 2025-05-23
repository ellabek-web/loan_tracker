import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Future<Map<String, dynamic>?> _fetchUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    return doc.exists ? doc.data() : null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            FutureBuilder<Map<String, dynamic>?>(
              future: _fetchUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const DrawerHeader(
                    decoration: BoxDecoration(),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final data = snapshot.data;
                final name = data != null
                    ? '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'
                    : 'No Name';
                final email = data != null ? data['email'] ?? '' : '';
                final photoUrl = data != null ? data['photoUrl'] : null;

                return DrawerHeader(
                 // decoration: const BoxDecoration(color: Colors.blue),
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundImage:
                              photoUrl != null ? NetworkImage(photoUrl) : null,
                          child: photoUrl == null
                              ? const Icon(Icons.person, size: 35, )
                              : null,
                        
                        ),
                        
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          
                          ),
                        ),
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 14,
                            
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

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
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );
              },
            ),

            const Spacer(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  context.goNamed('login');
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
