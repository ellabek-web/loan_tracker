import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  Future<void> _confirmRepayment(String groupId, String repaymentId) async {
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
    final repaymentRef = groupRef.collection('repayments').doc(repaymentId);

    await repaymentRef.update({'status': 'confirmed'});
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              final Timestamp? timestamp = data['createdAt'];
              final String message = data['message'] ?? '';
              final formattedTime = timestamp != null
                  ? DateFormat.yMMMd().add_jm().format(timestamp.toDate())
                  : 'Time unknown';

              return ListTile(
                title: Text(message),
                subtitle: Text(formattedTime),
                trailing: ElevatedButton(
                  onPressed: () async {
                    await _confirmRepayment(data['groupId'], data['repaymentId']);
                    await data.reference.update({'seen': true});

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Repayment confirmed!')),
                    );
                  },
                  child: const Text('Confirm'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
