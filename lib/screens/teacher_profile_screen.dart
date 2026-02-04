import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/supabase_service.dart';
import '../models/teacher.dart';

/// Screen for teachers to manage their profile including profile picture
class TeacherProfileScreen extends StatefulWidget {
  final String teacherInitial;

  const TeacherProfileScreen({
    super.key,
    required this.teacherInitial,
  });

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  Teacher? _currentTeacher;
  bool _isLoading = false;
  File? _selectedImage;
  bool _isEditing = false;
  bool _isChangingPassword = false;

  final _nameController = TextEditingController();
  final _initialController = TextEditingController();
  final _phoneController = TextEditingController();
  final _designationController = TextEditingController();
  final _departmentController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTeacher();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialController.dispose();
    _phoneController.dispose();
    _designationController.dispose();
    _departmentController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadTeacher() async {
    final service = context.read<SupabaseService>();
    setState(() => _isLoading = true);

    try {
      final teachers = await service.getTeachers(forceRefresh: true);
      final teacher = teachers.firstWhere(
        (t) => t.initial == widget.teacherInitial,
        orElse: () => throw Exception('Teacher not found'),
      );

      setState(() {
        _currentTeacher = teacher;
        _nameController.text = teacher.name;
        _initialController.text = teacher.initial;
        _phoneController.text = teacher.phone;
        _designationController.text = teacher.designation;
        _departmentController.text = teacher.homeDepartment;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading teacher: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetEditFields() {
    if (_currentTeacher == null) return;
    _nameController.text = _currentTeacher!.name;
    _initialController.text = _currentTeacher!.initial;
    _phoneController.text = _currentTeacher!.phone;
    _designationController.text = _currentTeacher!.designation;
    _departmentController.text = _currentTeacher!.homeDepartment;
  }

  Future<void> _saveProfileEdits() async {
    if (_currentTeacher == null) return;

    final name = _nameController.text.trim();
    final initial = _initialController.text.trim();
    final phone = _phoneController.text.trim();
    final designation = _designationController.text.trim();
    final department = _departmentController.text.trim();

    if (name.isEmpty || initial.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and Initial are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = context.read<SupabaseService>();
      final updated = Teacher(
        id: _currentTeacher!.id,
        name: name,
        initial: initial,
        designation: designation,
        phone: phone,
        email: _currentTeacher!.email,
        homeDepartment: department,
        profilePic: _currentTeacher!.profilePic,
      );

      final success = await service.updateTeacher(_currentTeacher!.id, updated);
      if (success && context.mounted) {
        await _loadTeacher();
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() => _selectedImage = File(image.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _uploadProfilePic() async {
    if (_currentTeacher == null || _selectedImage == null) return;

    setState(() => _isLoading = true);

    try {
      final service = context.read<SupabaseService>();

      // Delete old profile pic if exists
      if (_currentTeacher!.profilePic != null && _currentTeacher!.profilePic!.isNotEmpty) {
        await service.deleteTeacherProfilePic(_currentTeacher!.profilePic!);
      }

      // Upload new image
      final publicUrl = await service.uploadTeacherProfilePic(
        _currentTeacher!.initial,
        _selectedImage!.path,
      );

      // Update database
      final success = await service.updateTeacherProfilePic(
        _currentTeacher!.initial,
        publicUrl,
      );

      if (success && context.mounted) {
        // Reload teacher data
        await _loadTeacher();
        setState(() => _selectedImage = null);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _removeProfilePic() async {
    if (_currentTeacher == null || _currentTeacher!.profilePic == null) return;

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Profile Picture'),
        content: const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    setState(() => _isLoading = true);

    try {
      final service = context.read<SupabaseService>();

      // Delete from storage
      await service.deleteTeacherProfilePic(_currentTeacher!.profilePic!);

      // Update database to null
      final success = await service.updateTeacherProfilePic(
        _currentTeacher!.initial,
        null,
      );

      if (success && context.mounted) {
        await _loadTeacher();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture removed successfully!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing image: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _changePassword() async {
    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill all fields', isError: true);
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('New passwords do not match', isError: true);
      return;
    }

    if (newPassword.length < 6) {
      _showMessage('Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final service = context.read<SupabaseService>();
    
    if (_currentTeacher == null) {
      _showMessage('Teacher data not loaded', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // Verify current password
    final verifiedTeacher = await service.authenticateTeacherByEmail(
      _currentTeacher!.email,
      currentPassword,
    );
    
    if (verifiedTeacher == null) {
      _showMessage('Current password is incorrect', isError: true);
      setState(() => _isLoading = false);
      return;
    }

    // Update password in database
    try {
      await service.updateTeacherPassword(_currentTeacher!.id, newPassword);
      
      _showMessage('Password updated successfully');
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
      setState(() => _isChangingPassword = false);
    } catch (e) {
      _showMessage('Failed to update password: $e', isError: true);
    }

    setState(() => _isLoading = false);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E1E),
        elevation: 0,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_currentTeacher != null)
            if (!_isEditing)
              IconButton(
                onPressed: () {
                  setState(() => _isEditing = true);
                },
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Profile',
              )
            else ...[
              IconButton(
                onPressed: _saveProfileEdits,
                icon: const Icon(Icons.save),
                tooltip: 'Save',
              ),
              IconButton(
                onPressed: () {
                  _resetEditFields();
                  setState(() => _isEditing = false);
                },
                icon: const Icon(Icons.close),
                tooltip: 'Cancel',
              ),
            ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentTeacher == null
              ? const Center(child: Text('Teacher not found'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Profile Picture Section
                        Center(
                          child: Column(
                            children: [
                              // Current or Selected Image
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF2A2A2A),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary,
                                    width: 3,
                                  ),
                                ),
                                child: ClipOval(
                                  child: _selectedImage != null
                                      ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : _currentTeacher!.profilePic != null &&
                                              _currentTeacher!.profilePic!.isNotEmpty
                                          ? Image.network(
                                              _currentTeacher!.profilePic!,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) {
                                                return _buildInitialAvatar();
                                              },
                                            )
                                          : _buildInitialAvatar(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Action buttons
                              Wrap(
                                spacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _pickImage,
                                    icon: const Icon(Icons.add_photo_alternate),
                                    label: const Text('Choose Photo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  if (_selectedImage != null)
                                    ElevatedButton.icon(
                                      onPressed: _uploadProfilePic,
                                      icon: const Icon(Icons.upload),
                                      label: const Text('Upload'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                  if (_currentTeacher!.profilePic != null &&
                                      _currentTeacher!.profilePic!.isNotEmpty)
                                    ElevatedButton.icon(
                                      onPressed: _removeProfilePic,
                                      icon: const Icon(Icons.delete),
                                      label: const Text('Remove'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              
                              // Help text
                              Text(
                                'Select an image from your device gallery.\nThe image will be uploaded to secure cloud storage.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Teacher Information Card
                        Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Teacher Information',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (_isEditing)
                                      Text(
                                        'Editing',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.orangeAccent,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _isEditing
                                      ? 'Update your details and save'
                                      : 'Read-only information managed by administration',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const Divider(height: 32, color: Colors.grey),
                                _isEditing
                                    ? _buildEditableField('Name', _nameController)
                                    : _buildInfoRow('Name', _currentTeacher!.name),
                                _isEditing
                                    ? _buildEditableField('Initial', _initialController)
                                    : _buildInfoRow('Initial', _currentTeacher!.initial),
                                _buildInfoRow('Email', _currentTeacher!.email),
                                _isEditing
                                    ? _buildEditableField('Phone', _phoneController)
                                    : _buildInfoRow('Phone', _currentTeacher!.phone),
                                _isEditing
                                    ? _buildEditableField('Designation', _designationController)
                                    : _buildInfoRow('Designation', _currentTeacher!.designation),
                                _isEditing
                                    ? _buildEditableField('Department', _departmentController)
                                    : _buildInfoRow('Department', _currentTeacher!.homeDepartment),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Change Password Section
                        Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Security',
                                      style: GoogleFonts.poppins(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    if (!_isChangingPassword)
                                      TextButton.icon(
                                        onPressed: () => setState(() => _isChangingPassword = true),
                                        icon: const Icon(Icons.lock),
                                        label: const Text('Change Password'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: Colors.blue[400],
                                        ),
                                      ),
                                  ],
                                ),
                                const Divider(height: 24, color: Colors.grey),
                                if (_isChangingPassword) ...[
                                  TextField(
                                    controller: _currentPasswordController,
                                    style: GoogleFonts.poppins(color: Colors.white),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Current Password',
                                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                      filled: true,
                                      fillColor: const Color(0xFF2A2A2A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _newPasswordController,
                                    style: GoogleFonts.poppins(color: Colors.white),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'New Password',
                                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                      filled: true,
                                      fillColor: const Color(0xFF2A2A2A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _confirmPasswordController,
                                    style: GoogleFonts.poppins(color: Colors.white),
                                    obscureText: true,
                                    decoration: InputDecoration(
                                      labelText: 'Confirm Password',
                                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                                      prefixIcon: Icon(Icons.lock, color: Colors.grey[600]),
                                      filled: true,
                                      fillColor: const Color(0xFF2A2A2A),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _isLoading ? null : _changePassword,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF5B7CFF),
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                  ),
                                                )
                                              : const Text('Update Password'),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            setState(() => _isChangingPassword = false);
                                            _currentPasswordController.clear();
                                            _newPasswordController.clear();
                                            _confirmPasswordController.clear();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ] else
                                  Text(
                                    'Keep your password secure. Change it regularly.',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildInitialAvatar() {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Center(
        child: Text(
          _currentTeacher!.initial,
          style: GoogleFonts.poppins(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        style: GoogleFonts.poppins(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[400]),
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
