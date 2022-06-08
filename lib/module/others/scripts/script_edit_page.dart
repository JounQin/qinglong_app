import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/vbscript-html.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/extension.dart';

class ScriptEditPage extends ConsumerStatefulWidget {
  final String content;
  final String title;
  final String path;

  const ScriptEditPage(this.title, this.path, this.content, {Key? key}) : super(key: key);

  @override
  _ScriptEditPageState createState() => _ScriptEditPageState();
}

class _ScriptEditPageState extends ConsumerState<ScriptEditPage> {
  CodeController? _codeController;
  late String result;
  FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    result = widget.content;

    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
  }

  getLanguageType(String title) {
    if (title.endsWith(".js")) {
      return javascript;
    }

    if (title.endsWith(".sh")) {
      return powershell;
    }

    if (title.endsWith(".py")) {
      return python;
    }
    if (title.endsWith(".json")) {
      return json;
    }
    if (title.endsWith(".yaml")) {
      return yaml;
    }
    return vbscriptHtml;
  }

  @override
  Widget build(BuildContext context) {
    _codeController ??= CodeController(
      text: widget.content,
      language: getLanguageType(widget.title),
      onChange: (value) {
        result = value;
      },
      theme: ref.watch(themeProvider).themeColor.codeEditorTheme(),
      stringMap: {
        "export": const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff6B2375)),
      },
    );
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: '编辑${widget.title}',
        actions: [
          InkWell(
            onTap: () async {
              HttpResponse<NullResponse> response = await Api.updateScript(widget.title, widget.path, result);
              if (response.success) {
                "提交成功".toast();
                Navigator.of(context).pop(true);
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
        child: CodeField(
          controller: _codeController!,
          expands: true,
          wrap: true,
          lineNumberStyle: const LineNumberStyle(
            width: 0,
            margin: 0,
            textStyle: TextStyle(
              color: Colors.transparent,
              fontSize: 0,
            ),
          ),
          background: ref.watch(themeProvider).themeColor.tabBarColor(),
        ),
      ),
    );
  }
}
