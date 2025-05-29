import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:loan_tracker/screens/add_expense_page.dart';
import 'package:loan_tracker/screens/record_repayment_page.dart';
import 'package:loan_tracker/screens/add_members_page.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:loan_tracker/providers/group_provider.dart';
import 'package:loan_tracker/providers/user_service.dart';

class GroupDetail extends StatefulWidget {
  final Group group;
  const GroupDetail({Key? key, required this.group}) : super(key: key);

  @override
  _GroupDetailState createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  int _selectedTag = 0;
  int _selectedUser = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      groupProvider.setGroup(widget.group);
    });
  }

  final List<String> _tags = ['Members', 'Transactions', 'Overview'];

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final userService = Provider.of<UserServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Tags Row
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

            // Dynamic Action Buttons
            if (_selectedTag == 0)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToAddMembers(context),
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Add'),
                ),
              ),
            if (_selectedTag == 1) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddExpensePage(group: widget.group),
                      ),
                    ),
                    child: const Text('Add Expense'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
  onPressed: () async {
    final debtInfo = await _getOwedAmount(context);
    if (debtInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No debts to repay')));
      return;
    }

    final lenderName = await Provider.of<UserServiceProvider>(context, listen: false)
        .getUserFullName(debtInfo['lenderId']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordRepaymentPage(
          group: widget.group,
          lender: debtInfo['lenderId'],
          lenderName: lenderName,
          borrower: FirebaseAuth.instance.currentUser!.uid,
          amount: (debtInfo['amount'] as num).toDouble(),
          reason: debtInfo['reason'],
        ),
      ),
    );
  },
  child: const Text('Record Repayment'),
),
 
                ],
              ),
            ],
            if (_selectedTag == 2)
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('groups')
                    .doc(widget.group.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  final balances = (snapshot.data!.data() as Map<String, dynamic>?)?['balances'] ?? {};
                  return Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: FutureBuilder<Map<String, String>>(
                        future: _getBalanceSummary(balances, userService),
                        builder: (context, balanceSnapshot) {
                          if (!balanceSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return Text(
                            balanceSnapshot.data!['summary'] ?? 'Balance: Loading...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 16),

            // Content Area
            Expanded(
              child: _selectedTag == 0
                  ? _buildMembersStream(groupProvider)
                  : _buildPageContent(userService, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagButton(String label, int index) {
    final selected = _selectedTag == index;
    return InkWell(
      onTap: () => setState(() => _selectedTag = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.blue[100] : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.blue : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildMembersStream(GroupProvider groupProvider) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final memberIds = (snapshot.data!.data() as Map<String, dynamic>?)?['memberIds'] as List<dynamic>? ?? [];
        final memberIdsStrings = memberIds.map((id) => id.toString()).toList();

        return FutureBuilder<List<String>>(
          future: groupProvider.getMemberNames(memberIdsStrings),
          builder: (context, nameSnapshot) {
            if (!nameSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final memberNames = nameSnapshot.data!;
            return ListView.builder(
              itemCount: memberNames.length,
              itemBuilder: (context, index) {
                final selected = index == _selectedUser;
                return GestureDetector(
                  onTap: () => setState(() => _selectedUser = index),
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.person)),
                      title: Text(memberNames[index]),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildPageContent(UserServiceProvider userService, BuildContext context) {
    switch (_selectedTag) {
      case 1: // Transactions
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('groups')
              .doc(widget.group.id)
              .collection('expenses')
              .orderBy('date', descending: true)
              .snapshots(includeMetadataChanges: true),
          builder: (context, snapshot) {
            // Show cached data if available during loading
            if (snapshot.connectionState == ConnectionState.waiting && 
                !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError && !snapshot.hasData) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            // Handle empty state
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No transactions yet'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final data = doc.data() as Map<String, dynamic>;
                return _buildTransactionTile(data, userService, context);
              },
            );
          },
        );

      case 2: // Overview
        return _buildOverviewContent(userService);
        
      default:
        return const SizedBox();
    }
  }

  Widget _buildOverviewContent(UserServiceProvider userService) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.group.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final balances = (snapshot.data!.data() as Map<String, dynamic>?)?['balances'] ?? {};
        return FutureBuilder<Map<String, String>>(
          future: _getBalanceSummary(balances, userService),
          builder: (context, balanceSnapshot) {
            if (!balanceSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(balanceSnapshot.data!['summary'] ?? 'No balances'),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        balanceSnapshot.data!['detailed'] ?? 'No balance details',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>> _getBalanceSummary(
    Map<String, dynamic> balances,
    UserServiceProvider userService,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final summary = <String, String>{};
    final owes = <String>[];
    final owed = <String>[];
    final balanceMap = <String, double>{};

    for (final entry in balances.entries) {
      final amount = (entry.value as num?)?.toDouble() ?? 0.0;
      if (amount == 0) continue;

      try {
        final name = await userService.getUserFullName(entry.key);
        balanceMap[name] = amount;

        if (entry.key == currentUserId) {
          if (amount > 0) {
            owed.add('You are owed \$${amount.toStringAsFixed(2)}');
          } else if (amount < 0) {
            owes.add('You owe \$${(-amount).toStringAsFixed(2)}');
          }
        }
      } catch (e) {
        debugPrint('Error getting name for ${entry.key}: $e');
      }
    }

    summary['summary'] = [
      if (owes.isNotEmpty) owes.join(', '),
      if (owed.isNotEmpty) owed.join(', '),
    ].join('\n').trim();

    summary['detailed'] = balanceMap.entries
        .map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}')
        .join('\n')
        .ifEmpty('No balance details');

    return summary;
  }

  Widget _buildTransactionTile(Map<String, dynamic> data, UserServiceProvider userService, BuildContext context) {
    final isRepayment = data['type'] == 'repayment';
    final date = (data['date'] as Timestamp).toDate();
    final amount = data['amount'] as num;
    final reason = data['reason'] as String? ?? '';
    final paidById = data['paidById'] as String;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return FutureBuilder<String>(
      future: userService.getUserFullName(paidById),
      builder: (context, paidBySnapshot) {
        if (!paidBySnapshot.hasData) {
          return const ListTile(title: Text('Loading...'));
        }

        final paidByName = paidBySnapshot.data!;
        final formattedDate = DateFormat('MMM dd, yyyy').format(date);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: InkWell(
            onTap: () {
              final shares = data['shares'] as Map<String, dynamic>? ?? {};
              final userShare = (shares[currentUserId ?? ''] as num?)?.toDouble() ?? 0;
              if (userShare > 0) {
                _navigateToRepayment(context, paidById, paidByName, userShare, reason);
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isRepayment 
                            ? '$paidByName repaid \$${amount.toStringAsFixed(2)}'
                            : '$paidByName paid \$${amount.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(formattedDate, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                  if (reason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('For: $reason'),
                  ],
                  if (!isRepayment && data['shares'] != null) ...[
                    const SizedBox(height: 8),
                   FutureBuilder<Map<String, Map<String, dynamic>>>(
  future: _getSharesWithStatus(data['shares'] as Map<String, dynamic>, paidById, userService),
  builder: (context, sharesSnapshot) {
    if (!sharesSnapshot.hasData) {
      return const SizedBox();
    }

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sharesSnapshot.data!.entries.map((entry) {
        final isPaid = entry.value['isPaid'];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            '• ${entry.value['name']} owes \$${entry.value['amount']}',
            style: TextStyle(
              color: (currentUserId == data['paidById'])
                  ? (isPaid ? Colors.green : Colors.red)
                  : (entry.key == currentUserId
                      ? (isPaid ? Colors.green : Colors.red)
                      : (isPaid ? Colors.green : Colors.grey[700])),
              fontWeight: entry.key == currentUserId ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  },
),

                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, Map<String, dynamic>>> _getSharesWithStatus(
  Map<String, dynamic> shares,
  String paidById,
  UserServiceProvider userService,
) async {
  final result = <String, Map<String, dynamic>>{};
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;

  // Get all confirmed repayments for this expense
  final repayments = await FirebaseFirestore.instance
      .collection('groups')
      .doc(widget.group.id)
      .collection('repayments')
      .where('expenseId', isEqualTo: paidById)
      .where('status', isEqualTo: 'confirmed')
      .get();

  for (final entry in shares.entries) {
    if (entry.key == paidById) continue; // Skip the user who paid

    final amount = (entry.value as num).toDouble();
    if (amount > 0) {
      try {
        final name = await userService.getUserFullName(entry.key);
        final totalRepaid = repayments.docs.fold(0.0, (sum, doc) {
          if (doc['borrowerId'] == entry.key) {
            return sum + (doc['amount'] as num).toDouble();
          }
          return sum;
        });

        result[entry.key] = {
          'name': name,
          'amount': amount.toStringAsFixed(2),
          'isPaid': totalRepaid >= amount,
        };
      } catch (e) {
        debugPrint('Error getting name for ${entry.key}: $e');
      }
    }
  }
  return result;
}


  void _navigateToRepayment(
    BuildContext context,
    String lenderId,
    String lenderName,
    double amount,
    String reason,
  ) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecordRepaymentPage(
          group: widget.group,
          lender: lenderId,
          lenderName: lenderName,
          borrower: currentUserId,
          amount: amount,
          reason: reason,
        ),
      ),
    );
  }
Future<Map<String, dynamic>?> _getOwedAmount(BuildContext context) async {
  final currentUserId = FirebaseAuth.instance.currentUser?.uid;
  if (currentUserId == null) return null;

  final snapshot = await FirebaseFirestore.instance
      .collection('groups')
      .doc(widget.group.id)
      .collection('expenses')
      .where('shares.$currentUserId', isGreaterThan: 0)
      .get();

  if (snapshot.docs.isEmpty) return null;

  // For simplicity, let's take the first debt
  final debt = snapshot.docs.first;
  return {
    'lenderId': debt['paidById'],
    'amount': (debt['shares'] as Map<String, dynamic>)[currentUserId],
    'reason': debt['reason'] ?? '',
  };
}
  void _navigateToAddMembers(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMembersPage(group: widget.group),
      ),
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
