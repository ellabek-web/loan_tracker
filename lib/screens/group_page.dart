import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loan_tracker/screens/add_members_page.dart';

class CbeStaffPage extends StatefulWidget {
  const CbeStaffPage({super.key});

  @override
  _CbeStaffPageState createState() => _CbeStaffPageState();
}

class _CbeStaffPageState extends State<CbeStaffPage> {
  int _selectedTag = 0;
  int _selectedUser = 0;

  final List<String> _tags = ['Members', 'Transactions', 'Overview'];
  final List<String> _users = List.generate(5, (_) => 'John Doe');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CBE Staff'),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            context.go('/home');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tag buttons with spacing for alignment
            Row(
              children: [
                _buildTagButton('Members', 0),
                const SizedBox(width: 8),
                _buildTagButton('Transactions', 1),
                const SizedBox(width: 8),
                Expanded(child: _buildTagButton('Overview', 2)),
              ],
            ),
            const SizedBox(height: 12),

            // Conditional action buttons
            if (_selectedTag == 0)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                    onPressed: () {
                    // TODO: Add Member
                    Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddMembersPage()),
        );
   // TODO: Add Member
                  },
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            if (_selectedTag == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Add Expense
                    },
                    child: const Text('Add Expense'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Record Repayment
                    },
                    child: const Text('Record Repayment'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            if (_selectedTag == 2)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: const Text('Balance: +120'),
                ),
              ),

            const SizedBox(height: 16),

            // Dynamic content
            Expanded(child: _buildPageContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildTagButton(String label, int index) {
    final bool selected = _selectedTag == index;
    return InkWell(
      onTap: () => setState(() => _selectedTag = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedTag) {
      case 0:
        return ListView.builder(
          itemCount: _users.length,
          itemBuilder: (context, index) {
            bool selected = index == _selectedUser;
            return GestureDetector(
              onTap: () => setState(() => _selectedUser = index),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  border: selected ? Border.all(width: 2) : null,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(_users[index]),
                ),
              ),
            );
          },
        );

      case 1:
        return ListView(
          children: List.generate(
            3,
            (index) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Alice paid \$60 for dinner\nfor Alice, Bob, and Charlie",
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Charlie paid back Alice \$10\nfor his dinner share",
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

      case 2:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            children: const [
              Text('You owe Alice \$X, Bob \$X'),
              SizedBox(height: 16),
              Text('You are owed Alice \$Y, Bob \$X'),
            ],
          ),
        );

      default:
        return const SizedBox();
    }
  }
}
