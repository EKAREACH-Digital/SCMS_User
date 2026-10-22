/// A school (tenant) a user belongs to.
class School {
  final String id;
  final String name;

  const School({required this.id, required this.name});

  School copyWith({String? id, String? name}) {
    return School(id: id ?? this.id, name: name ?? this.name);
  }
}
