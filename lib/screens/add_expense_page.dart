import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:loan_tracker/providers/user_service.dart';
import 'package:provider/provider.dart';
import 'package:loan_tracker/providers/group_provider.dart';

class AddExpensePage extends StatefulWidget {
  final Group group;
  const AddExpensePage({super.key, required this.group});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  String? paidById;
  final Map<String, bool> sharedMemberIds = {};
  final Map<String, double> customAmounts = {};
  String splitMethod = 'Equally';
  DateTime selectedDate = DateTime.now();
  double totalAmount = 0;

  final TextEditingController amountController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();
  List<String> _memberNames = [];
  List<String> _memberIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final userService = Provider.of<UserServiceProvider>(context, listen: false);
    
    setState(() {
      _memberIds = widget.group.memberIds;
      _isLoading = true;
    });

    try {
      final names = await userService.getMemberNames(_memberIds);
      
      setState(() {
        _memberNames = names;
        for (var i = 0; i < _memberIds.length; i++) {
          sharedMemberIds[_memberIds[i]] = false;
          customAmounts[_memberIds[i]] = 0;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load members: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            // Who Paid Dropdown
            _buildPayerDropdown(),
            const SizedBox(height: 16),

            // Amount Field
            _buildAmountField(),
            const SizedBox(height: 16),

            // Shared By Section
            _buildSharedBySection(),
            const SizedBox(height: 16),

            // Split Method
            _buildSplitMethodSelector(),
            if (splitMethod == 'Custom') ...[
              const SizedBox(height: 8),
              _buildCustomAmountInputs(),
            ],

            // Reason Field
            _buildReasonField(),
            const SizedBox(height: 16),

            // Date Picker
            _buildDatePicker(),
            const SizedBox(height: 24),

            // Save Button
            ElevatedButton(
              onPressed: _validateForm() ? () => _saveExpense() : null,
              child: const Text('Save Expense'),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    return paidById != null && 
           amountController.text.isNotEmpty &&
           sharedMemberIds.containsValue(true) &&
           reasonController.text.isNotEmpty;
  }

  Future<void> _saveExpense() async {
    final amount = double.parse(amountController.text);
    final reason = reasonController.text;
    final sharedCount = sharedMemberIds.values.where((v) => v).length;
    final perPersonAmount = amount / sharedCount;

    // Create mapping between indices and IDs
    final idToName = <String, String>{};
    for (var i = 0; i < _memberIds.length; i++) {
      idToName[_memberIds[i]] = _memberNames[i];
    }

    final expenseData = {
      'paidById': paidById,
      'paidByName': idToName[paidById],
      'amount': amount,
      'reason': reason,
      'date': Timestamp.fromDate(selectedDate),
      'splitMethod': splitMethod,
      'shares': _memberIds.asMap().map((index, memberId) {
        final isSharing = sharedMemberIds[memberId] ?? false;
        final amount = isSharing
            ? splitMethod == 'Equally'
                ? perPersonAmount
                : customAmounts[memberId] ?? 0
            : 0;
        return MapEntry(memberId, amount);
      }),
      'createdAt': FieldValue.serverTimestamp(),
    };

    try {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .collection('expenses')
          .add(expenseData);

      // Update balances
      await groupProvider.updateBalancesAfterExpense(
        widget.group.id,
        paidById!,
        expenseData['shares'] as Map<String, dynamic>,
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add expense: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildPayerDropdown() {
    return DropdownButtonFormField<String>(
      value: paidById,
      items: _memberIds.asMap().entries.map((entry) {
        final index = entry.key;
        final memberId = entry.value;
        return DropdownMenuItem<String>(
          value: memberId,
          child: Text(_memberNames[index]),
        );
      }).toList(),
      onChanged: (value) => setState(() => paidById = value),
      decoration: InputDecoration(
        labelText: 'Who Paid',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildAmountField() {
    return TextField(
      controller: amountController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Amount',
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onChanged: (value) {
        setState(() {
          totalAmount = double.tryParse(value) ?? 0;
        });
      },
    );
  }

  Widget _buildSharedBySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Shared By', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ..._memberIds.asMap().entries.map((entry) {
          final index = entry.key;
          final memberId = entry.value;
          return CheckboxListTile(
            title: Text(_memberNames[index]),
            value: sharedMemberIds[memberId] ?? false,
            onChanged: (value) {
              setState(() {
                sharedMemberIds[memberId] = value!;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _buildSplitMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Split Method', style: TextStyle(fontSize: 16)),
        Row(
          children: [
            Radio<String>(
              value: 'Equally',
              groupValue: splitMethod,
              onChanged: (value) => setState(() => splitMethod = value!),
            ),
            const Text('Equally'),
            const SizedBox(width: 20),
            Radio<String>(
              value: 'Custom',
              groupValue: splitMethod,
              onChanged: (value) => setState(() => splitMethod = value!),
            ),
            const Text('Custom'),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomAmountInputs() {
    return Column(
      children: _memberIds.asMap().entries.where((entry) {
        final memberId = entry.value;
        return sharedMemberIds[memberId] ?? false;
      }).map((entry) {
        final index = entry.key;
        final memberId = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextField(
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Amount for ${_memberNames[index]}',
              prefixText: '\$ ',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (value) {
              customAmounts[memberId] = double.tryParse(value) ?? 0;
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReasonField() {
    return TextField(
      controller: reasonController,
      decoration: InputDecoration(
        labelText: 'Reason',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildDatePicker() {
    return Row(
      children: [
        const Text('Date', style: TextStyle(fontSize: 16)),
        const Spacer(),
        TextButton(
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
          child: Row(
            children: [
              Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
              const SizedBox(width: 8),
              const Icon(Icons.calendar_today, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}