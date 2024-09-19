import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/colortheme.dart';
import '../widget/button.dart';
import '../widget/chart.dart';
import '../widget/form.dart';
import '../widget/dropdown.dart';

class CustomComponent extends StatelessWidget {
  final Map<String, dynamic> responseData;
  final Function(String) onButtonPressed;
  final String message;

  const CustomComponent({required this.responseData, required this.onButtonPressed, Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (responseData['metadata']['templateId'] == '6') {
      List<dynamic> payloadList = responseData['metadata']['payload'];

      return Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: payloadList.map((payload) {
          return CustomButton(
            title: payload['title'],
            onPressed: (isclicked) {
              onButtonPressed(payload['title']);
            },
            // onPressed: () {
            //   onButtonPressed(payload['title']);
            // },
          );
        }).toList(),
      );
    }
    else if (responseData['metadata']['templateId'] == 'chart') {
      dynamic payloadChart = responseData['metadata']['payload'][0]['chart_data'];
      print("++++payloadchart $payloadChart");

      return Container(
        height: 350,
        width: 500,
        child: ExampleChart(chartData: json.encode(payloadChart)),
      );
    }
    else if (responseData['metadata']['templateId'] == '12') {
       List<dynamic> payloadList = responseData['metadata']['payload'];
       return DynamicFormWidget(payloadList: payloadList, onFormSubmit: (String message, Map<String, dynamic> formData) {  },);
    }
    else {
      return Container(
        child: Text("No Component to display"),
      );
    }
  }
}
