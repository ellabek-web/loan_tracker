import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String? paidBy;
  String? sharedBy;
  String splitMethod = 'Equally';
  DateTime? selectedDate;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  final List<String> members = ['Alice', 'Bob', 'Charlie'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildDropdownField('Who Paid', paidBy, (value) {
              setState(() => paidBy = value);
            }),
            const SizedBox(height: 12),

            _buildTextField('Total Amount', controller: amountController, keyboardType: TextInputType.number),
            const SizedBox(height: 12),

            _buildDropdownField('Who Shared', sharedBy, (value) {
              setState(() => sharedBy = value);
            }),
            const SizedBox(height: 12),

            // Split Method
            const Text('Split Method'),
            Row(
              children: ['Equally', 'Custom', 'Percentage']
                  .map((option) => Row(
                        children: [
                          Radio<String>(
                            value: option,
                            groupValue: splitMethod,
                            onChanged: (value) {
                              setState(() => splitMethod = value!);
                            },
                          ),
                          Text(option),
                        ],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 12),

            _buildTextField('Reason', controller: reasonController),
            const SizedBox(height: 12),

            // Date Picker
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
