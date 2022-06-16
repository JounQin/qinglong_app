import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/base/ui/search_cell.dart';
import 'package:qinglong_app/module/others/scripts/script_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

import 'script_upload_page.dart';

/// @author NewTab
class ScriptPage extends ConsumerStatefulWidget {
  const ScriptPage({Key? key}) : super(key: key);

  @override
  _ScriptPageState createState() => _ScriptPageState();
}

class _ScriptPageState extends ConsumerState<ScriptPage>
    with LazyLoadState<ScriptPage> {
  List<ScriptBean> list = [];
  final TextEditingController _searchController = TextEditingController();

  final TextEditingController _nameController = TextEditingController();
  String? path;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: "脚本管理",
        actions: [
          InkWell(
            onTap: () {
              addScript();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.add,
                  size: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: list.isEmpty
          ? const Center(
              child: CupertinoActivityIndicator(),
            )
          : RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: () async {
                await loadData();
                return Future.value();
              },
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return searchCell(ref);
                  }

                  ScriptBean item = list[index - 1];

                  if (_searchController.text.isEmpty ||
                      (item.title?.contains(_searchController.text) ?? false) ||
                      (item.value?.contains(_searchController.text) ?? false) ||
                      ((item.children?.where((e) {
                            return (e.title?.contains(_searchController.text) ??
                                    false) ||
                                (e.value?.contains(_searchController.text) ??
                                    false);
                          }).isNotEmpty ??
                          false))) {
                    return ColoredBox(
                      color:
                          ref.watch(themeProvider).themeColor.settingBgColor(),
                      child:
                          (item.children != null && item.children!.isNotEmpty)
                              ? ExpansionTile(
                                  title: Text(
                                    item.title ?? "",
                                    style: TextStyle(
                                      color: (item.disabled ?? false)
                                          ? ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .descColor()
                                          : ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .titleColor(),
                                      fontSize: 16,
                                    ),
                                  ),
                                  children: item.children!
                                      .where((element) {
                                        if (_searchController.text.isEmpty) {
                                          return true;
                                        }
                                        return (element.title?.contains(
                                                    _searchController.text) ??
                                                false) ||
                                            (element.value?.contains(
                                                    _searchController.text) ??
                                                false);
                                      })
                                      .map((e) => ListTile(
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                Routes.routeScriptDetail,
                                                arguments: {
                                                  "title": e.title,
                                                  "path": e.parent,
                                                },
                                              ).then((value) {
                                                if (value != null &&
                                                    value == true) {
                                                  loadData();
                                                }
                                              });
                                            },
                                            title: Text(
                                              e.title ?? "",
                                              style: TextStyle(
                                                color: (item.disabled ?? false)
                                                    ? ref
                                                        .watch(themeProvider)
                                                        .themeColor
                                                        .descColor()
                                                    : ref
                                                        .watch(themeProvider)
                                                        .themeColor
                                                        .titleColor(),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                )
                              : ListTile(
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      Routes.routeScriptDetail,
                                      arguments: {
                                        "title": item.title,
                                        "path": "",
                                      },
                                    ).then(
                                      (value) {
                                        if (value != null && value == true) {
                                          loadData();
                                        }
                                      },
                                    );
                                  },
                                  title: Text(
                                    item.title ?? "",
                                    style: TextStyle(
                                      color: (item.disabled ?? false)
                                          ? ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .descColor()
                                          : ref
                                              .watch(themeProvider)
                                              .themeColor
                                              .titleColor(),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
                itemCount: list.length + 1,
              ),
            ),
    );
  }

  Widget searchCell(WidgetRef context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child: SearchCell(
        controller: _searchController,
      ),
    );
  }

  Future<void> loadData() async {
    HttpResponse<List<ScriptBean>> response = await Api.scripts();

    if (response.success) {
      if (response.bean == null || response.bean!.isEmpty) {
        "暂无数据".toast();
      }
      list.clear();
      list.addAll(response.bean ?? []);
      setState(() {});
    } else {
      response.message?.toast();
    }
  }

  @override
  void onLazyLoad() {
    loadData();
  }

  String scriptPath = "";

  void addScript() {
    List<String?> paths = list
        .where((element) => element.children?.isNotEmpty ?? false)
        .map((e) => e.title)
        .toList();

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ScriptUploadPage(paths: paths)));
  }
}
