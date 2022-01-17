
import 'package:flutter/material.dart';
import 'package:qinglong_app/utils/codeeditor_theme.dart';
import 'FileEditor.dart';
import 'EditorModelStyleOptions.dart';
/// Use the EditorModel into CodeEditor in order to control the editor.
///
/// EditorModel extends ChangeNotifier because we use the provider package
/// to simplify the work.
class EditorModel extends ChangeNotifier {
  late int _currentPositionInFiles;
  bool _isEditing = false;
  EditorModelStyleOptions? styleOptions;
  late List<String?> _languages;
  late List<FileEditor> allFiles;

  /// Define the required parameters for the editor to work properly.
  /// For that, you need to define [files] wich is a `List<FileEditor>`.
  ///
  /// You can also define your own preferences with [styleOptions].
  EditorModel({required List<FileEditor> files, this.styleOptions}) {
    if (this.styleOptions == null) {
      this.styleOptions = new EditorModelStyleOptions(theme: qinglongLightTheme);
    }
    this._languages = [];
    this._currentPositionInFiles = 0;
    if (files.length == 0) {
      files.add(
        new FileEditor(
          name: "index.html",
          language: "html",
          code: "",
        ),
      );
    }
    files.forEach((FileEditor file) {
      this._languages.add(file.language);
    });
    this.allFiles = files;
  }

  /// Checks in all the given files if [language] is found,
  /// then returns a List<String> of the files' content that uses [language].
  List<String?> getCodeWithLanguage(String language) {
    List<String?> listOfCode = [];
    this.allFiles.forEach((FileEditor file) {
      if (file.language == language) {
        listOfCode.add(file.code);
      }
    });
    return listOfCode;
  }

  /// Returns the code of the file where [index] corresponds.
  String? getCodeWithIndex(int index) {
    return this.allFiles[index].code;
  }

  /// Returns the file where [index] corresponds.
  FileEditor getFileWithIndex(int index) {
    return this.allFiles[index];
  }

  /// Switch the file using [i] as index of the List<FileEditor> files.
  ///
  /// The user can't change the file if he is editing another one.
  void changeIndexTo(int i) {
    if (this._isEditing) {
      return;
    }
    this._currentPositionInFiles = i;
    this.notify();
  }

  /// Toggle the text field.
  void toggleEditing() {
    this._isEditing = !this._isEditing;
    this.notify();
  }

  /// Overwite the previous code of the file where [index] corresponds by [newCode].
  void updateCodeOfIndex(int index, String? newCode) {
    this.allFiles[index].code = newCode;
    // this.allFiles[index].setCode = newCode;
  }

  void notify() => notifyListeners();

  /// Gets the index of wich file is currently displayed in the editor.
  int? get position => this._currentPositionInFiles;

  /// Gets which language is currently shown.
  String? get currentLanguage =>
      this.allFiles[this._currentPositionInFiles].language;

  /// Is the text field shown ?
  bool get isEditing => this._isEditing;

  /// Gets the number of files.
  int get numberOfFiles => this.allFiles.length;
}
