import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _degreeController = TextEditingController();
  final _locationController = TextEditingController();

  // State variables
  String? _selectedGender;
  String? _currentImageUrl; // To show existing image from DB
  File? _newImageFile; // To show new image picked from gallery
  bool _isLoading = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // 1. Fetch existing data
  Future<void> _loadUserData() async {
    if (currentUser == null) return;

    setState(() => _isLoading = true);

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _degreeController.text = data['degree'] ?? '';
        _locationController.text = data['location'] ?? '';

        String dbGender = data['gender'] ?? '';
        if (['Male', 'Female', 'Other'].contains(dbGender)) {
          _selectedGender = dbGender;
        }

        setState(() {
          _currentImageUrl = data['profile_pic_url'];
        });
      }
    } catch (e) {
      print("Error loading profile: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 2. LOGIC: Pick Image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _newImageFile = File(image.path);
      });
    }
  }

  // 3. LOGIC: Remove Image (New)
  void _removeImage() {
    setState(() {
      _newImageFile = null; // Clear local pick
      _currentImageUrl = null; // Clear existing URL reference
    });
  }

  // 4. UI: Show Options Dialog (New)
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8), // Small spacing at the very top
              // Option 1: Choose from Gallery
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ), // Standard height
                  alignment: Alignment.center,
                  child: const Text(
                    'Choose from Gallery',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              // The Divider: Thinner and Transparent
              Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.withOpacity(0.2), // Very faint line
              ),

              // Option 2: Remove Photo (Shorter Height)
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _removeImage();
                },
                child: Container(
                  width: double.infinity,
                  // Padding reduced to 12.0 to make this button shorter
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  alignment: Alignment.center,
                  child: const Text(
                    'Remove Current Photo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 8), // Bottom spacing
            ],
          ),
        );
      },
    );
  }

  // 5. Save Logic
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String uid = currentUser!.uid;
      String? finalImageUrl = _currentImageUrl;

      // A. Upload New Image (if selected)
      if (_newImageFile != null) {
        // 1. Generate a UNIQUE filename using timestamp
        // This forces the app to see it as a "new" image and update everywhere
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String fileName = '${uid}_$timestamp.jpg';

        final ref = FirebaseStorage.instance
            .ref()
            .child('profile_images')
            .child(fileName);

        // 2. Upload
        await ref.putFile(_newImageFile!);

        // 3. Get the new Download URL
        finalImageUrl = await ref.getDownloadURL();
      }

      // B. Update Firestore
      // Because your other screens use StreamBuilder, updating this URL
      // will cause all those screens to automatically rebuild with the new picture.
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'degree': _degreeController.text.trim(),
        'location': _locationController.text.trim(),
        'gender': _selectedGender ?? 'Other',
        'profile_pic_url': finalImageUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print(e); // Print error to console for debugging
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading && _firstNameController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- PROFILE PICTURE SECTION ---
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _getProfileImage(),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap:
                                  _showImageOptions, // UPDATED: Calls the popup
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8A84A3),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // --- FORM FIELDS ---
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            "First Name",
                            _firstNameController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            "Last Name",
                            _lastNameController,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      "Degree / Course",
                      _degreeController,
                      hint: "e.g. Bachelor of Computer Science",
                      isRequired: false,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      "Location",
                      _locationController,
                      hint: "e.g. Selangor, Malaysia",
                      isRequired: false,
                    ),
                    const SizedBox(height: 16),

                    // Gender Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: InputDecoration(
                        labelText: 'Gender',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: ['Male', 'Female', 'Other'].map((String val) {
                        return DropdownMenuItem(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedGender = val),
                    ),

                    const SizedBox(height: 40),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8A84A3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Save Changes",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper to determine which image to show
  ImageProvider _getProfileImage() {
    if (_newImageFile != null) {
      return FileImage(_newImageFile!); // Show local file if picked
    }
    if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
      return NetworkImage(_currentImageUrl!); // Show Firebase URL if exists
    }
    return const AssetImage(
      'assets/images/user_avatar.png',
    ); // Default fallback
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? hint,
    bool isRequired = true, // NEW: Add this parameter, default to true
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      // NEW: Only validate if isRequired is true
      validator: (val) {
        if (isRequired && (val == null || val.isEmpty)) {
          return 'Required';
        }
        return null;
      },
    );
  }
}
