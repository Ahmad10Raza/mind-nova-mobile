import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../auth/services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../../core/network/api_client.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  final UserProfile profile;

  const EditProfileSheet({super.key, required this.profile});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  String? _selectedAgeRange;
  String? _selectedGender;
  late Set<String> _selectedGoals;

  XFile? _pickedImage;
  Uint8List? _pickedImageBytes;
  bool _isLoading = false;

  final List<String> _ageRanges = [
    '13–17', '18–24', '25–34', '35–44', '45–54', '55–64', '65+',
  ];

  final List<String> _genderOptions = [
    'Male', 'Female', 'Non-binary', 'Prefer not to say',
  ];

  final List<String> _goalOptions = [
    'Reduce Anxiety', 'Manage Stress', 'Improve Sleep', 'Boost Mood',
    'Build Resilience', 'Focus & Productivity', 'Manage Depression', 'Self-Discovery',
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.profile.firstName);
    _lastNameController = TextEditingController(text: widget.profile.lastName);
    _weightController = TextEditingController(text: widget.profile.weight?.toString() ?? '');
    _heightController = TextEditingController(text: widget.profile.height?.toString() ?? '');
    _selectedAgeRange = widget.profile.ageRange;
    _selectedGender = widget.profile.gender;
    _selectedGoals = Set.from(widget.profile.goals);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _pickedImage = image;
        _pickedImageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    final authStatus = ref.read(authProvider).status;
    final isGuest = authStatus == AuthStatus.anonymous;
    
    // 1. Upload Avatar if picked
    String? newAvatarUrl;
    if (_pickedImage != null && _pickedImageBytes != null && !isGuest) {
      newAvatarUrl = await ref.read(profileServiceProvider).uploadAvatar(
        _pickedImageBytes!,
        _pickedImage!.name,
      );
    }

    // 2. Update Profile Info
    bool success = false;
    if (isGuest) {
      await ref.read(authProvider.notifier).updateGuestProfile(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        ageRange: _selectedAgeRange,
        gender: _selectedGender,
        goals: _selectedGoals.toList(),
        weight: double.tryParse(_weightController.text),
        height: double.tryParse(_heightController.text),
      );
      success = true;
    } else {
      success = await ref.read(profileServiceProvider).updateProfile(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            ageRange: _selectedAgeRange,
            gender: _selectedGender,
            goals: _selectedGoals.toList(),
            weight: double.tryParse(_weightController.text),
            height: double.tryParse(_heightController.text),
            avatarUrl: newAvatarUrl,
          );
    }

    if (mounted) {
      if (success) {
        final fullName = '${_firstNameController.text} ${_lastNameController.text}'.trim();
        if (fullName.isNotEmpty) {
          await ref.read(authProvider.notifier).updateDisplayName(fullName);
        }
        
        if (newAvatarUrl != null) {
          await ref.read(authProvider.notifier).updateUserAvatar(newAvatarUrl);
        }
        
        ref.invalidate(userProfileProvider);
        if (mounted) setState(() => _isLoading = false);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Personal Identity', style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w700)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
              ],
            ),
            const Divider(height: 1),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // --- Photo Upload Section ---
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF2F2F7),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: const Color(0xFF5E4B8B).withOpacity(0.1), width: 2),
                                  ),
                                  child: ClipOval(
                                    child: _pickedImage != null
                                      ? (kIsWeb 
                                          ? Image.network(
                                              _pickedImage!.path, 
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(
                                                child: Text(
                                                  _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : 'U',
                                                  style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w700, color: const Color(0xFF5E4B8B)),
                                                ),
                                              ),
                                            ) 
                                          : Image.file(
                                              File(_pickedImage!.path), 
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => Center(
                                                child: Text(
                                                  _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : 'U',
                                                  style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w700, color: const Color(0xFF5E4B8B)),
                                                ),
                                              ),
                                            )
                                        )
                                      : ref.watch(authProvider).avatarUrl != null && ref.watch(authProvider).avatarUrl!.isNotEmpty
                                        ? Image.network(
                                            ref.watch(authProvider).avatarUrl!.startsWith('http') 
                                              ? ref.watch(authProvider).avatarUrl! 
                                              : '${ref.read(apiClientProvider).baseUrl}${ref.watch(authProvider).avatarUrl!.startsWith('/') ? '' : '/'}${ref.watch(authProvider).avatarUrl!}',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Center(
                                              child: Text(
                                                _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : 'U',
                                                style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w700, color: const Color(0xFF5E4B8B)),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              _firstNameController.text.isNotEmpty ? _firstNameController.text[0].toUpperCase() : 'U',
                                              style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.w700, color: const Color(0xFF5E4B8B)),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: const BoxDecoration(color: Color(0xFF5E4B8B), shape: BoxShape.circle),
                                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: _pickImage,
                            child: Text('Change Profile Photo', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF5E4B8B))),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildSectionTitle('Basics'),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('First Name', _firstNameController)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Last Name', _lastNameController)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildDropdown('Age Range', _selectedAgeRange, _ageRanges, (v) => setState(() => _selectedAgeRange = v)),
                    const SizedBox(height: 24),
                    _buildDropdown('Gender', _selectedGender, _genderOptions, (v) => setState(() => _selectedGender = v)),
                    
                    const SizedBox(height: 32),
                    _buildSectionTitle('Biometrics'),
                    Row(
                      children: [
                        Expanded(child: _buildTextField('Weight (kg)', _weightController, isNumber: true)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildTextField('Height (cm)', _heightController, isNumber: true)),
                      ],
                    ),

                    const SizedBox(height: 32),
                    _buildSectionTitle('Focus Areas'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _goalOptions.map((goal) {
                        final isSelected = _selectedGoals.contains(goal);
                        return FilterChip(
                          label: Text(goal),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) _selectedGoals.add(goal);
                              else _selectedGoals.remove(goal);
                            });
                          },
                          selectedColor: const Color(0xFF5E4B8B).withOpacity(0.1),
                          checkmarkColor: const Color(0xFF5E4B8B),
                          labelStyle: GoogleFonts.inter(
                            fontSize: 12,
                            color: isSelected ? const Color(0xFF5E4B8B) : const Color(0xFF1C1C1E),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1C1E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Save Identity Changes', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1C1C1E)),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF8E8E93))),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF2F2F7),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF8E8E93))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16)),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              items: options.map((o) => DropdownMenuItem(value: o, child: Text(o, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500)))).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
