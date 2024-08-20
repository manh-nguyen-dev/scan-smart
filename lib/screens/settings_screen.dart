import 'package:flutter/material.dart';
import 'package:scan_smart/widgets/gender_choice_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.onUsernameChanged});
  final void Function(String) onUsernameChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _usernameController;
  String _selectedGender = 'other';
  bool _isSaveHistoryEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _usernameController.text = prefs.getString('username') ?? 'Username';
      _selectedGender = prefs.getString('gender') ?? 'other';
      _isSaveHistoryEnabled = prefs.getBool('save_history') ?? false;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('gender', _selectedGender);
    await prefs.setBool(
      'save_history',
      _isSaveHistoryEnabled,
    );
    widget.onUsernameChanged(_usernameController.text);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
      _saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SwitchListTile(
                    activeColor: Colors.blue,
                    title: const Text('Save history'),
                    value: _isSaveHistoryEnabled,
                    onChanged: (bool value) {
                      setState(() {
                        _isSaveHistoryEnabled = value;
                      });
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Username'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Enter your username"
                    ),
                    onChanged: (value) {
                      _saveSettings();
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text('Select Gender'),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GenderChoiceWidget(
                        icon: Icons.male,
                        isSelected: _selectedGender == 'male',
                        onTap: () => _selectGender('male'),
                      ),
                      const SizedBox(width: 8),
                      GenderChoiceWidget(
                        icon: Icons.female,
                        isSelected: _selectedGender == 'female',
                        onTap: () => _selectGender('female'),
                      ),
                      const SizedBox(width: 8),
                      GenderChoiceWidget(
                        icon: Icons.transgender,
                        isSelected: _selectedGender == 'other',
                        onTap: () => _selectGender('other'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
