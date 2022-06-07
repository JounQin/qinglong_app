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

/// @author NewTab
class ScriptPage extends ConsumerStatefulWidget {
  const ScriptPage({Key? key}) : super(key: key);

  @override
  _ScriptPageState createState() => _ScriptPageState();
}

class _ScriptPageState extends ConsumerState<ScriptPage> with LazyLoadState<ScriptPage> {
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
          : ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return searchCell(ref);
          }

          ScriptBean item = list[index - 1];

          if (_searchController.text.isEmpty ||
              (item.title?.contains(_searchController.text) ?? false) ||
              (item.value?.contains(_searchController.text) ?? false) ||
              ((item.children?.where((e) {
                return (e.title?.contains(_searchController.text) ?? false) || (e.value?.contains(_searchController.text) ?? false);
              }).isNotEmpty ??
                  false))) {
            return ColoredBox(
              color: ref.watch(themeProvider).themeColor.settingBgColor(),
              child: (item.children != null && item.children!.isNotEmpty)
                  ? ExpansionTile(
                title: Text(
                  item.title ?? "",
                  style: TextStyle(
                    color: (item.disabled ?? false)
                        ? ref.watch(themeProvider).themeColor.descColor()
                        : ref.watch(themeProvider).themeColor.titleColor(),
                    fontSize: 16,
                  ),
                ),
                children: item.children!
                    .where((element) {
                  if (_searchController.text.isEmpty) {
                    return true;
                  }
                  return (element.title?.contains(_searchController.text) ?? false) ||
                      (element.value?.contains(_searchController.text) ?? false);
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
                      if (value != null && value == true) {
                        loadData();
                      }
                    });
                  },
                  title: Text(
                    e.title ?? "",
                    style: TextStyle(
                      color: (item.disabled ?? false)
                          ? ref.watch(themeProvider).themeColor.descColor()
                          : ref.watch(themeProvider).themeColor.titleColor(),
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
                        ? ref.watch(themeProvider).themeColor.descColor()
                        : ref.watch(themeProvider).themeColor.titleColor(),
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
    );
  }

  Widget searchCell(WidgetRef context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
      child:SearchCell(controller: _searchController,),
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
    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("新增脚本"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 10,
            ),
            const Text(
              "脚本名称:",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(4),
                  hintText: "请输入脚本名称",
                  hintStyle: TextStyle(
                    fontSize: 14,
                  ),
                ),
                autofocus: false,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "脚本所属文件夹:",
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            DropdownButtonFormField<String>(
              items: list
                  .where((element) => element.children?.isNotEmpty ?? false)
                  .map((e) => DropdownMenuItem(
                value: e.value,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 2,
                  child: Text(
                    e.value ?? "",
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
                    )),
              value: scriptPath,
              onChanged: (value) {
                scriptPath = value ?? "";
              },
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
              "提交中...".toast();
              HttpResponse<NullResponse> response = await Api.addScript(
                _nameController.text,
                scriptPath,
                "## created by 青龙客户端 ${DateTime.now()}\n\n",
              );
              if (response.success) {
                "提交成功".toast();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(
                  Routes.routeScriptUpdate,
                  arguments: {
                    "title": _nameController.text,
                    "path": scriptPath,
                    "content": "## created by 青龙客户端 ${DateTime.now()}\n\n",
                  },
                ).then((value) {
                  if (value != null && value == true) {
                    _nameController.text = "";
                    loadData();
                  }
                });
              } else {
                (response.message ?? "").toast();
              }
            },
          ),
        ],
      ),
    );
  }
}
