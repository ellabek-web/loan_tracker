<<<<<<< HEAD
import 'package:flutter/material.dart';

class RecordRepaymentPage extends StatefulWidget {
  const RecordRepaymentPage({super.key});
=======
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
>>>>>>> 19bbe7ed594803dc82229e3b7b6c1b31185b241f

  @override
  State<RecordRepaymentPage> createState() => _RecordRepaymentPageState();
}

class _RecordRepaymentPageState extends State<RecordRepaymentPage> {
<<<<<<< HEAD
  String? lender;
  String? borrower;
  DateTime? selectedDate;

  final List<String> members = ['Alice', 'Bob', 'Charlie'];
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
=======
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
    
>>>>>>> 19bbe7ed594803dc82229e3b7b6c1b31185b241f
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
<<<<<<< HEAD
        child: ListView(
          children: [
            _buildDropdownField('Lender', lender, (value) {
              setState(() => lender = value);
            }),
            const SizedBox(height: 12),

            _buildDropdownField('Borrower', borrower, (value) {
              setState(() => borrower = value);
            }),
            const SizedBox(height: 12),

            _buildTextField('Amount', controller: amountController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),

            _buildTextField('Reason', controller: reasonController),
            const SizedBox(height: 12),

            _buildDatePicker(),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Save logic
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        ),
=======
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
>>>>>>> 19bbe7ed594803dc82229e3b7b6c1b31185b241f
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildDropdownField(String label, String? value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: members
          .map((e) => DropdownMenuItem<String>(
                value: e,
                child: Text(e),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: label,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildTextField(String hint, {required TextEditingController controller, TextInputType? keyboardType}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        const Text('Date'),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date != null) {
              setState(() => selectedDate = date);
            }
          },
        ),
        if (selectedDate != null)
          Text('${selectedDate!.year}/${selectedDate!.month}/${selectedDate!.day}'),
      ],
    );
  }
}
=======
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
      // 1. Create repayment record
      await FirebaseFirestore.instance
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

      // 2. Send notification to lender (implementation depends on your notification system)
      await _sendConfirmationNotification();

      setState(() => _isConfirmed = true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record repayment: ${e.toString()}')),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendConfirmationNotification() async {
    // Implement your notification logic here
    // This could be Firebase Cloud Messaging, push notifications, etc.
    debugPrint('Notification sent to ${widget.lenderName} for confirmation');
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
>>>>>>> 19bbe7ed594803dc82229e3b7b6c1b31185b241f
