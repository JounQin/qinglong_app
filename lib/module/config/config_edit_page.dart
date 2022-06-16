import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

class ConfigEditPage extends ConsumerStatefulWidget {
  final String content;
  final String title;

  const ConfigEditPage(this.title, this.content, {Key? key}) : super(key: key);

  @override
  _ConfigEditPageState createState() => _ConfigEditPageState();
}

class _ConfigEditPageState extends ConsumerState<ConfigEditPage> {
  CodeController? _codeController;
  late String result;
  late String preResult;
  List<String> operateList = [];

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    result = widget.content;
    preResult = widget.content;
    super.initState();
    generateOperateList();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
      checkClipBoard();
    });
  }

  Future<void> notifyICloud(
      BuildContext context, String? title, String? content) async {}

  @override
  Widget build(BuildContext context) {
    _codeController ??= CodeController(
      text: result,
      language: powershell,
      onChange: (value) {
        result = value;
      },
      theme: ref.watch(themeProvider).themeColor.codeEditorTheme(),
      stringMap: {
        "export": const TextStyle(
            fontWeight: FontWeight.normal, color: Color(0xff6B2375)),
      },
    );
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          FocusManager.instance.primaryFocus?.unfocus();

          if (preResult == result) {
            Navigator.of(context).pop();
          } else {
            showCupertinoDialog(
              context: context,
              useRootNavigator: false,
              builder: (childContext) => CupertinoAlertDialog(
                title: const Text("温馨提示"),
                content: const Text("你编辑的内容还没用提交,确定退出吗?"),
                actions: [
                  CupertinoDialogAction(
                    child: const Text(
                      "取消",
                      style: TextStyle(
                        color: Color(0xff999999),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(childContext).pop();
                    },
                  ),
                  CupertinoDialogAction(
                    child: Text(
                      "确定",
                      style: TextStyle(
                        color: ref.watch(themeProvider).primaryColor,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(childContext).pop();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            );
          }
        },
        title: '编辑${widget.title}',
        actions: [
          const SizedBox(
            width: 15,
          ),
          Material(
            color: Colors.transparent,
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                updateValueBykey(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                ...operateList
                    .map(
                      (e) => PopupMenuItem<String>(
                        child: Text(e),
                        value: e,
                      ),
                    )
                    .toList(),
              ],
              child: const Center(
                child: Icon(
                  CupertinoIcons.arrow_up_right_diamond,
                ),
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              HttpResponse<NullResponse> response =
                  await Api.saveFile(widget.title, result);
              await notifyICloud(context, widget.title, result);
              if (response.success) {
                "提交成功".toast();
                Navigator.of(context).pop(widget.title);
              } else {
                (response.message ?? "").toast();
              }
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
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SpUtil.getBool(spShowLine, defValue: false) ? 0 : 10,
          ),
          child: CodeField(
            controller: _codeController!,
            expands: true,
            background: Colors.white,
            wrap: SpUtil.getBool(spShowLine, defValue: false) ? false : true,
            hideColumn: !SpUtil.getBool(spShowLine, defValue: false),
            lineNumberStyle: LineNumberStyle(
              textStyle: TextStyle(
                color: ref.watch(themeProvider).themeColor.descColor(),
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  FocusNode focusNode = FocusNode();

  void generateOperateList() {
    operateList.clear();
    List<String> array = result.split("\n");
    for (String a in array) {
      String t = a.replaceAll(" ", "");
      if (t.trim().startsWith("export")) {
        int i = t.indexOf("export") + 6;
        int j = t.indexOf("=");
        operateList.add(t.substring(i, j));
      }
    }
  }

  void updateValueBykey(String key) async {
    String defaultValue = "";
    try {
      var clipBoard = await Clipboard.getData(Clipboard.kTextPlain);

      if (clipBoard != null && clipBoard.text != null) {
        String tempText = clipBoard.text!;

        if (tempText.trim().contains("export")) {
          int i = tempText.trim().indexOf("\"");
          int j = tempText.trim().lastIndexOf("\"");

          if (i == -1 || j == -1) {
            i = tempText.trim().indexOf("'");
            j = tempText.trim().lastIndexOf("'");
          }

          defaultValue = tempText.trim().substring(i, j);
        } else {
          defaultValue = tempText;
        }
      }
    } catch (e) {}

    TextEditingController controller = TextEditingController(
        text: defaultValue.replaceAll("\"", "").replaceAll("'", ""));
    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text("编辑$key:"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(4),
                  hintText: "请输入值",
                  hintStyle: TextStyle(
                    fontSize: 14,
                  ),
                ),
                autofocus: false,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text(
              "取消",
              style: TextStyle(
                color: Color(0xff999999),
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          CupertinoDialogAction(
            child: Text(
              "确定",
              style: TextStyle(
                color: ref.watch(themeProvider).primaryColor,
              ),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              updateValueByKey(key, controller.text);
            },
          ),
        ],
      ),
    );
  }

  void updateValueByKey(String key, String text) {
    List<String> array = result.split("\n");
    for (String a in array) {
      String t = a.replaceAll(" ", "");
      if (t.trim().startsWith("export")) {
        int i = t.indexOf("export") + 6;
        int j = t.indexOf("=");

        String tempResult = t.substring(i, j);
        if (tempResult == key) {
          result = result.replaceAll(a, "\nexport $key = \"$text\" \n\n");
          break;
        }
      }
    }
    _codeController = null;
    setState(() {});
    "已修改".toast();
  }

  void checkClipBoard() async {
    try {
      String key = "";
      String value = "";
      var clipBoard = await Clipboard.getData(Clipboard.kTextPlain);

      if (clipBoard != null && clipBoard.text != null) {
        String tempText = clipBoard.text!;

        if (tempText.trim().contains("export")) {
          int kI = tempText.trim().indexOf("export");
          int kJ = tempText.trim().indexOf("=");

          key = tempText.trim().substring(kI + 6, kJ);

          int i = tempText.trim().indexOf("\"");
          int j = tempText.trim().lastIndexOf("\"");

          if (i == -1 || j == -1) {
            i = tempText.trim().indexOf("'");
            j = tempText.trim().lastIndexOf("'");
          }
          value = tempText.trim().substring(i, j);

          if (key.isNotEmpty && result.contains(key) && value.isNotEmpty) {
            WidgetsBinding.instance.endOfFrame.then((value) {
              updateValueBykey(key);
            });
          }
        }
      }
    } catch (e) {}
  }
}
