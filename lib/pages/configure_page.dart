import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../services/agent_service.dart';

class ConfigureEditPage extends StatefulWidget {
  final String agentId;

  ConfigureEditPage({required this.agentId});

  @override
  _ConfigureEditPageState createState() => _ConfigureEditPageState();
}

class _ConfigureEditPageState extends State<ConfigureEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _displayNameController;
  String? _selectedType;
  String? _uploadedImageUrl;
  File? _avatarImage;
  Color _primaryColor = CupertinoColors.activeBlue;
  Color _secondaryColor = CupertinoColors.systemBlue;
  Color _tertiaryColor = CupertinoColors.black;


  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _displayNameController = TextEditingController();
    _loadAgentData();
  }

  void _loadAgentData() async {
    try {
      final agent = await AgentProvider().getAgentById(widget.agentId);
      setState(() {
        _nameController.text = agent.name!;
        _descriptionController.text = agent.description!;
        _displayNameController.text = agent.agentConfigs!.displayName??'';
        _selectedType = agent.type;
        _uploadedImageUrl = agent.agentConfigs?.image!;
        _primaryColor = _getColorFromHex(agent.agentConfigs?.colors!['primary'] ?? '#19427d');
        _secondaryColor = _getColorFromHex(agent.agentConfigs?.colors!['secondary'] ?? '#FFFFFF');
        _tertiaryColor = _getColorFromHex(agent.agentConfigs?.colors!['accent'] ?? '#000000');
      });
    } catch (e) {
      print('Error loading agent data: $e');
      // Handle error (e.g., show an alert to the user)
    }
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _avatarImage = File(image.path);
        _uploadedImageUrl = null;
      });

      try {
        final agentService = Provider.of<AgentService>(context, listen: false);
        final uploadedUrl = await agentService.uploadImage(_avatarImage!);
        setState(() {
          _uploadedImageUrl = uploadedUrl;
          _avatarImage = null;
        });
      } catch (e) {
        showCupertinoDialog(
          context: context,
          builder: (context) {
            return CupertinoAlertDialog(
              title: Text('Upload Failed'),
              content: Text('Failed to upload image: ${e.toString()}'),
              actions: [
                CupertinoDialogAction(
                  child: Text('OK'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _pickColor(String colorType) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        Color initialColor = colorType == 'primary'
            ? _primaryColor
            : colorType == 'secondary'
            ? _secondaryColor
            : _tertiaryColor;

        return CupertinoAlertDialog(
          title: Text('Pick a color'),
          content: Container(
            child: ColorPicker(
              color: initialColor,
              onColorChanged: (Color color) {
                setState(() {
                  if (colorType == 'primary') {
                    _primaryColor = color;
                  } else if (colorType == 'secondary') {
                    _secondaryColor = color;
                  } else {
                    _tertiaryColor = color;
                  }
                });
              },
            ),
          ),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview() {
    if (_avatarImage != null) {
      return Image.file(_avatarImage!, width: 40, height: 40, fit: BoxFit.cover);
    } else if (_uploadedImageUrl != null && _uploadedImageUrl!.isNotEmpty) {
      return CircleAvatar(
        backgroundColor: CupertinoColors.systemBlue,
        radius: 25,
        child: Image.network(
          _uploadedImageUrl!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Image.asset('assets/haiva.png', width: 40, height: 40, fit: BoxFit.cover);
          },
        ),
      );
    } else {
      return CircleAvatar(
        child: Image.asset('assets/haiva.png', width: 40, height: 40),
        radius: 25,
        backgroundColor: CupertinoColors.white,
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String placeholder, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: CupertinoColors.systemGrey),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
               Text(
                 placeholder,
                 style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 11),
               ),
                CupertinoTextField(
                  controller: controller,
                  placeholder: placeholder,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector(String label, Color color, VoidCallback onTap, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: CupertinoColors.systemGrey),
              SizedBox(width: 8),
              Text(label),
            ],
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: CupertinoColors.systemGrey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageUploader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(width: 8),
          _buildImagePreview(),
          Spacer(),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: _pickImage,
            child: Text('Upload Image', style: TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Edit Agent'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_nameController, 'Name', CupertinoIcons.person),
              SizedBox(height: 16),
              _buildTextField(_descriptionController, 'Description', CupertinoIcons.doc_text),
              SizedBox(height: 16),
              _buildTextField(_displayNameController, 'Display Name', CupertinoIcons.textformat),
              SizedBox(height: 16),
              _buildColorSelector('Primary Color', _primaryColor, () => _pickColor('primary'), CupertinoIcons.paintbrush),
              SizedBox(height: 16),
              _buildColorSelector('Secondary Color', _secondaryColor, () => _pickColor('secondary'), CupertinoIcons.paintbrush_fill),
              SizedBox(height: 16),
              _buildColorSelector('Tertiary Color', _tertiaryColor, () => _pickColor('tertiary'), CupertinoIcons.color_filter),
              SizedBox(height: 16),
              _buildImageUploader(),
              SizedBox(height: 24),
              Center(
                child: CupertinoButton(
                  onPressed: () async {

                    final agent = Agent(
                      id: widget.agentId,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      type: _selectedType ?? 'Analytics',
                      isActive: true,
                      isDeployed: false,
                      agentConfigs: AgentConfigs(
                        colors: {
                          'primary': '#${_primaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          'secondary': '#${_secondaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                          'accent': '#${_tertiaryColor.value.toRadixString(16).substring(2).toUpperCase()}',
                        },
                        displayName: _displayNameController.text,
                        image: _uploadedImageUrl ?? '',
                        description: '',
                      ),
                    );

                    try {
                      AgentProvider().updateAgentConfig(agent.agentConfigs!);
                      await AgentProvider().updateAgent(agent);


                      Navigator.of(context).pop(true);
                    } catch (e) {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: Text('Update Failed'),
                            content: Text('Failed to update agent: ${e.toString()}'),
                            actions: [
                              CupertinoDialogAction(
                                child: Text('OK'),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Save Changes'),
                  color: Color(0xFF19437D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}