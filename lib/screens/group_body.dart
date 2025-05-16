import 'package:flutter/material.dart';
import 'package:loan_tracker/screens/create_group.dart';
import 'package:loan_tracker/screens/group_detail.dart';

class GroupBody extends StatefulWidget {
  const GroupBody({super.key});

  @override
  State<GroupBody> createState() => _GroupBodyState();
}

class _GroupBodyState extends State<GroupBody> {
  List<String> groups = [];
  List<String> filteredGroups = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredGroups = groups;
    searchController.addListener(_filterGroups);
  }

  void _filterGroups() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredGroups = groups
          .where((group) => group.toLowerCase().contains(query))
          .toList();
    });
  }

  void _addGroup(String groupName) {
    setState(() {
      groups.add(groupName);
      filteredGroups = groups
          .where((group) =>
              group.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GroupDetailPage(groupName: groupName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.black : Colors.black;
    final iconColor = isDark ? Colors.black : Colors.black;

    return Column(
      children: [
        // Stylish floating search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Material(
            elevation: 2,
            borderRadius: BorderRadius.circular(25),
            child: TextField(
              controller: searchController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                // contentPadding:
                //     const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                // prefixIcon: Icon(Icons.search, color: iconColor),
                hintText: 'Search group',
                hintStyle: TextStyle(color: iconColor),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              ...filteredGroups.map(
                (groupName) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroupDetailPage(groupName: groupName),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[300] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          groupName,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(Icons.north_east, color: iconColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Create Group Card
              GestureDetector(
                onTap: () async {
                  final newGroupName = await Navigator.push<String>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateGroupPage(),
                    ),
                  );
                  if (newGroupName != null && newGroupName.isNotEmpty) {
                    _addGroup(newGroupName);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[300] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Create", style: TextStyle(color: textColor)),
                      const SizedBox(height: 8),
                      Icon(Icons.add, color: iconColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
