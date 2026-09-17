import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../data/exceptions/api_exception.dart';
import '../../../data/repositories/auth/auth_repository.dart';
import '../../../model/user/user.dart';
import '../../../theme/app_theme.dart';
import '../../../ui/states/user_profile_state.dart';
import '../../widgets/settings_widgets.dart';
import '../../widgets/smart_canteen_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  static const routeName = '/edit-profile';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  File? _photo;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<UserProfileState>();
    _nameController = TextEditingController(text: user.name);
    _emailController = TextEditingController(text: user.email);
    _photo = user.photo;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (picked != null && mounted) {
      setState(() => _photo = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: ctx.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              _SheetOption(
                icon: Icons.camera_alt_rounded,
                label: 'Take Photo',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 10),
              _SheetOption(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_photo != null) ...[
                const SizedBox(height: 10),
                _SheetOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Remove Photo',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _photo = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_saving || !_formKey.currentState!.validate()) return;

    final profileState = context.read<UserProfileState>();
    final userId = profileState.userId;
    if (userId == null) {
      // No backend id yet (profile never loaded) — can't PATCH.
      _showSnack('Profile not loaded yet. Please try again.', isError: true);
      return;
    }

    final authRepo = context.read<AuthRepository>();
    final navigator = Navigator.of(context);

    // The backend stores name as first/last, so split the single "Full Name"
    // field the same way onboarding does.
    final fullName = _nameController.text.trim();
    final parts = fullName.split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : null;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;

    HapticFeedback.mediumImpact();
    setState(() => _saving = true);

    try {
      final dto = await authRepo.updateProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
      );
      if (!mounted) return;
      // Reflect the saved name (and photo, which stays device-local since the
      // backend has no image upload) so the header updates immediately.
      final saved = User.fromDto(dto);
      profileState.setFromUser(
        id: saved.id,
        name: saved.fullName,
        email: saved.email,
        schoolName: saved.schoolName,
      );
      profileState.setPhoto(_photo);
      navigator.pop();
      _showSnack('Profile updated');
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showSnack(
        e is ApiException
            ? e.message
            : 'Could not update profile. Please try again.',
        isError: true,
      );
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFE53935) : AppTheme.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.bgColor,
      body: Column(
        children: [
          const SettingsHeader(title: 'Edit Profile'),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                children: [
                  SettingsFadeIn(
                    index: 0,
                    child: Center(
                      child: _AvatarPicker(
                        photo: _photo,
                        initials: context.read<UserProfileState>().initials,
                        onTap: _showImageSourceSheet,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SettingsFadeIn(
                    index: 1,
                    child: _LabeledField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      hint: 'Enter your name',
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Name cannot be empty'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SettingsFadeIn(
                    index: 2,
                    child: _LabeledField(
                      label: 'Email',
                      controller: _emailController,
                      icon: Icons.mail_outline_rounded,
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      readOnly: true,
                      helper:
                          'Email is linked to your account and can’t be changed here.',
                    ),
                  ),
                  const SizedBox(height: 36),
                  SettingsFadeIn(
                    index: 3,
                    child: SmartCanteenButton(
                      label: _saving ? 'Saving…' : 'Save Changes',
                      gradient: const LinearGradient(
                        colors: [AppTheme.greenDark, AppTheme.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      leading: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      onPressed: _saving ? null : _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  const _AvatarPicker({
    required this.photo,
    required this.initials,
    required this.onTap,
  });

  final File? photo;
  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.green.withValues(alpha: 0.12),
              border: Border.all(
                color: AppTheme.green.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: photo != null
                  ? Image.file(
                      photo!,
                      fit: BoxFit.cover,
                      width: 104,
                      height: 104,
                    )
                  : Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.green,
                        ),
                      ),
                    ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.green,
                shape: BoxShape.circle,
                border: Border.all(color: context.bgColor, width: 2.5),
              ),
              child: const Icon(
                Icons.edit_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.keyboardType,
    this.validator,
    this.readOnly = false,
    this.helper,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool readOnly;
  final String? helper;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.green,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: readOnly ? context.mutedColor : context.textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: context.mutedColor, size: 20),
            filled: readOnly,
            fillColor: readOnly ? context.surfaceColor : null,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: context.mutedColor,
            ),
          ),
        ],
      ],
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFE53935) : AppTheme.green;
    final bgColor = isDestructive
        ? const Color(0xFFFFEBEE)
        : context.surfaceColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
