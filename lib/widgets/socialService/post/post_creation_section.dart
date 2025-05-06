import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shape_up_app/enums/socialService/post_visibility.dart';
import 'package:shape_up_app/services/social_service.dart';

class PostCreationSection extends StatefulWidget {
  String profileImage;

  PostCreationSection({required this.profileImage, super.key});

  @override
  _PostCreationSectionState createState() => _PostCreationSectionState();
}

class _PostCreationSectionState extends State<PostCreationSection> {
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isExpanded = false;
  List<String> _selectedImages = [];
  String _selectedVisibility = "Público";

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isExpanded = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile>? images = await picker.pickMultiImage();
      if (images != null) {
        setState(() {
          _selectedImages = images.map((image) => image.path).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagens: $e')),
      );
    }
  }

  Future<void> _createPost() async {
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, insira uma descrição.')),
      );
      return;
    }

    try {

      var post = await SocialService.createPostAsync(_descriptionController.text, stringToVisibilityMap[_selectedVisibility]!);

      if (_selectedImages.isNotEmpty) {
        await SocialService.uploadFilesAsync(post.id, _selectedImages);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post criado com sucesso!')),
      );

      setState(() {
        _descriptionController.clear();
        _selectedImages = [];
        _isExpanded = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao criar post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final layerLink = LayerLink();

    return Stack(
      children: [
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
                setState(() {
                  _isExpanded = false;
                });
              },
              behavior: HitTestBehavior.opaque,
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          height: _isExpanded ? 250.0 : 60.0,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF191F2B),
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: _isExpanded ? Colors.transparent : Colors.grey,
              width: 1.0,
            ),
          ),
          child: FocusScope(
            onFocusChange: (hasFocus) {
              if (!hasFocus) {
                setState(() {
                  _isExpanded = false;
                });
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!_isExpanded)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = true;
                        _focusNode.requestFocus();
                      });
                    },
                    child: const Text(
                      "O que está em sua mente?",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                widget.profileImage),
                            radius: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _descriptionController,
                              focusNode: _focusNode,
                              maxLines: 1,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'No que você está pensando?',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _selectImages,
                            icon: const Icon(Icons.image, color: Colors.white, size: 18),
                            label: const Text('Imagem', style: TextStyle(fontSize: 14)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white24,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              elevation: 0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          CompositedTransformTarget(
                            link: layerLink,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedVisibility,
                                dropdownColor: const Color(0xFF191F2B),
                                style: const TextStyle(color: Colors.white),
                                items: <String>["Público", "Amigos", "Privado"]
                                    .map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedVisibility = newValue!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_selectedImages.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          children: _selectedImages
                              .map((image) => Chip(
                            label: Text(image),
                            onDeleted: () {
                              setState(() {
                                _selectedImages.remove(image);
                              });
                            },
                          ))
                              .toList(),
                        ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _createPost,
                          child: const Text('Publicar', style: TextStyle(fontSize: 14)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}