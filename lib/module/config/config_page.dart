import 'dart:ui';

import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:highlight/languages/powershell.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/sp_const.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/abs_underline_tabindicator.dart';
import 'package:qinglong_app/base/ui/empty_widget.dart';
import 'package:qinglong_app/main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qinglong_app/utils/sp_utils.dart';

import '../../base/ui/syntax_highlighter.dart';
import 'config_viewmodel.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({Key? key}) : super(key: key);

  @override
  ConfigPageState createState() => ConfigPageState();
}

class ConfigPageState extends State<ConfigPage> with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  int _initIndex = 0;
  BuildContext? childContext;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BaseStateWidget<ConfigViewModel>(
      builder: (ref, model, child) {
        if (model.list.isEmpty) {
          return const EmptyWidget();
        }

        return DefaultTabController(
          length: model.list.length,
          initialIndex: _initIndex,
          child: Builder(builder: (context) {
            childContext = context;
            return Column(
              children: [
                TabBar(
                  tabs: model.list
                      .map((e) => Tab(
                            text: e.title,
                          ))
                      .toList(),
                  isScrollable: true,
                  indicator: AbsUnderlineTabIndicator(
                    wantWidth: 20,
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: model.list
                        .map(
                          (e) => CodeWidget(
                            content: model.content[e.title] ?? "",
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            );
          }),
        );
      },
      model: configProvider,
      onReady: (viewModel) {
        viewModel.loadData();
      },
    );
  }

  void editMe(WidgetRef ref) {
    if (childContext == null) return;
    navigatorState.currentState?.pushNamed(Routes.routeConfigEdit, arguments: {
      "title": ref.read(configProvider).list[DefaultTabController.of(childContext!)?.index ?? 0].title,
      "content": ref.read(configProvider).content[ref.read(configProvider).list[DefaultTabController.of(childContext!)?.index ?? 0].title]
    }).then((value) async {
      if (value != null && (value as String).isNotEmpty) {
        await ref.read(configProvider).loadContent(value);
        setState(() {});
      }
    });
  }

  @override
  bool get wantKeepAlive => true;
}

class CodeWidget extends ConsumerStatefulWidget {
  final String content;

  const CodeWidget({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  ConsumerState<CodeWidget> createState() => _CodeWidgetState();
}

class _CodeWidgetState extends ConsumerState<CodeWidget> with AutomaticKeepAliveClientMixin {
  CodeController? _codeController;

  @override
  void dispose() {
    _codeController?.dispose();
    super.dispose();
  }

  String result = "";

  @override
  void initState() {
    result = widget.content;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    _codeController ??= CodeController(
      text: result,
      language: powershell,
      onChange: (value) {
        result = value;
      },
      theme: ref.watch(themeProvider).themeColor.codeEditorTheme(),
      stringMap: {
        "export": const TextStyle(fontWeight: FontWeight.normal, color: Color(0xff6B2375)),
      },
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: SpUtil.getBool(spShowLine, defValue: false) ? 0 : 10,
        ),
        child: CodeField(
          controller: _codeController!,
          expands: true,
          readOnly: true,
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
