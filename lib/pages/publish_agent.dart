import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../models/agent.dart';
import '../providers/agent_provider.dart';
import '../services/agent_service.dart';
import '../services/publish_service.dart';
import 'agent_select_page.dart';

class PublishAgentPage extends StatefulWidget {
  final String? agentId;

  PublishAgentPage(this.agentId);

  @override
  _PublishAgentPageState createState() => _PublishAgentPageState();
}

class _PublishAgentPageState extends State<PublishAgentPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text('Publish Agent'),
      ),
      body: Column(
        children: [
          Expanded(
            child: PublishAgent(agentId: widget.agentId),
          ),
        ],
      ),
    );
  }
}

class PublishAgent extends StatefulWidget {
  final String? agentId;
  const PublishAgent({super.key, this.agentId});
  @override
  State<PublishAgent> createState() => _PublishAgentState();
}

late TextEditingController _nameController;
late TextEditingController _descriptionController;
late TextEditingController _displayNameController;
late List<TextEditingController> _imageControllers;
late TextEditingController _taglineController;
late TextEditingController _keyFeaturesController;
late TextEditingController _detailedDescController;
late TextEditingController _helpDocUrlController;
late TextEditingController _caseStudiesController;
late TextEditingController _helpvideoController;
late List<TextEditingController> _questionController;
late TextEditingController _publisherController;
late TextEditingController _addressController;
late TextEditingController _emailController;
late PublishService _publishService;

String? _selectedCategory = '';
bool dataLoader = false;
bool imageUploadLoading = false;

Widget _buildTextField(
    TextEditingController controller,
    String placeholder,
    IconData icon, {
      int maxLines = 1,
      bool required = false,
      bool isUrl = false,
      bool isEnable = true,
      Function(String)? onChanged,
    }) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnable ? CupertinoColors.systemGrey4 : CupertinoColors.systemGrey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: CupertinoColors.systemGrey),
            SizedBox(width: 8),
            Expanded(
              child: CupertinoTextField(
                enabled: isEnable,
                controller: controller,
                placeholder: placeholder,
                padding: EdgeInsets.zero,
                maxLines: maxLines,
                decoration: BoxDecoration(
                  color: isEnable ? CupertinoColors.white : CupertinoColors.systemGrey4,
                  borderRadius: BorderRadius.circular(8),
                ),
                onChanged: (value) {
                  _validateField(controller, required: required, isUrl: isUrl);
                  if (onChanged != null) {
                    onChanged(value); // Call the passed onChanged function
                  }
                },
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 4),
      ValueListenableBuilder<String?>(
        valueListenable: _getErrorNotifier(controller),
        builder: (context, errorText, child) {
          return errorText != null
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              errorText,
              style: TextStyle(color: CupertinoColors.systemRed, fontSize: 12),
            ),
          )
              : SizedBox.shrink();
        },
      ),
    ],
  );
}



final Map<TextEditingController, ValueNotifier<String?>> _errorNotifiers = {};

ValueNotifier<String?> _getErrorNotifier(TextEditingController controller) {
  if (!_errorNotifiers.containsKey(controller)) {
    _errorNotifiers[controller] = ValueNotifier(null);
  }
  return _errorNotifiers[controller]!;
}

void _validateField(TextEditingController controller, {bool required = false, bool isUrl = false}) {
  final value = controller.text;
  String? error;

  if (required && value.isEmpty) {
    error = 'This field is required.';
  } else if (isUrl && value.isNotEmpty) {
    final urlPattern = r'^(https?:\/\/([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,6}(\/[^\s]*)?)$';
    final regex = RegExp(urlPattern);
    if (!regex.hasMatch(value)) {
      error = 'Please enter a valid URL.';
    }
  }
  _getErrorNotifier(controller).value = error;
}


class _PublishAgentState extends State<PublishAgent> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _publishService = PublishService();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _displayNameController = TextEditingController();
    _taglineController = TextEditingController();
    _detailedDescController = TextEditingController();
    _keyFeaturesController = TextEditingController();
    _helpDocUrlController = TextEditingController();
    _caseStudiesController = TextEditingController();
    _helpvideoController = TextEditingController();
    _publisherController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _questionController = [TextEditingController()];
    _imageControllers = [];
    _selectedCategory = '';
    getAgentName();
    _getPublishDetails().then((getData) {
      bool published = getData['isPublished'] ?? false;
      getData = getData['publishDetails'];
      setState(() {
        if(published) {
          // _nameController = TextEditingController(
          //     text: getData['primary']['name'] ?? '') ;
          // print('name:: ${_nameController.text}');
          // _descriptionController = TextEditingController(
          //     text: getData['primary']['description'] ?? '');
          // _displayNameController = TextEditingController(
          //     text: getData['primary']['displayName'] ?? '');
          _selectedCategory = getData['primary']['category'];
          _taglineController = TextEditingController(text: getData['summary']['tagLine'] ?? '');
          _detailedDescController = TextEditingController(
              text: getData['summary']['detailedDescription'] ?? '');
          _keyFeaturesController = TextEditingController(
              text: getData['summary']['keyFeatures'] ?? '');
          _helpDocUrlController = TextEditingController(
              text: getData['summary']['userEducation']['helpDocumentationLink'] ??
                  '');
          _caseStudiesController = TextEditingController(
              text: getData['summary']['userEducation']['caseStudiesLink'] ??
                  '');
          _helpvideoController = TextEditingController(
              text: getData['summary']['helpVideo'] ?? '');
          _publisherController = TextEditingController(
              text: getData['publisherInfo']['publisherName'] ?? '');
          _emailController = TextEditingController(
              text: getData['publisherInfo']['email'] ?? '');
          _addressController = TextEditingController(
              text: getData['publisherInfo']['address'] ?? '');
          List<dynamic>? questions = getData['summary']['sampleQuestions'] ??
              [];
          _questionController = questions != null && questions.isNotEmpty
              ? questions.map((text) => TextEditingController(text: text.toString())).toList()
              : [TextEditingController()];
          List<dynamic>? imageLinks = getData['imagery']['screenshots'] ?? [];
          print('imageLinks$imageLinks');
          _imageControllers = imageLinks != null && imageLinks.isNotEmpty
              ? imageLinks.map((image) => TextEditingController(text: image.toString())).toList()
              : [];
          _isNextButtonEnabled = _areRequiredFieldsFilled();
          print('If _imageControllers ${_imageControllers}');
        }
      });
    });
    // _addListeners();
    // _onTextFieldChanged();
  }

  Future<void> getAgentName() async {
    try {
      final agent = await AgentProvider().getAgentById(widget.agentId!);
      setState(() {
        _nameController.text = agent.name! ?? '';
        _displayNameController.text = agent.agentConfigs!.displayName ?? '';
        _descriptionController.text = agent.description! ?? '';
        _isNextButtonEnabled = _areRequiredFieldsFilled();
      });
    } catch (e) {
      print('Error loading agent data: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _displayNameController.dispose();
    _taglineController.dispose();
    _detailedDescController.dispose();
    _keyFeaturesController.dispose();
    _helpDocUrlController.dispose();
    _caseStudiesController.dispose();
    _helpvideoController.dispose();
    _publisherController.dispose();
    _emailController.dispose();
    _addressController.dispose();

    for (var controller in _questionController) {
      controller.dispose();
    }
    for (var controller in _imageControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile>? selectedImages = await _picker.pickMultiImage();

    if (selectedImages != null) {
      if (_imageControllers.length + selectedImages.length > 4) {
        _showErrorSnackbar('You can only add a maximum of 4 images.');
        return;
      }

      List<XFile> validImages = [];

      for (var image in selectedImages) {
        bool isDuplicateInControllers = _imageControllers.isNotEmpty &&
            _imageControllers.any((controller) {
              String fileNameFromUrl = Uri.parse(controller.text).pathSegments.last;
              return fileNameFromUrl == image.name;
            });

        if (isDuplicateInControllers) {
          _showErrorSnackbar('Image already added: ${image.name}');
          continue;
        }
        String? validationError = await _validateImage(File(image.path));
        if (validationError == null) {
          validImages.add(image);
        } else {
          _showErrorSnackbar(validationError);
        }
      }

      if (validImages.isNotEmpty) {
        setState(() {
          imageUploadLoading = true;
        });

        for (var validImage in validImages) {
          // Pass each image as a single-item list to the upload function
          bool insertScreenshot = await _uploadAgentScreenshots([validImage]);

          // Check if the upload was successful
          if (insertScreenshot) {
            // Perform any necessary actions for successful upload
            // For example, you might want to update the state or notify the user
            _isNextButtonEnabled = _areRequiredFieldsFilled();
          } else {
            // Handle the case where the upload fails
            _showErrorSnackbar('Failed to upload image: ${validImage.name}');
          }
        }

        setState(() {
          imageUploadLoading = false;
        });
      }
    }
  }


  Future<String?> _validateImage(File image) async {
    final fileSize = await image.length();
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    const maxFileSize = 2 * 1024 * 1024; // 2MB
    const minWidth = 480;
    const minHeight = 854;
    final fileExtension = image.path.split('.').last.toLowerCase();
    final allowedFormats = ['jpg', 'jpeg', 'png'];

    if (fileSize > maxFileSize) {
      return 'Image size exceeds 2MB.';
    }
    if (!allowedFormats.contains(fileExtension)) {
      return 'Invalid image format. Only JPG, JPEG, and PNG are allowed.';
    }
    if (decodedImage.width < minWidth || decodedImage.height < minHeight) {
      return 'Image resolution is too low. Minimum 480x854 pixels required.';
    }
    return null;
  }

  void _showErrorSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  Future<bool> _postPublishDetails() async{
    final postPayload = {
      'primary' : {
        'category' : _selectedCategory,
        'description' : _descriptionController.text,
        'name' : _nameController.text,
        'displayName' : _displayNameController.text,
      }
    };
    try{
      final response = await _publishService.postPublishAgentDetails(widget.agentId, postPayload);
      return true;
    }
    catch(e){
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _getPublishDetails() async {
    setState(() {
      dataLoader = true;
    });
    try{
      final getDetail = await _publishService.getPublishAgentDetails(widget.agentId);
      final getResp = getDetail['publishDetails'];
      return {'isPublished' : getDetail['isPublished'],
      'publishDetails':
      {

        'primary': getResp.containsKey('primary') ? getResp['primary'] : {
          'category': '',
          'name': '',
          'displayName': '',
          'description': '',
        },
        'imagery': getResp.containsKey('imagery') ? getResp['imagery'] : {
          'screenshots': []
        },
        'summary': getResp.containsKey('summary') ? getResp['summary'] : {
          'tagLine': '',
          'detailedDescription': '',
          'keyFeatures': '',
          'userEducation': {
            'helpDocumentationLink': '',
            'caseStudiesLink': '',
          },
          'helpVideo': '',
          'sampleQuestions': [],
        },
        'publisherInfo': getResp.containsKey('publisherInfo')
            ? getResp['publisherInfo']
            : {
          'publisherName': '',
          'email': '',
          'address': '',
        }
      },
      };


    }
    catch(e){
      return {
        'primary' : {
          'category': '',
          'name': '',
          'displayName': '',
          'description': '',
        },
        'imagery': { 'screenshots' : []},
        'summary': {
          'tagLine': '',
          'detailedDescription': '',
          'keyFeatures': '',
          'userEducation': {
            'helpDocumentationLink': '',
            'caseStudiesLink': '',
          },
          'helpVideo': '',
          'sampleQuestions': [],
        },
        'publisherInfo': {
          'publisherName': '',
          'email': '',
          'address': '',
        },
      };
    }
    finally{
      setState(() {
        dataLoader = false;
      });
    }

  }

  Future<bool> _updatePublishDetails(dynamic updatePayload) async{
    try{
      final updateResp = await _publishService.updatePublishAgentDetails(widget.agentId, updatePayload);
      print('updateResp ${updateResp}');
      return true;
    }
    catch(e){
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final AgentService _agentService =  AgentService();
  Future<Agent> getAgentById(String agentId) async {
    try {
      final agent = await _agentService.getAgentById(agentId);
      print("agent in settings ${agent.name}");
      return agent;
    } catch (e) {
      print('Error fetching agent: $e');
      rethrow;
    }
  }

  Future<bool> _updateAgentDesc(dynamic updatePayload) async{
    try{
      final updateResp = await _publishService.updateAgentDesc(widget.agentId, updatePayload);
      print('updateResp ${updateResp}');
      return true;
    }
    catch(e){
      return false;
    }
  }

  Future<bool> _uploadAgentScreenshots(List<XFile> imageFile) async {
    try {
      final response = await _publishService.uploadAgentScreenshots(widget.agentId, imageFile);
      String s3Url = response;
      _imageControllers.add(TextEditingController(text: s3Url));
      print('response $response');
      return true;
    } catch (e) {
      // Log the exception error
      print('Error uploading image: $e');
      return false;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _currentIndex = 0;
  PageController _pageController = PageController();
  bool _isLoading = false;
  bool _isNextButtonEnabled = false;

  Future<void> _publishToHub(String? agentID) async {
    try {
      final agentService = AgentService();
      final response = await agentService.publishAgent(agentID!);
      Map<String, dynamic> res = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Agent published successfully')),
        );
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AgentSelectionPage(),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['message'] ?? 'Failed to publish agent')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _areRequiredFieldsFilled() {
    if (_currentIndex == 0) {
      return _descriptionController.text.trim().isNotEmpty &&
          _selectedCategory != null && _selectedCategory!.trim().isNotEmpty;
    } else if (_currentIndex == 1) {
      return _imageControllers.isNotEmpty;
    } else if (_currentIndex == 2) {
      print('_questionController$_questionController');
      return _taglineController.text.trim().isNotEmpty &&
          _detailedDescController.text.trim().isNotEmpty &&
          _keyFeaturesController.text.trim().isNotEmpty &&
          _helpDocUrlController.text.trim().isNotEmpty &&
          _caseStudiesController.text.trim().isNotEmpty &&
          _helpvideoController.text.trim().isNotEmpty &&
      _questionController[0].text.trim().isNotEmpty;
    } else if (_currentIndex == 3) {
      return _publisherController.text.trim().isNotEmpty &&
          _emailController.text.trim().isNotEmpty &&
          _addressController.text.trim().isNotEmpty;
    } else {
      return true;
    }
  }

  void _nextPage() async {
    setState(() {
      _isLoading = true;
    });
    if (_currentIndex == 0) {
      bool insertStatus = await _postPublishDetails();
      final descPayload = {
        "description": _descriptionController.text,
      };
      bool descUpdateStatus = await _updateAgentDesc(descPayload);
      if (insertStatus == true && descUpdateStatus == true) {
        setState(() {
          _currentIndex += 1;
          _pageController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.ease);
          _isNextButtonEnabled = _areRequiredFieldsFilled();
        });
      }
    } else if (_currentIndex == 1) {
      bool UpdateStatus = false;
      List<String> ScreenshotUrls = [];
      ScreenshotUrls = _imageControllers.map((controller) => controller.text).toList();
      if (ScreenshotUrls.isNotEmpty) {
        final updatePayload = {
          "imagery": {
            "screenshots": ScreenshotUrls,
          },
        };
        UpdateStatus = await _updatePublishDetails(updatePayload);
      }
      if (UpdateStatus == true) {
        setState(() {
          _currentIndex += 1;
          _pageController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.ease);
          _isNextButtonEnabled = _areRequiredFieldsFilled();
        });
      }
    } else if (_currentIndex == 2) {
      List<String> questionTexts = _questionController.map((controller) => controller.text).toList();
      final updatePayload = {
        "summary": {
          "tagLine": _taglineController.text,
          "detailedDescription": _detailedDescController.text,
          "keyFeatures": _keyFeaturesController.text,
          "userEducation": {
            'helpDocumentationLink' : _helpDocUrlController.text,
            'caseStudiesLink' : _caseStudiesController.text
          },
          "helpVideo": _helpvideoController.text,
          "sampleQuestions": questionTexts
        }
      };
      bool UpdateStatus = await _updatePublishDetails(updatePayload);
      if (UpdateStatus == true) {
        setState(() {
          _currentIndex += 1;
          _pageController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.ease);
          _isNextButtonEnabled = _areRequiredFieldsFilled();
        });
      }
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex -= 1;
        _pageController.previousPage(
            duration: Duration(milliseconds: 300), curve: Curves.ease);
        _isNextButtonEnabled = _areRequiredFieldsFilled();
      });
    }
  }

  void _onTextFieldChanged(String value) {
    setState(() {
      _isNextButtonEnabled = _areRequiredFieldsFilled();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: dataLoader
          ? Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19437D)),
      ))
          : PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          _buildBasicInfoPage(),
          _buildImageryPage(),
          _buildSummaryPage(),
          _buildPublisherInfoPage(),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentIndex == 0)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (_currentIndex > 0)
              ElevatedButton(
                onPressed: _previousPage,
                child: Text(
                  'Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (_currentIndex == 0) Spacer(),
            if (_currentIndex < 3)
              ElevatedButton(
                onPressed: _isLoading || !_isNextButtonEnabled ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF19437D),
                  disabledBackgroundColor: Color(0x8519437D),
                ),
                child: _isLoading
                    ? CupertinoActivityIndicator(
                  color: Colors.white,
                )
                    : Text(
                  'Next',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            if (_currentIndex == 3)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF19437D),
                  disabledBackgroundColor: Color(0x8019437D),
                ),
                onPressed: _isLoading || !_isNextButtonEnabled ? null
                    : () async {
                  final shouldPublish = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return CupertinoAlertDialog(
                        title: Text("Confirm Publish"),
                        content: Column(
                          children: [
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Publishing will make this agent available in the Haiva Marketplace! ',
                                      style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                    ),
                                    TextSpan(
                                      text: 'Haiva Agent Hub',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF19437D),
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          launch('https://haiva.ai/agent-hub');
                                        },
                                    ),
                                    TextSpan(
                                      text: ', accessible to all users within the Haiva ecosystem.',
                                      style: TextStyle(fontSize: 14, color: CupertinoColors.systemGrey),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Proceed to publish this agent?',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          CupertinoDialogAction(
                            isDefaultAction: true,
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text("Cancel"),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text("Publish"),
                          ),
                        ],
                      );
                    },
                  );

                  if (shouldPublish == true) {
                    setState(() {
                      _isLoading = true;
                    });

                    final updatePayload = {
                      "publisherInfo": {
                        "publisherName": _publisherController.text,
                        "email": _emailController.text,
                        "address": _addressController.text
                      }
                    };

                    bool updateStatus = await _updatePublishDetails(updatePayload);

                    if (updateStatus == true) {
                      await _publishToHub(widget.agentId);
                    }

                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: _isLoading
                    ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CupertinoActivityIndicator(
                    color: Colors.white,
                  ),
                )
                    : Text(
                  'Publish',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(_nameController, 'Name *', CupertinoIcons.person, isEnable: false),
            SizedBox(height: 16),
            _buildTextField(_displayNameController, 'Display Name *', CupertinoIcons.textformat, isEnable: false),
            SizedBox(height: 16),
            _buildTextField(_descriptionController, 'Description *', CupertinoIcons.doc_text, maxLines: 4, required: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildCategoryDropdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageryPage() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Imagery',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: _pickImages,
                child: Container( // Wrap with Container to set height
                  height: 170, // Set the desired height here
                  child: DottedBorderContainer(
                    child: Padding( // Add padding inside the container
                      padding: const EdgeInsets.all(4.0), // Adjust padding as needed
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // SizedBox(height: 5),
                          Icon(Icons.image, size: 50, color: Color(0x9019437D)),
                          SizedBox(height: 5),
                          Text('Tap to upload an image, or ', style: TextStyle(fontSize: 16)),
                          GestureDetector(
                            onTap: _pickImages,
                            child: Text(
                              'browse',
                              style: TextStyle(fontSize: 16, color: Color(0xFF19437D), decoration: TextDecoration.underline),
                            ),
                          ),
                          SizedBox(height: 5),
                          Center(
                            child: Text(
                              'Upload 1 to 4 images (JPG, JPEG, PNG) under 2MB each, minimum resolution: 480x854 px.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: CupertinoColors.systemGrey),
                            ),
                          ),
                          // SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildImagePreview(),
            ],
          ),
        ),
        if (imageUploadLoading)
          Center(
            child: Container(
              // color: Colors.black.withOpacity(0.5),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF19437D)),
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildSummaryPage() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Make the heading bold
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildTextField(_taglineController, 'Tagline *', CupertinoIcons.quote_bubble, required: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildTextField(_detailedDescController, 'Detailed Description *', CupertinoIcons.doc_text, maxLines: 4, required: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildTextField(_keyFeaturesController, 'Key Features *', CupertinoIcons.list_bullet, maxLines: 3, required: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildTextField(_helpDocUrlController, 'Help Documentation Link *', CupertinoIcons.link, required: true, isUrl: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildTextField(_caseStudiesController, 'Case studies Link *', CupertinoIcons.link, required: true, isUrl: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildTextField(_helpvideoController, 'Help video Link *', CupertinoIcons.link, required: true, isUrl: true, onChanged: _onTextFieldChanged),
            SizedBox(height: 16),
            _buildSampleQuestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildPublisherInfoPage() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Publisher Information',
              style: TextStyle(
                fontSize: 18, // Adjust the font size as needed
                fontWeight: FontWeight.bold, // Make the heading bold
              ),
            ),
          ),
          SizedBox(height: 16),
          _buildTextField(_publisherController, 'Publisher Name *', CupertinoIcons.person, required: true, onChanged: _onTextFieldChanged),
          SizedBox(height: 16),
          _buildTextField(_emailController, 'Email *', CupertinoIcons.mail, required: true, onChanged: _onTextFieldChanged),
          SizedBox(height: 16),
          _buildTextField(_addressController, 'Address *', CupertinoIcons.map_pin_ellipse, maxLines: 3, required: true, onChanged: _onTextFieldChanged),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Expanded(
      child: _imageControllers.isEmpty
          ? Center(
        child: Text(
          'No Images added',
          style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
        ),
      )
          : ListView.builder(
        itemCount: _imageControllers.length,
        itemBuilder: (context, index) {
          final controller = _imageControllers[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                // Image with a loader
                Stack(
                  children: [
                    // Image widget
                    Image.network(
                      controller.text,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        // Display loader while the image is loading
                        return Center(
                          child: SizedBox(
                            child: CupertinoActivityIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                        return Center(child: Icon(Icons.error, color: Colors.red));
                      },
                    ),
                  ],
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    controller.text.split('/').last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool? isDeleted = await _deleteFile(controller.text.split('/').last);
                    if (isDeleted != null && isDeleted) {
                      setState(() {
                        _imageControllers.removeAt(index);
                        _isNextButtonEnabled = _areRequiredFieldsFilled();
                      });
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _deleteFile(String fileName) async {
    bool? confirmDeletion = await _showDeleteConfirmationDialog();
    if (confirmDeletion == true) {
      try {
        List<String> filePaths = ['${Constants.orgId}/${Constants.workspaceId}/$fileName'];
        await _publishService.deleteFiles(filePaths);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted successfully')),
        );
        return true;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete image: $e')),
        );
        return false;
      }
    }
    return false; // Return false if deletion was not confirmed
  }

  Future<bool?> _showDeleteConfirmationDialog() async {
    return showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Delete File'),
          content: const Text('Are you sure you want to delete this file?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Delete', style: TextStyle(color: CupertinoColors.destructiveRed)),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }


  Widget _buildCategoryDropdown() {
    final List<String> categories = ['Sales', 'Finance', 'Education', 'Business', 'Analytics'];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      decoration: BoxDecoration(
        border: Border.all(color: CupertinoColors.systemGrey4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.tag, color: CupertinoColors.systemGrey4),
          SizedBox(width: 8),
          Expanded(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _showPicker(
                  context,
                  'Select a category *',
                  categories,
                  _selectedCategory,
                      (String newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      _isNextButtonEnabled = _areRequiredFieldsFilled();
                    });
                  },
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory != null && _selectedCategory!.isNotEmpty
                        ? _selectedCategory!
                        : 'Select a category *',
                    style: TextStyle(
                      color: _selectedCategory != null && _selectedCategory!.isNotEmpty
                          ? Colors.black
                          : CupertinoColors.systemGrey,
                    ),
                  ),
                  Icon(CupertinoIcons.chevron_down, color: CupertinoColors.systemGrey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showPicker(BuildContext context, String label, List<String> options, String? currentValue, Function(String) onChanged) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 250,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CupertinoButton(
                    child: Text('Done'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Expanded(
                child: CupertinoPicker(
                  magnification: 1.22,
                  squeeze: 1.2,
                  useMagnifier: true,
                  itemExtent: 32,
                  scrollController: FixedExtentScrollController(
                    initialItem: currentValue != null ? options.indexOf(currentValue) : 0,
                  ),
                  onSelectedItemChanged: (int selectedIndex) {
                    onChanged(options[selectedIndex]);
                  },
                  children: options.map((String value) => Center(child: Text(value, style: TextStyle(fontSize: 14)))).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSampleQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Spaces out the label and button
          children: [
            Text(
              'Sample Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold), // Styling for the label
            ),
            IconButton(
              onPressed: _addQuestion, // Add a new question when clicked
              icon: Icon(Icons.add_circle_outline), // Plus icon only
              tooltip: 'Add a question', // Optional tooltip for clarity
            ),
          ],
        ),
        const SizedBox(height: 8), // Adds space below the label/button
        ListView.builder(
          shrinkWrap: true, // Prevents infinite height
          physics: NeverScrollableScrollPhysics(), // Disables scrolling for the ListView
          itemCount: _questionController.length,
          itemBuilder: (BuildContext context, int index) {
            return Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    _questionController[index],
                    'Sample Question ${index + 1} *',
                    CupertinoIcons.question_circle,
                    required: true,
                      onChanged: _onTextFieldChanged
                  ),
                ),
                if(_questionController.length > 1)
                  IconButton(
                    icon: Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => _removeQuestion(index), // Remove the selected question
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _addQuestion() {
    setState(() {
      // Add a new TextEditingController for the new question input
      _questionController.add(TextEditingController());
    });
  }

  void _removeQuestion(int index) {
      // Ensure at least one question remains
      setState(() {
        _questionController[index].dispose();  // Dispose of the TextEditingController to free resources
        _questionController.removeAt(index);   // Remove the controller from the list
      });

  }

}
class DottedBorderContainer extends StatelessWidget {
  final Widget child;

  DottedBorderContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey,
          style: BorderStyle.solid,
        ),
      ),
      child: child,
    );
  }
}
