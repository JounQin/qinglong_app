import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/utils/extension.dart';

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

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }
  @override
  void initState() {
    result = widget.content;

    super.initState();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    _codeController ??= CodeController(
      text: widget.content,
      language: powershell,
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
              HttpResponse<NullResponse> response = await Api.saveFile(widget.title, result);
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
        child: CodeField(
          controller: _codeController!,
          expands: true,
          background: ref.watch(themeProvider).themeColor.settingBgColor(),
        ),
      ),
    );
  }

  FocusNode focusNode = FocusNode();
}
