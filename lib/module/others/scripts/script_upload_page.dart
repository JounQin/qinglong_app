import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:path/path.dart';
import 'package:qinglong_app/module/others/scripts/script_code_detail_page.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

/// @author NewTab

class ScriptUploadPage extends ConsumerStatefulWidget {
  final List<String?> paths;

  const ScriptUploadPage({
    Key? key,
    required this.paths,
  }) : super(key: key);

  @override
  ConsumerState<ScriptUploadPage> createState() => ScriptUploadPageState();
}

class ScriptUploadPageState extends ConsumerState<ScriptUploadPage> {
  List<String> list = [];

  final TextEditingController _nameController = TextEditingController();
  String scriptPath = "";
  File? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        title: "新增脚本",
        actions: [
          InkWell(
            onTap: () {
              submit(context);
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Text(
                  "提交",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 30,
                  ),
                  const TitleWidget(
                    "脚本名称",
                  ),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                      hintText: "请输入脚本名称",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: ref.watch(themeProvider).themeColor.descColor(),
                      ),
                    ),
                    autofocus: false,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const TitleWidget(
                    "脚本目录",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  DropdownButtonFormField<String>(
                    items: widget.paths
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  e ?? "",
                                  maxLines: 2,
                                ),
                              ),
                            ))
                        .toList()
                      ..insert(
                        0,
                        DropdownMenuItem(
                          value: "",
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width / 2,
                            child: const Text(
                              "根目录",
                              maxLines: 2,
                            ),
                          ),
                        ),
                      ),
                    style: TextStyle(
                      fontSize: 14,
                      color: ref.watch(themeProvider).themeColor.titleColor(),
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xfff5f5f5),
                        ),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: Color(0xfff5f5f5),
                        ),
                      ),
                    ),
                    value: scriptPath,
                    onChanged: (value) {
                      scriptPath = value ?? "";
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const TitleWidget(
                    "上传脚本",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 80,
                    alignment: Alignment.centerLeft,
                    child: file == null ? addWidget() : addedWidget(context),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget addWidget() {
    return GestureDetector(
      onTap: () async {
        FilePickerResult? result = await FilePicker.platform.pickFiles();
        if (result != null &&
            result.files.isNotEmpty &&
            result.files.single.path != null) {
          file = File(result.files.single.path!);

          if (file == null) return;
          if (file!.lengthSync() > 5242880) {
            file = null;
            "最大支持上传5M的文件".toast();
            return;
          }

          _nameController.text = getFileName();
          setState(() {});
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
        ),
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xfff3f5f7),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Image.asset(
            "assets/images/icon_add_file.png",
            width: 50,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget addedWidget(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          String content = await file!.readAsString();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ScriptCodeDetailPage(
                title: getFileName(),
                content: content,
              ),
            ),
          );
        } catch (e) {
          e.toString().toast();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Image.asset(
              getIconBySuffix(),
              width: 50,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    getFileName(),
                    style: TextStyle(
                      color: ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    getFileSize(file!.path, 1),
                    style: TextStyle(
                      color: ref.watch(themeProvider).themeColor.descColor(),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                file = null;
                _nameController.text = "";
                setState(() {});
              },
              child: Icon(
                CupertinoIcons.clear,
                size: 20,
                color: ref.watch(themeProvider).themeColor.descColor(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getFileSize(String filepath, int decimals) {
    var file = File(filepath);
    int bytes = file.lengthSync();
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  String getFileName() {
    return basename(file!.path);
  }

  String getIconBySuffix() {
    String end = file!.path;

    if (end.endsWith(".py")) {
      return "assets/images/py.png";
    }
    if (end.endsWith(".js")) {
      return "assets/images/js.png";
    }
    if (end.endsWith(".ts")) {
      return "assets/images/ts.png";
    }
    if (end.endsWith(".json")) {
      return "assets/images/json.png";
    }
    if (end.endsWith(".sh")) {
      return "assets/images/shell.png";
    }
    return "assets/images/other.png";
  }

  void submit(BuildContext context) async {
    try {
      if (_nameController.text.isEmpty) {
        "请输入文件名称".toast();
        return;
      }

      if (file == null) {
        Navigator.of(context).pushNamed(
          Routes.routeScriptAdd,
          arguments: {
            "title": _nameController.text,
            "path": scriptPath,
          },
        ).then((value) {
          if (value != null && value == true) {
            Navigator.of(context).pop(true);
          }
        });
      } else {
        String content = await file!.readAsString();
        HttpResponse<NullResponse> response = await Api.addScript(
          _nameController.text,
          scriptPath,
          content,
        );
        if (response.success) {
          "提交成功".toast();

          String command =
              "task $scriptPath${(scriptPath.isNotEmpty) ? separator : ""}${getFileName()} ";

          String? cron = getCronString(content, getFileName());
          Navigator.of(context).popAndPushNamed(
            Routes.routeAddTask,
            arguments: TaskBean(
              name: _nameController.text,
              command: command,
              schedule: cron,
            ),
          );
        } else {
          (response.message ?? "").toast();
        }
      }
    } catch (e) {
      e.toString().toast();
    }
  }

  static String? getCronString(String pre, String fileName) {
    String reg =
        "([\\d\\*]*[\\*-\\/,\\d]*[\\d\\*] ){4,5}[\\d\\*]*[\\*-\\/,\\d]*[\\d\\*]( |,|\").*$fileName";
    RegExp regExp = RegExp(reg);
    RegExpMatch? result = regExp.firstMatch(pre);
    return result?[0]?.replaceAll(fileName, "").trim();
  }
}

class TitleWidget extends ConsumerWidget {
  final String title;
  final bool required;

  const TitleWidget(
    this.title, {
    Key? key,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return RichText(
      text: TextSpan(
        text: !required ? "" : "* ",
        style: const TextStyle(
          color: Color(0xFFF02D2D),
        ),
        children: <TextSpan>[
          TextSpan(
            text: title,
            style: TextStyle(
              fontSize: 16,
              color: ref.watch(themeProvider).themeColor.titleColor(),
            ),
          ),
        ],
      ),
    );
  }
}
