enum UserRole { admin, manager, staff }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String businessName;
  final String businessId;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.businessName,
    required this.businessId,
  });
}

