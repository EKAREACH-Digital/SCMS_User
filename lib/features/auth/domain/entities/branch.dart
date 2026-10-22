/// A pickup branch (campus canteen) of a school. The student's home branch
/// decides which menu they see.
class Branch {
  final String id;
  final String name;
  final String schoolId;

  /// True for the branch saved as the student's `home_branch_id`.
  final bool isHome;

  const Branch({
    required this.id,
    required this.name,
    required this.schoolId,
    this.isHome = false,
  });

  Branch copyWith({String? id, String? name, String? schoolId, bool? isHome}) {
    return Branch(
      id: id ?? this.id,
      name: name ?? this.name,
      schoolId: schoolId ?? this.schoolId,
      isHome: isHome ?? this.isHome,
    );
  }
}
