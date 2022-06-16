import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:highlight/languages/json.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:highlight/languages/python.dart';
import 'package:highlight/languages/vbscript-html.dart';
import 'package:highlight/languages/yaml.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

/// @author NewTab
class ScriptCodeDetailPage extends ConsumerStatefulWidget {
  final String title;
  final String content;

  const ScriptCodeDetailPage({
    Key? key,
    required this.title,
    required this.content,
  }) : super(key: key);

  @override
  ScriptCodeDetailPageState createState() => ScriptCodeDetailPageState();
}

class ScriptCodeDetailPageState extends ConsumerState<ScriptCodeDetailPage> {
  CodeController? _codeController;
  GlobalKey<CodeFieldState> codeFieldKey = GlobalKey();

  bool buttonshow = false;

  void scrollToTop() {
    codeFieldKey.currentState?.getCodeScroll()?.animateTo(0,
        duration: const Duration(milliseconds: 200), curve: Curves.linear);
  }

  void floatingButtonVisibility() {
    double y = codeFieldKey.currentState?.getCodeScroll()?.offset ?? 0;
    if (y > MediaQuery.of(context).size.height / 2) {
      if (buttonshow == true) return;
      setState(() {
        buttonshow = true;
      });
    } else {
      if (buttonshow == false) return;
      setState(() {
        buttonshow = false;
      });
    }
  }

  String suffix = "\n\n\n";

  @override
  void dispose() {
    _codeController?.dispose();
    _codeController = null;
    super.dispose();
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

  late String content;

  @override
  void initState() {
    content = widget.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _codeController ??= CodeController(
      text: (content) + suffix,
      language: getLanguageType(widget.title),
      onChange: (value) {
        content = value + suffix;
      },
      theme: ref.watch(themeProvider).themeColor.codeEditorTheme(),
      stringMap: {
        "export": const TextStyle(
            fontWeight: FontWeight.normal, color: Color(0xff6B2375)),
      },
    );
    return Scaffold(
      floatingActionButton: Visibility(
        visible: buttonshow,
        child: FloatingActionButton(
          mini: true,
          onPressed: () {
            scrollToTop();
          },
          elevation: 2,
          backgroundColor: Colors.white,
          child: const Icon(CupertinoIcons.up_arrow),
        ),
      ),
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: widget.title,
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: SpUtil.getBool(spShowLine, defValue: false) ? 0 : 10,
          ),
          child: CodeField(
            key: codeFieldKey,
            controller: _codeController!,
            expands: true,
            readOnly: true,
            wrap: SpUtil.getBool(spShowLine, defValue: false) ? false : true,
            hideColumn: !SpUtil.getBool(spShowLine, defValue: false),
            lineNumberStyle: LineNumberStyle(
              textStyle: TextStyle(
                color: ref.watch(themeProvider).themeColor.descColor(),
                fontSize: 12,
              ),
            ),
            background: Colors.white,
          ),
        ),
      ),
    );
  }
}
