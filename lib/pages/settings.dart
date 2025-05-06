import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shape_up_app/enums/socialService/gender.dart';
import 'package:shape_up_app/pages/main.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  File? _profileImage;
  final TextEditingController _bioController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;

  final List<String> _genders = ['Masculino', 'Feminino'];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _saveChanges() async{
    Gender? gender;
    String? birthDate;
    String? bio;

    if(_profileImage != null){
      await SocialService.uploadProfilePictureAsync(_profileImage!.path);
    }

    if (_birthDate != null) {
      birthDate = "${_birthDate!.year}-${_birthDate!.month}-${_birthDate!.day}";
    }

    if (_bioController.text.isNotEmpty) {
      bio = _bioController.text;
    }

    if(_selectedGender != null && _selectedGender!.isNotEmpty){
      gender = stringToGenderMap[_selectedGender!];
    }

    await SocialService.editProfileAsync(gender, birthDate, bio);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Alterações salvas com sucesso!")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Configurações",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF191F2B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ProfileImagePicker(
                profileImage: _profileImage,
                onImagePicked: _pickImage,
              ),
              const SizedBox(height: 16),
              BioInputField(controller: _bioController),
              const SizedBox(height: 16),
              BirthDatePicker(
                birthDate: _birthDate,
                onDatePicked: () => _pickBirthDate(context),
              ),
              const SizedBox(height: 16),
              GenderDropdown(
                genders: _genders,
                selectedGender: _selectedGender,
                onGenderChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue;
                  });
                },
              ),
              const SizedBox(height: 16),
              SaveButton(onSave: _saveChanges),
              const SizedBox(height: 16),
              LogoutButton(
                onLogout: () async {
                  await AuthenticationService.signOut();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => Main()),
                        (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileImagePicker extends StatelessWidget {
  final File? profileImage;
  final VoidCallback onImagePicked;

  const ProfileImagePicker({
    super.key,
    required this.profileImage,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onImagePicked,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: profileImage != null
            ? FileImage(profileImage!)
            : const AssetImage('assets/default_profile.png') as ImageProvider,
        child: profileImage == null
            ? const Icon(Icons.camera_alt, size: 50, color: Colors.white)
            : null,
      ),
    );
  }
}

class BioInputField extends StatelessWidget {
  final TextEditingController controller;

  const BioInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelStyle: TextStyle(color: Colors.white),
        labelText: "Bio",
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }
}

class BirthDatePicker extends StatelessWidget {
  final DateTime? birthDate;
  final VoidCallback onDatePicked;

  const BirthDatePicker({
    super.key,
    required this.birthDate,
    required this.onDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            birthDate != null
                ? "Data de Nascimento: ${birthDate!.day}/${birthDate!.month}/${birthDate!.year}"
                : "Selecione sua Data de Nascimento",
            style: TextStyle(color: Colors.white),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          color: Colors.white,
          onPressed: onDatePicked,
        ),
      ],
    );
  }
}

class GenderDropdown extends StatelessWidget {
  final List<String> genders;
  final String? selectedGender;
  final ValueChanged<String?> onGenderChanged;

  const GenderDropdown({
    super.key,
    required this.genders,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selectedGender,
      items: genders.map((String gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: onGenderChanged,
      decoration: const InputDecoration(
        labelText: "Gênero",
        border: OutlineInputBorder(),
      ),
    );
  }
}

class SaveButton extends StatelessWidget {
  final Future<void> Function() onSave;

  const SaveButton({super.key, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        await onSave(); // Aguarda a execução completa de _saveChanges
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
      child: const Text("Salvar Alterações", style: TextStyle(color: Colors.white)),
    );
  }
}

class LogoutButton extends StatelessWidget {
  final VoidCallback onLogout;

  const LogoutButton({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onLogout,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        backgroundColor: Colors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
      ),
      icon: const Icon(Icons.logout, color: Colors.white),
      label: const Text(
        "Logout",
        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}