import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:provider/provider.dart';
import 'package:loan_tracker/providers/group_provider.dart';

class AddMembersPage extends StatefulWidget {
  final Group group;
  const AddMembersPage({super.key, required this.group});

  @override
  State<AddMembersPage> createState() => _AddMembersPageState();
}

class _AddMembersPageState extends State<AddMembersPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedUserIds = {};
  List<Map<String, dynamic>> _allUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();

      setState(() {
        _allUsers = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'uid': doc.id,
            'firstName': data['firstName'] ?? '',
            'lastName': data['lastName'] ?? '',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load users: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleUserSelection(String uid) {
    setState(() {
      if (_selectedUserIds.contains(uid)) {
        _selectedUserIds.remove(uid);
      } else {
        _selectedUserIds.add(uid);
      }
    });
  }

  Future<void> _addMembers() async {
    if (_selectedUserIds.isEmpty) return;

    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    try {
      await groupProvider.addMembers(_selectedUserIds.toList());
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added ${_selectedUserIds.length} members')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add members: ${e.toString()}')),
        );
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredUsers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return _allUsers;
    
    return _allUsers.where((user) {
      final fullName = '${user['firstName']} ${user['lastName']}'.toLowerCase();
      return fullName.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Members'),
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
            // Search field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search members',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),

            // Selection counter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select members'),
                Text(
                  '${_selectedUserIds.length} selected',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Member list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                      ? Center(child: Text(_errorMessage!))
                      : ListView.builder(
                          itemCount: filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredUsers[index];
                            final fullName = '${user['firstName']} ${user['lastName']}';
                            final uid = user['uid'];
                            final selected = _selectedUserIds.contains(uid);
                            final alreadyInGroup = widget.group.memberIds.contains(uid);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: selected 
                                    ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
                                    : BorderSide.none,
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(fullName),
                                subtitle: alreadyInGroup 
                                    ? const Text('Already in group', style: TextStyle(color: Colors.grey))
                                    : null,
                                trailing: selected
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : null,
                                onTap: alreadyInGroup 
                                    ? null
                                    : () => _handleUserSelection(uid),
                              ),
                            );
                          },
                        ),
            ),

            // Add button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedUserIds.isEmpty ? null : _addMembers,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Add Selected Members'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
