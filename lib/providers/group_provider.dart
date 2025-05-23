import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loan_tracker/models/group_model.dart';
import 'package:loan_tracker/providers/user_service.dart';

class GroupProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  final UserServiceProvider _userService;
  
  GroupProvider(this._userService) : _firestore = FirebaseFirestore.instance {
    _setupListeners();
  }

  // Current state
  List<Group> _groups = [];
  Group? _selectedGroup;
  List<String> _memberNames = [];
  StreamSubscription? _groupsSubscription;
  StreamSubscription? _membersSubscription;

  // Getters
  List<Group> get groups => _groups;
  Group? get selectedGroup => _selectedGroup;
  List<String> get memberNames => _memberNames;

  // Initialize real-time listeners
  void _setupListeners() {
    _groupsSubscription?.cancel();
    _membersSubscription?.cancel();
  }

  /// Create a new group
  Future<void> createGroup(String groupName, String currentUserId, BuildContext context) async {
    try {
      final docRef = _firestore.collection('groups').doc();
      final newGroup = Group(
        id: docRef.id,
        name: groupName,
        memberIds: [currentUserId],
        createdBy: currentUserId,
      );
      
      await docRef.set(newGroup.toMap());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Group created!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      rethrow;
    }
  }

 Stream<List<Group>> groupsStream(String userId) {
  return _firestore
      .collection('groups')
      .where('memberIds', arrayContains: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Group.fromMap(doc.data()))
          .toList());
}


  /// Set group and initialize member stream
  void setGroup(Group group) {
    _selectedGroup = group;
    _subscribeToMemberUpdates(group.id);
    notifyListeners();
  }

  /// Real-time member updates
  void _subscribeToMemberUpdates(String groupId) {
    _membersSubscription?.cancel();
    _membersSubscription = _firestore
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .listen((doc) async {
          if (doc.exists) {
            final memberIds = List<String>.from(doc.data()?['memberIds'] ?? []);
            _memberNames = await _userService.getMemberNames(memberIds);
            notifyListeners();
          }
        });
  }

  /// Add members with batch write support
  Future<void> addMembers(List<String> newMemberIds) async {
    if (_selectedGroup == null) return;

    final batch = _firestore.batch();
    final groupRef = _firestore.collection('groups').doc(_selectedGroup!.id);
    
    batch.update(groupRef, {
      'memberIds': FieldValue.arrayUnion(newMemberIds),
    });

    try {
      await batch.commit();
      // Listener will automatically update _memberNames
    } catch (e) {
      debugPrint('Failed to add members: $e');
      rethrow;
    }
  }

  /// Optimized member name fetching
  Future<List<String>> getMemberNames(List<String> uids) async {
    if (uids.isEmpty) return [];
    return _userService.getMemberNames(uids);
  }

  @override
  void dispose() {
    _groupsSubscription?.cancel();
    _membersSubscription?.cancel();
    super.dispose();
  }

  Future<void> updateBalancesAfterExpense(
  String groupId, 
  String paidById,
  Map<String, dynamic> shares
) async {
  final batch = _firestore.batch();
  final groupRef = _firestore.collection('groups').doc(groupId);
  
  // Update each member's balance
  for (final entry in shares.entries) {
    final memberId = entry.key;
    final amount = entry.value as double;
    
    if (amount > 0) {
      // For each share, the payer is owed money
      final isPayer = memberId == paidById;
      final amountToUpdate = isPayer ? amount : -amount;
      
      batch.update(groupRef, {
        'balances.$memberId': FieldValue.increment(amountToUpdate),
      });
    }
  }
  
  await batch.commit();
}
}