import 'package:flutter/material.dart';

class RecordRepaymentPage extends StatefulWidget {
  const RecordRepaymentPage({super.key});

  @override
  State<RecordRepaymentPage> createState() => _RecordRepaymentPageState();
}

class _RecordRepaymentPageState extends State<RecordRepaymentPage> {
  String? lender;
  String? borrower;
  DateTime? selectedDate;

  final List<String> members = ['Alice', 'Bob', 'Charlie'];
  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }

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
