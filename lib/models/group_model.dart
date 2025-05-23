class Group {
  String id;
  String name;
  List<String> memberIds;
  String createdBy;

  Group({
    required this.id,
    required this.name,
    required this.memberIds,
    required this.createdBy,
  });


 Group copyWith({
    String? id,
    String? name,
    List<String>? memberIds,
    String? createdBy,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      memberIds: memberIds ?? this.memberIds,
      createdBy: createdBy ?? this.createdBy,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'memberIds': memberIds,
      'createdBy':createdBy
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      memberIds: List<String>.from(map['memberIds']),
      createdBy:map['createdBy']
    );
  }
}
