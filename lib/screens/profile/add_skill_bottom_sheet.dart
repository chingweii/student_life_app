import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddSkillBottomSheet extends StatefulWidget {
  const AddSkillBottomSheet({super.key});

  @override
  State<AddSkillBottomSheet> createState() => _AddSkillBottomSheetState();
}

class _AddSkillBottomSheetState extends State<AddSkillBottomSheet> {
  // Controllers for text input
  final TextEditingController _skillController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Dropdown values
  String _selectedProficiency = 'Intermediate';
  String _selectedCategory = 'Experience'; // Maps to 'subtitle' in your card

  bool _isLoading = false;

  // List of options for dropdowns
  final List<String> _proficiencyLevels = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Expert',
  ];

  final List<String> _categories = [
    'Experience',
    'Verification',
    'Education',
    'Project',
    'Hobby',
  ];

  Future<void> _saveSkill() async {
    final String skillName = _skillController.text.trim();
    final String description = _descriptionController.text.trim();

    // ... (Keep existing validation checks) ...

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final userDocRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        // 1. Save detailed info to Sub-collection (KEEP THIS)
        await userDocRef.collection('skills').add({
          'title': skillName,
          'subtitle': _selectedCategory,
          'proficiency': _selectedProficiency,
          'description': description,
          'created_at': FieldValue.serverTimestamp(),
        });

        // 2. NEW: Add just the skill name to the main User Document array
        // This allows it to be seen in the Search/Home screen list immediately
        await userDocRef.update({
          'skills': FieldValue.arrayUnion([skillName]),
        });

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Skill added successfully!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error adding skill: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _skillController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Get the keyboard height
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    // 2. Remove FractionallySizedBox. Return Padding directly.
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        // This pushes the sheet up when keyboard opens
        bottom: bottomPadding + 16,
      ),
      // 3. Wrap everything in SingleChildScrollView so it scrolls if screen is small
      child: SingleChildScrollView(
        child: Column(
          // 4. "Auto Fit": Make the column only as tall as its content
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 80,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 25),

            const Center(
              child: Text(
                'Add New Skill',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            // --- FORM FIELDS (No Expanded needed) ---

            // 1. Skill Name
            TextField(
              controller: _skillController,
              decoration: InputDecoration(
                labelText: 'Skill Name*',
                hintText: 'e.g., Python, Public Speaking',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 2. Category Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _categories.map((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedCategory = newValue!);
              },
            ),
            const SizedBox(height: 20),

            // 3. Proficiency Dropdown
            DropdownButtonFormField<String>(
              value: _selectedProficiency,
              decoration: InputDecoration(
                labelText: 'Proficiency Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _proficiencyLevels.map((String level) {
                return DropdownMenuItem<String>(
                  value: level,
                  child: Text(level),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() => _selectedProficiency = newValue!);
              },
            ),
            const SizedBox(height: 20),

            // 4. Description / Certification
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description / Certification',
                hintText:
                    'e.g., PCAP Certified, or "Used in Final Year Project"',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8A84A3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Save', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20), // Little extra padding at bottom
          ],
        ),
      ),
    );
  }
}
