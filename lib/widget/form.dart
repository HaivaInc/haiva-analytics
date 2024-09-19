import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:haivanalytics/widget/radio.dart';
import 'package:haivanalytics/widget/textfield.dart';

import '../theme/colortheme.dart';
import 'dropdown.dart';

typedef FormSubmitCallback = void Function(String message, Map<String, dynamic> formData);
class DynamicFormWidget extends StatefulWidget {
  final List<dynamic> payloadList;
  final FormSubmitCallback onFormSubmit;

  DynamicFormWidget({
    required this.payloadList,
    required this.onFormSubmit,
  });

  @override
  _DynamicFormWidgetState createState() => _DynamicFormWidgetState();
}

class _DynamicFormWidgetState extends State<DynamicFormWidget> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _dropdownValues = {};
  final Map<String, String?> _radioValues = {};
 // late ConfettiController _confettiController;

  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
  //  _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    for (var payload in widget.payloadList) {
      if (payload['type'] == 'text_field' || payload['type'] == 'number_field') {
        var controller = TextEditingController();
        if (payload['data']['displayValue'] != null && payload['data']['displayValue'].isNotEmpty && payload['data']['displayValue'] != '') {
          controller.text = payload['data']['displayValue'];
        }
        _controllers[payload['data']['attributeName']] = controller;
      } else if (payload['type'] == 'dropdown') {
        var selectedOption = (payload['data']['options'] as List<dynamic>).firstWhere(
              (option) => option.containsKey('selected') && option['selected'] == true,
          orElse: () => null,
        );
        _dropdownValues[payload['data']['name']] = selectedOption?['value'] ?? '';
      } else if (payload['type'] == 'radio') {
        _radioValues[payload['data']['name']] = null;
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
  //  _confettiController.dispose(); // Dispose the ConfettiController

    super.dispose();
  }

  void _submitForm() {
    if (_isSubmitted) return;
    _isSubmitted = true;
    Map<String, dynamic> formData = {};
    List<String> incompleteFields = [];
    String submitButtonMessage = '';

    for (var payload in widget.payloadList) {

      if (payload['type'] == 'text_field' || payload['type'] == 'number_field') {
        var text = _controllers[payload['data']['attributeName']]!.text;

        if (text.isEmpty && payload['data']['displayValue'] != null && payload['data']['displayValue'].isNotEmpty) {
          text = payload['data']['displayValue'];
        }

        if (text.isEmpty) {
          incompleteFields.add(payload['data']['displayName']);
        } else {
          formData[payload['data']['attributeName']] = text;
        }
      }

      else if (payload['type'] == 'dropdown') {
        var value = _dropdownValues[payload['data']['name']];
        if (value == null || value.isEmpty) {
          incompleteFields.add(payload['data']['displayName']);
        } else {
          formData[payload['data']['name']] = value;
        }
      } else if (payload['type'] == 'radio') {
        var value = _radioValues[payload['data']['name']];
        if (value == null) {
          incompleteFields.add(payload['data']['displayName']);
        } else {
          formData[payload['data']['name']] = value;
        }
      }
      // } else if (payload['type'] == 'submit_button') {
      //   submitButtonMessage = payload['data']['action']['message'];
      // }
    }

 //   print("Form data to be sent: $formData");

    if (incompleteFields.isNotEmpty) {
      setState(() {
        _isSubmitted = false;
      });
      _showIncompleteFieldsAlert(incompleteFields);
    } else {
    //  print("formData: $formData");
     // _confettiController.play(); // Start confetti animation

      widget.onFormSubmit(submitButtonMessage, formData);
    }
  }

  void _showIncompleteFieldsAlert(List<String> incompleteFields) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ColorTheme.primary,
          shadowColor: ColorTheme.primary,
          title: Text('Incomplete Form'),
          content: Text('Please fill in the following fields: ${incompleteFields.join(', ')}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK',style: GoogleFonts.questrial(
                color: ColorTheme.secondary.computeLuminance() < 0.5 ? Colors.white : Colors.black,
              ),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: widget.payloadList.map((payload) {
            if (payload['type'] == 'text_field') {
              return CustomTextField(
                title: payload['data']['attributeName'],
                hintText: payload['data']['displayValue'],
                labelText: payload['data']['displayName'],
                textController: _controllers[payload['data']['attributeName']]!,
                textType: 'text',
                enableText: true,
              );
            }else if (payload['type'] == 'number_field') {
              return CustomTextField(
                title: payload['data']['attributeName'],
                labelText: payload['data']['displayName'],
                hintText: payload['data']['displayName'],
                textController: _controllers[payload['data']['attributeName']]!,
                textType: 'number',
                enableText: true,

              );
            } else if (payload['type'] == 'dropdown') {
              return CustomDropdown(
                title: payload['data']['displayName'],
                options: (payload['data']['options'] as List<dynamic>).cast<Map<String, dynamic>>(),
                name: payload['data']['name'],
                onChanged: (String? newValue) {
                  setState(() {
                    _dropdownValues[payload['data']['name']] = newValue ?? '';
                  });
                },
                selectedValue: _dropdownValues[payload['data']['name']],
              );
            } else if (payload['type'] == 'radio') {
              return CustomRadio(
                title: payload['data']['displayName'],
                name: payload['data']['name'],
                options: List<Map<String, dynamic>>.from(payload['data']['options']),
                onChanged: (String? newValue) {
                  setState(() {
                    _radioValues[payload['data']['name']] = newValue;
                  });
                },
                selectedValue: _radioValues[payload['data']['name']],
              );
            }
            return SizedBox.shrink();
          }).toList(),
        ),
        SizedBox(height: 10),
        Align(
            alignment: Alignment.bottomLeft,
            child: FilledButton(
              style: FilledButton.styleFrom(
                foregroundColor: ColorTheme.secondary,
                backgroundColor: ColorTheme.primary,
                textStyle: TextStyle(
                  fontSize: 13.0,
                  fontWeight: FontWeight.normal,
                ),
                elevation: 0,
              ),
              onPressed: _submitForm,
              child: Text('Submit'),
            )),
//         ConfettiWidget(
//           confettiController: _confettiController,
//           blastDirectionality: BlastDirectionality.explosive,
// numberOfParticles: 20,
//           shouldLoop: false,
//           colors: [Colors.green, Colors.blue, Colors.pink, Colors.orange],
//         ),
      ],
    );
  }
}
