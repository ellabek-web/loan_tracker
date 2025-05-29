import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:loan_tracker/providers/user_service.dart';
import 'package:provider/provider.dart';

class RecordRepaymentPage extends StatefulWidget {
  final Group group;
  final String lender;
  final String lenderName;
  final String borrower;
  final double amount;
  final String reason;
  
  const RecordRepaymentPage({
    super.key, 
    required this.group,
    required this.lender,
    required this.lenderName,
    required this.borrower,
    required this.amount,
    required this.reason,
  });

  @override
  State<RecordRepaymentPage> createState() => _RecordRepaymentPageState();
}

class _RecordRepaymentPageState extends State<RecordRepaymentPage> {
  late String lender;
  late String borrower;
  late double amount;
  late String reason;
  DateTime selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    lender = widget.lender;
    borrower = widget.borrower;
    amount = widget.amount;
    reason = widget.reason;
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserServiceProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Repayment'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _isConfirmed
            ? _buildConfirmationSuccess()
            : FutureBuilder<String>(
                future: userService.getUserFullName(lender),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildRepaymentForm(snapshot.data!);
                },
              ),
      ),
    );
  }

  Widget _buildRepaymentForm(String lenderName) {
    return ListView(
      children: [
        ListTile(
          title: const Text('Lender'),
          subtitle: Text(lenderName),
        ),
        ListTile(
          title: const Text('Borrower'),
          subtitle: Text(FirebaseAuth.instance.currentUser?.displayName ?? 'You'),
        ),
        ListTile(
          title: const Text('Amount'),
          subtitle: Text('\$${amount.toStringAsFixed(2)}'),
        ),
        ListTile(
          title: const Text('Reason'),
          subtitle: Text(reason.isNotEmpty ? reason : 'No reason provided'),
        ),
        _buildDatePicker(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRepayment,
          child: _isSubmitting
              ? const CircularProgressIndicator()
              : const Text('Confirm Repayment'),
        ),
      ],
    );
  }

  Widget _buildConfirmationSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Repayment Recorded!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Waiting for ${widget.lenderName} to confirm',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

Future<void> _submitRepayment() async {
  setState(() => _isSubmitting = true);

  try {
    final currentUser = FirebaseAuth.instance.currentUser;
    final borrowerName = currentUser?.displayName ?? 'Someone';

    // Step 1: Create the repayment record
    final repaymentRef = await FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group.id)
        .collection('repayments')
        .add({
          'lenderId': lender,
          'borrowerId': borrower,
          'amount': amount,
          'reason': reason,
          'date': Timestamp.fromDate(selectedDate),
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });

    await repaymentRef.update({'id': repaymentRef.id});

    // Step 2: Send notification to lender
    await FirebaseFirestore.instance
        .collection('users')
        .doc(lender)
        .collection('notifications')
        .add({
          'type': 'repayment',
          'repaymentId': repaymentRef.id,
          'groupId': widget.group.id,
          'message':
              '$borrowerName paid \$${amount.toStringAsFixed(2)} for "$reason"',
          'createdAt': FieldValue.serverTimestamp(),
          'seen': false,
        });

    setState(() => _isConfirmed = true);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to record repayment: ${e.toString()}')),
    );
    setState(() => _isSubmitting = false);
  }
}


  Widget _buildDatePicker() {
    return ListTile(
      title: const Text('Date'),
      subtitle: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final date = await showDatePicker(
            context: context,
            initialDate: selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date != null) {
            setState(() => selectedDate = date);
          }
        },
      ),
    );
  }
}