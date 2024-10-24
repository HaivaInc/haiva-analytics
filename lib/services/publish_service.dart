import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import '../constants.dart';
import 'package:http_parser/http_parser.dart';

import '../models/agent.dart';
import 'agent_service.dart';

class PublishService{
  final String baseurl = 'https://app-haiva.gateway.apiplatform.io/v1';
  final String apiHost = 'https://services.haiva.ai';

  static  String? workspaceId = Constants.workspaceId;
  static  String? token = Constants.accessToken;


  Future<Map<String, dynamic>> getPublishAgentDetails(String? agentId)async {
    print('get//// $agentId');
    final response = await http.get(
    Uri.parse('$baseurl/getPublishAgentDetails?agentId=$agentId'),
    );

    final Map<String, dynamic> data = json.decode(response.body);

    if(response.statusCode == 200){
      print('success: $data');
      return data;
    }
    else{
      print('////Error status code: ${response.statusCode}');
      print('Error response body: ${response.body}');
      print('$baseurl/getPublishAgent?agentId=$agentId');
      throw Exception(data['message']);

    }
  }


  Future<String> postPublishAgentDetails(String? agentId, Map<String, dynamic> payload) async{
    print('post////$agentId');
    final postResponse = await http.post(
      Uri.parse('$baseurl/postPublishAgentDetails?workspaceId=$workspaceId&agentId=$agentId'),
      headers: {
        'Authorization' : 'Bearer $token',
        'Content-Type' : 'application/json',
      },
      body: json.encode(payload)
    );
    final Map<String, dynamic> data = json.decode(postResponse.body);
    if(postResponse.statusCode == 201 || postResponse.statusCode == 200){
      print('3333${data['message']}');
      return data['message'];
    }
    else{

      print('Error status code: ${postResponse.statusCode}');
      print('Error response body: ${postResponse.body}');
      throw Exception(data['message']);
    }
  }

  Future<String> updatePublishAgentDetails(String? agentId, Map<String, dynamic> payload) async{
    print('update////');
    final updateResponse = await http.post(
      Uri.parse('$baseurl/updatePublishAgentDetails?agentId=$agentId'),
      headers: {
        'Content-Type':'application/json'
      },
      body: json.encode(payload)
    );

    final Map<String, dynamic> data = json.decode(updateResponse.body);
    print('7777 ${data['message']}');
    if(updateResponse.statusCode == 200 || updateResponse.statusCode == 201){
      return data['message'];
    }
    else{
      throw Exception(data['message']);
    }

  }

  Future<String> uploadAgentScreenshots(String? agentId, List<XFile> files) async {
    // Prepare the request
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseurl/uploadAgentScreenshots'),
    )
      ..fields['workspaceId'] = Constants.workspaceId! // Add the workspaceId field
      ..fields['agentId'] = agentId ?? '';

    // Add headers
    request.headers.addAll({
      'authorization': 'Bearer ${Constants.accessToken}', // Add your access token here
      // 'Content-Type': 'multipart/form-data', // This line can be commented out
    });

    // print('Uploading to: $baseurl/uploadAgentScreenshots');
    // print('workspaceId: ${Constants.workspaceId}');
    // print('agentId: $agentId');

    // Attach files
    for (var file in files) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'imageFile', // This should match the backend's expected key
          await file.readAsBytes(),
          filename: file.name, // Use the name from XFile
          contentType: MediaType.parse(
              lookupMimeType(file.path) ?? 'application/octet-stream'),
        ),
      );
    }

    // Send the request
    final response = await request.send();

    // Handle the response
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = await response.stream.bytesToString();
      final Map<String, dynamic> data = json.decode(responseData);
      if (data['Url'] != null && data['Url'] is String) {
        // print('Url: ${data['Url']}');
        return data['Url'] as String;
      } else {
        throw Exception('Invalid response format: Url is missing or not a string');
      }
    } else {
      final responseData = await response.stream.bytesToString();
      final errorMessage = json.decode(responseData)['message'] ?? 'Failed to upload image';
      throw Exception(errorMessage);
    }
  }

  Future<String> updateAgentDesc(String? agentId, Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseurl/saveHaivaAgentConfig?agent-id=${agentId}');
    print('666${payload}');
    final updateResponse = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
        body: json.encode(payload),
    );
    final Map<String, dynamic> data = json.decode(updateResponse.body);
    print('7777 ${data['message']}');
    if(updateResponse.statusCode == 200 || updateResponse.statusCode == 201){
      return data['message'];
    }
    else{
      throw Exception(data['message']);
    }
  }

  Future<http.Response> deleteFile(String filePath) async {
    var uri = Uri.parse('$apiHost/v1/filehandling/delete?path=$filePath');
    final response = await http.delete(uri);
    return response;
  }

  Future<http.Response> deleteFiles(List<String> filePaths) async {
    List<String> updatedPaths = filePaths.map((path) {
      return '${Constants.orgId}/${Constants.workspaceId}/$path';
    }).toList();
    String encodedPaths = jsonEncode(updatedPaths);

    var uri = Uri.parse('$apiHost/v1/filehandling/delete?paths=$encodedPaths');

    final response = await http.delete(
      uri,
      headers: {'Content-Type': 'application/json'},
    );
    return response;
  }
}