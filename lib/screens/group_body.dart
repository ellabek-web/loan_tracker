import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:loan_tracker/providers/group_provider.dart';
import 'package:loan_tracker/screens/create_group.dart';
import 'package:loan_tracker/screens/group_page.dart';
import 'package:provider/provider.dart';

class GroupBody extends StatefulWidget {
  const GroupBody({super.key});

  @override
  State<GroupBody> createState() => _GroupBodyState();
}

class _GroupBodyState extends State<GroupBody> {
  late TextEditingController _searchController;
  late Stream<List<Group>> _groupsStream;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    _groupsStream = currentUserId != null
        ? Provider.of<GroupProvider>(context, listen: false)
            .groupsStream(currentUserId)
        : Stream.value([]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Group> _filterGroups(List<Group> groups, String query) {
    if (query.isEmpty) return groups;
    return groups.where((group) => 
      group.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
           padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Material(
                elevation: 2,
                borderRadius: BorderRadius.circular(25),
                child: TextField(
                  controller: _searchController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Search groups',
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
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: StreamBuilder<List<Group>>(
                  stream: _groupsStream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading groups',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      );
                    }
                    
                    final allGroups = snapshot.data ?? [];
                    final filteredGroups = _filterGroups(allGroups, _searchQuery);
          
                    if (filteredGroups.isEmpty && _searchQuery.isNotEmpty) {
                      return Center(
                        child: Text(
                          'No groups found for "$_searchQuery"',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }
          
                    return GridView.count(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      // padding: const EdgeInsets.symmetric(
                      //     horizontal: 16, vertical: 10),
                      children: [
                        ...filteredGroups.map(
                          (group) => _buildGroupCard(context, group),
                        ),
                        if (_searchQuery.isEmpty) _buildCreateGroupCard(context),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(BuildContext context, Group group) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => GroupDetail(group: group)),
      ),
      child: Card(
        elevation: 2,
        color: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(Icons.north_east),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateGroupCard(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    
    return GestureDetector(
      onTap: () async {
        final newGroupName = await Navigator.push<String>(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupPage()),
        );

        if (newGroupName != null && newGroupName.isNotEmpty) {
          final currentUserId = FirebaseAuth.instance.currentUser!.uid;
          await groupProvider.createGroup(
            newGroupName, 
            currentUserId, 
            context,
          );
        }
      },
      child: Card(
        elevation: 2,
        color: Theme.of(context).colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Create New"),
              SizedBox(height: 8),
              Icon(Icons.add),
            ],
          ),
        ),
      ),
    );
  }
}