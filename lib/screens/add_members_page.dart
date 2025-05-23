import 'package:flutter/material.dart';

class AddMembersPage extends StatefulWidget {
  const AddMembersPage({super.key});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final List<String> _allUsers = List.generate(5, (_) => 'John Doe');

  final Set<int> _selectedIndexes = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Group'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Group name input
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'enter group name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
              ),
            ),

            const SizedBox(height: 16),

            // Member label and counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Add members'),
                Text('${_selectedIndexes.length} selected'),
              ],
            ),

            const SizedBox(height: 12),

            // Search field (optional logic later)
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search group',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                filled: true,
              ),
              onChanged: (value) {
                // TODO: Implement search logic if needed
              },
            ),

            const SizedBox(height: 16),

            // Member list
            Expanded(
              child: ListView.builder(
                itemCount: _allUsers.length,
                itemBuilder: (context, index) {
                  final bool selected = _selectedIndexes.contains(index);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedIndexes.remove(index);
                        } else {
                          _selectedIndexes.add(index);
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: selected ? Border.all(width: 2) : null,
                      ),
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(_allUsers[index]),
                        trailing: selected
                            ? const Icon(Icons.check_circle, size: 20)
                            : const SizedBox.shrink(),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Create Group button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Handle group creation
                  Navigator.pop(context); // Pop after creation for now
                },
                child: const Text('add'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
