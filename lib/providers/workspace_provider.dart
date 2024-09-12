import 'package:flutter/material.dart';

class WorkspaceProvider with ChangeNotifier {
  List<String> _workspaces = [];

  List<String> get workspaces => _workspaces;

  void setWorkspaces(List<String> workspaces) {
    _workspaces = workspaces;
    print('Workspaces set: $_workspaces'); // Add this line for debugging
    notifyListeners();
  }

}
