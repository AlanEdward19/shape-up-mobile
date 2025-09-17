import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shape_up_app/dtos/socialService/profile_dto.dart';
import 'package:shape_up_app/enums/socialService/gender.dart';
import 'package:shape_up_app/pages/main.dart';
import 'package:shape_up_app/services/authentication_service.dart';
import 'package:shape_up_app/services/social_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key, required this.profile});
  final ProfileDto profile;

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  static const Color _bg = Color(0xFF101827); // fundo original
  static const Color _card = Color(0xFF101827);
  static const Color _text = Colors.white;
  static const Color _muted = Colors.white70;
  static const Color _primary = Colors.blue;
  static const Color _danger = Colors.red;
  static const Color _field = Color(0xFF0C131F);
  static const Color _border = Color(0xFF2A3446);

  final _formKey = GlobalKey<FormState>();

  File? _profileImage;
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  DateTime? _birthDate;
  String? _selectedGender;
  bool _saving = false;

  final List<String> _genders = const [
    'Masculino',
    'Feminino'
  ];

  @override
  void initState() {
    super.initState();

    _bioController.text = widget.profile.bio;

    if (widget.profile.birthDate.isNotEmpty) {
      try {
        _birthDate = DateTime.parse(widget.profile.birthDate);
        _birthdayController.text =
        "${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}";
      } catch (e) {
        // Caso a data de nascimento não seja válida, ignore
      }
    }

    _selectedGender = genderToString[widget.profile.gender];
  }

  InputDecoration _fieldDecoration(String label,
      {String? hint, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(color: _muted, fontSize: 14),
      hintStyle: const TextStyle(color: _muted),
      filled: true,
      fillColor: _field,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _border, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: _primary, width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      suffixIcon: suffixIcon,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (!mounted) return;
    if (pickedFile != null) {
      setState(() => _profileImage = File(pickedFile.path));
    }
  }

  Future<void> _pickBirthDate(BuildContext context) async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _primary,
              surface: _card,
              onSurface: _text,
            ),
            dialogBackgroundColor: _card,
          ),
          child: child!,
        );
      },
    );

    if (!mounted) return;
    if (picked != null) {
      setState(() {
        _birthDate = picked;
        _birthdayController.text =
        "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year.toString()}";
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      Gender? gender;
      String? birthDate;
      String? bio;

      if (_profileImage != null) {
        await SocialService.uploadProfilePictureAsync(_profileImage!.path);
      }

      if (_birthDate != null) {
        final y = _birthDate!.year.toString().padLeft(4, '0');
        final m = _birthDate!.month.toString().padLeft(2, '0');
        final d = _birthDate!.day.toString().padLeft(2, '0');
        birthDate = "$y-$m-$d";
      }

      if (_bioController.text.trim().isNotEmpty) {
        bio = _bioController.text.trim();
      }

      if (_selectedGender != null && _selectedGender!.isNotEmpty) {
        final mapped = stringToGenderMap[_selectedGender!];
        print(mapped);
        if (mapped != null) gender = mapped;
      }

      await SocialService.editProfileAsync(gender, birthDate, bio);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Alterações salvas com sucesso!")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao salvar: $e")),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg, // mantém o fundo original
      appBar: AppBar(
        title: const Text(
          "Configurações",
          style: TextStyle(color: _text, fontWeight: FontWeight.w600),
        ),
        backgroundColor: _bg,
        iconTheme: const IconThemeData(color: _text),
        elevation: 0,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _AvatarPicker(
                    imageFile: _profileImage,
                    profileImageUrl: widget.profile.imageUrl,
                    onTap: _pickImage,
                  ),
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _bioController,
                    minLines: 3,
                    maxLines: 6,
                    style: const TextStyle(color: _text),
                    decoration: _fieldDecoration(
                        "Bio", hint: "Escreva algo sobre você..."),
                  ),
                  const SizedBox(height: 26),

                  TextFormField(
                    controller: _birthdayController,
                    readOnly: true,
                    style: const TextStyle(color: _text),
                    onTap: () => _pickBirthDate(context),
                    decoration: _fieldDecoration(
                      "Data de Nascimento",
                      hint: "dd/mm/aaaa",
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today, color: _text),
                        onPressed: () => _pickBirthDate(context),
                      ),
                    ),
                    cursorColor: _text,
                  ),
                  const SizedBox(height: 26),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child:
                        Text("Selecione...", style: TextStyle(color: _text)),
                      ),
                      ..._genders.map(
                            (g) => DropdownMenuItem<String>(
                          value: g,
                          child: Text(g, style: const TextStyle(color: _text)),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedGender = v),
                    dropdownColor: _card,
                    style: const TextStyle(color: _text),
                    iconEnabledColor: _text,
                    decoration: _fieldDecoration("Gênero"),
                  ),

                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _saving ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _saving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                        : const Text("Salvar Alterações",
                        style: TextStyle(color: _text)),
                  ),
                  const SizedBox(height: 12),

                  ElevatedButton.icon(
                    onPressed: () async {
                      await AuthenticationService.signOut();
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => Main()),
                            (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text("Logout",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _danger,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPicker extends StatelessWidget {
  final File? imageFile;
  final VoidCallback onTap;
  final String? profileImageUrl;

  const _AvatarPicker({
    required this.imageFile,
    required this.onTap,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 96;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: const Color(0xFFD9E1F6),
            backgroundImage: imageFile != null
                ? FileImage(imageFile!)
                : (profileImageUrl != null && profileImageUrl!.isNotEmpty
                ? NetworkImage(profileImageUrl!)
                : null),
            child: imageFile == null && (profileImageUrl == null || profileImageUrl!.isEmpty)
                ? const Icon(Icons.person, size: 40, color: Colors.black54)
                : null,
          ),
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.25),
              border: Border.all(color: const Color(0xFF2A3446)),
            ),
          ),
          const Icon(Icons.photo_camera_outlined,
              color: Colors.white, size: 28),
        ],
      ),
    );
  }
}
