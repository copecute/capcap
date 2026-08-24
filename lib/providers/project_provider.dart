import 'package:flutter/material.dart';
import '../models/editor_project.dart';

class ProjectProvider extends ChangeNotifier {
  final List<EditorProject> _projects = [];

  List<EditorProject> get projects => List.unmodifiable(_projects);

  void addProject(EditorProject project) {
    _projects.insert(0, project);
    notifyListeners();
  }

  void removeProject(String id) {
    _projects.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
