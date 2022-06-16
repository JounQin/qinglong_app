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
import 'package:qinglong_app/module/others/task_log/task_log_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

/// @author NewTab
class TaskLogPage extends ConsumerStatefulWidget {
  const TaskLogPage({Key? key}) : super(key: key);

  @override
  _TaskLogPageState createState() => _TaskLogPageState();
}

class _TaskLogPageState extends ConsumerState<TaskLogPage>
    with LazyLoadState<TaskLogPage> {
  List<TaskLogBean> list = [];
  final TextEditingController _searchController = TextEditingController();

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
        title: "任务日志",
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
                TaskLogBean item = list[index - 1];
                if (_searchController.text.isNotEmpty &&
                    !(item.name?.contains(_searchController.text) ?? false)) {
                  return const SizedBox.shrink();
                }
                return ColoredBox(
                  color: ref.watch(themeProvider).themeColor.settingBgColor(),
                  child: (item.isDir ?? false)
                      ? ExpansionTile(
                          title: Text(
                            item.name ?? "",
                            style: TextStyle(
                              color: ref
                                  .watch(themeProvider)
                                  .themeColor
                                  .titleColor(),
                              fontSize: 16,
                            ),
                          ),
                          children: (item.files?.isNotEmpty ?? false)
                              ? item.files!
                                  .map((e) => ListTile(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              Routes.routeTaskLogDetail,
                                              arguments: {
                                                "path": item.name,
                                                "title": e,
                                              });
                                        },
                                        title: Text(
                                          e,
                                          style: TextStyle(
                                            color: ref
                                                .watch(themeProvider)
                                                .themeColor
                                                .titleColor(),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ))
                                  .toList()
                              : (item.children ?? [])
                                  .map((e) => ListTile(
                                        onTap: () {
                                          Navigator.of(context).pushNamed(
                                              Routes.routeTaskLogDetail,
                                              arguments: {
                                                "path": item.name,
                                                "title": e.title,
                                              });
                                        },
                                        title: Text(
                                          e.title ?? "",
                                          style: TextStyle(
                                            color: ref
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
                            if (item.isDir ?? false) {
                              "该文件夹为空".toast();
                              return;
                            }
                            Navigator.of(context).pushNamed(
                                Routes.routeTaskLogDetail,
                                arguments: {
                                  "path": "",
                                  "title": item.name,
                                });
                          },
                          title: Text(
                            item.name ?? "",
                            style: TextStyle(
                              color: ref
                                  .watch(themeProvider)
                                  .themeColor
                                  .titleColor(),
                              fontSize: 16,
                            ),
                          ),
                        ),
                );
              },
              itemCount: list.length,
            ),
    );
  }

  Future<void> loadData() async {
    HttpResponse<List<TaskLogBean>> response = await Api.taskLog();

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
}
