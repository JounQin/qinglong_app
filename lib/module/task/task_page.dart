import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/single_account_page.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/module/task/intime_log/intime_log_page.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/module/task/task_viewmodel.dart';
import 'package:qinglong_app/utils/utils.dart';

class TaskPage extends ConsumerStatefulWidget {
  const TaskPage({Key? key}) : super(key: key);

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends ConsumerState<TaskPage> {
  final TextEditingController _searchController = TextEditingController();

  String currentState = TaskViewModel.allStr;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseStateWidget<TaskViewModel>(
      builder: (ref, model, child) {
        return body(model, getListByType(model), ref);
      },
      model: taskProvider,
      onReady: (viewModel) {
        viewModel.loadData(context);
      },
    );
  }

  Widget body(TaskViewModel model, List<TaskBean> list, WidgetRef ref) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: () async {
        return model.loadData( false);
      },
      child: IconTheme(
        data: const IconThemeData(
          size: 25,
        ),
        child: SlidableAutoCloseBehavior(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            itemBuilder: (context, index) {
              if (index == 0) {
                return searchCell(ref);
              }
              TaskBean item = list[index - 1];
              if (_searchController.text.isEmpty ||
                  (item.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
                  (item.command?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
                  (item.schedule?.contains(_searchController.text.toLowerCase()) ?? false)) {
                return TaskItemCell(item, ref);
              } else {
                return const SizedBox.shrink();
              }
            },
            itemCount: list.length + 1,
            separatorBuilder: (BuildContext context, int index) {
              if (index == 0) return const SizedBox.shrink();
              TaskBean item = list[index - 1];
              if (_searchController.text.isEmpty ||
                  (item.name?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
                  (item.command?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
                  (item.schedule?.contains(_searchController.text.toLowerCase()) ?? false)) {
                return Container(
                  color: ref.watch(themeProvider).themeColor.settingBgColor(),
                  child: const Divider(
                    height: 1,
                    indent: 15,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
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
      child: Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              onSubmitted: (value) {
                setState(() {});
              },
              onSuffixTap: () {
                _searchController.text = "";
                setState(() {});
              },
              controller: _searchController,
              borderRadius: BorderRadius.circular(
                30,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 5,
              ),
              suffixInsets: const EdgeInsets.only(
                right: 15,
              ),
              prefixInsets: EdgeInsets.only(
                top: Platform.isAndroid ? 10 : 6,
                bottom: 6,
                left: 15,
              ),
              placeholderStyle: TextStyle(
                fontSize: 16,
                color: context.watch(themeProvider).themeColor.descColor(),
              ),
              style: const TextStyle(
                fontSize: 16,
              ),
              placeholder: "搜索",
            ),
          ),
          Material(
            color: Colors.transparent,
            child: PopupMenuButton<String>(
              onSelected: (String result) {
                currentState = result;
                setState(() {});
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: Text(
                    TaskViewModel.allStr,
                    style: TextStyle(
                      color: currentState == TaskViewModel.allStr ? ref.watch(themeProvider).primaryColor : ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 14,
                    ),
                  ),
                  value: TaskViewModel.allStr,
                ),
                PopupMenuItem(
                  child: Text(
                    TaskViewModel.runningStr,
                    style: TextStyle(
                      color:
                          currentState == TaskViewModel.runningStr ? ref.watch(themeProvider).primaryColor : ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 14,
                    ),
                  ),
                  value: TaskViewModel.runningStr,
                ),
                PopupMenuItem(
                  child: Text(
                    TaskViewModel.neverStr,
                    style: TextStyle(
                      color: currentState == TaskViewModel.neverStr ? ref.watch(themeProvider).primaryColor : ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 14,
                    ),
                  ),
                  value: TaskViewModel.neverStr,
                ),
                PopupMenuItem(
                  child: Row(
                    children: [
                      Text(
                        TaskViewModel.notScriptStr,
                        style: TextStyle(
                          color: currentState == TaskViewModel.notScriptStr
                              ? ref.watch(themeProvider).primaryColor
                              : ref.watch(themeProvider).themeColor.titleColor(),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  value: TaskViewModel.notScriptStr,
                ),
                PopupMenuItem(
                  child: Text(
                    TaskViewModel.disableStr,
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          currentState == TaskViewModel.disableStr ? ref.watch(themeProvider).primaryColor : ref.watch(themeProvider).themeColor.titleColor(),
                    ),
                  ),
                  value: TaskViewModel.disableStr,
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                ),
                child: Text(
                  "筛选",
                  style: TextStyle(
                    color: ref.watch(themeProvider).themeColor.descColor(),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TaskBean> getListByType(TaskViewModel model) {
    if (currentState == TaskViewModel.allStr) {
      return model.list;
    }

    if (currentState == TaskViewModel.runningStr) {
      return model.running;
    }

    if (currentState == TaskViewModel.neverStr) {
      return model.neverRunning;
    }
    if (currentState == TaskViewModel.notScriptStr) {
      return model.notScripts;
    }
    if (currentState == TaskViewModel.disableStr) {
      return model.disabled;
    }
    return model.list;
  }
}

class TaskItemCell extends StatelessWidget {
  final TaskBean bean;
  final WidgetRef ref;

  const TaskItemCell(this.bean, this.ref, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ref.watch(themeProvider).themeColor.settingBgColor(),
      child: Slidable(
        key: ValueKey(bean.sId),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.7,
          children: [
            SlidableAction(
              backgroundColor: const Color(0xff5D5E70),
              onPressed: (_) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  Navigator.of(context).pushNamed(Routes.routeAddTask, arguments: bean);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.pencil_outline,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffF19A39),
              onPressed: (_) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  pinTask(context);
                });
              },
              foregroundColor: Colors.white,
              icon: bean.isPinned! == 0 ? CupertinoIcons.pin : CupertinoIcons.pin_slash,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffA356D6),
              onPressed: (_) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  enableTask(context);
                });
              },
              foregroundColor: Colors.white,
              icon: bean.isDisabled! == 0 ? Icons.dnd_forwardslash : Icons.check_circle_outline_sharp,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffEA4D3E),
              onPressed: (_) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  delTask(context, ref);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
            ),
          ],
        ),
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.4,
          children: [
            SlidableAction(
              backgroundColor: const Color(0xffD25535),
              onPressed: (_) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  if (bean.status! == 1) {
                    startCron(context, ref);
                  } else {
                    stopCron(context, ref);
                  }
                });
              },
              foregroundColor: Colors.white,
              icon: bean.status! == 1 ? CupertinoIcons.memories : CupertinoIcons.stop_circle,
            ),
            SlidableAction(
              backgroundColor: const Color(0xff606467),
              onPressed: (_) {
                WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
                  logCron(context, ref);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.text_justifyleft,
            ),
          ],
        ),
        child: Material(
          color: ref.watch(themeProvider).themeColor.settingBgColor(),
          child: InkWell(
            onTap: () {
              Navigator.of(context).pushNamed(Routes.routeTaskDetail, arguments: bean);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: bean.isPinned == 1 ? ref.watch(themeProvider).themeColor.pinColor() : Colors.transparent,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            bean.isDisabled == 1
                                ? const Icon(
                                    Icons.dnd_forwardslash,
                                    size: 18,
                                    color: Color(0xffEA4D3E),
                                  )
                                : const SizedBox.shrink(),
                            SizedBox(
                              width: bean.isDisabled == 1 ? 5 : 0,
                            ),
                            bean.status == 1
                                ? const SizedBox.shrink()
                                : SizedBox(
                                    width: 13,
                                    height: 13,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: ref.watch(themeProvider).primaryColor,
                                    ),
                                  ),
                            SizedBox(
                              width: bean.status == 1 ? 0 : 5,
                            ),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  bean.name ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: ref.watch(themeProvider).themeColor.titleColor(),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          (bean.lastExecutionTime == null || bean.lastExecutionTime == 0) ? "-" : Utils.formatMessageTime(bean.lastExecutionTime!),
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color: ref.watch(themeProvider).themeColor.descColor(),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      bean.schedule ?? "",
                      maxLines: 1,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: ref.watch(themeProvider).themeColor.descColor(),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Material(
                    color: Colors.transparent,
                    child: Text(
                      bean.command ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        overflow: TextOverflow.ellipsis,
                        color: ref.watch(themeProvider).themeColor.descColor(),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  startCron(BuildContext context, WidgetRef ref) async {
    await ref.read(taskProvider).runCrons( bean.sId!);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      logCron(context, ref);
    });
  }

  stopCron(BuildContext context, WidgetRef ref) {
    ref.read(taskProvider).stopCrons( bean.sId!);
  }

  logCron(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      showCupertinoDialog(
          useRootNavigator: false,
          builder: (BuildContext context) {
            return CupertinoAlertDialog(
              title: Text(
                "${bean.name}运行日志",
                maxLines: 1,
                style: const TextStyle(overflow: TextOverflow.ellipsis),
              ),
              content: InTimeLogPage(bean.sId!, bean.status == 0),
              actions: [
                CupertinoDialogAction(
                  child: Text(
                    "知道了",
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(taskProvider).loadData( false);
                  },
                ),
              ],
            );
          },
          context: context);
    });
  }

  void enableTask(BuildContext context) {
    ref.read(taskProvider).enableTask( bean.sId!, bean.isDisabled!);
  }

  void pinTask(BuildContext context) {
    ref.read(taskProvider).pinTask( bean.sId!, bean.isPinned!);
  }

  void delTask(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      useRootNavigator: false,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除定时任务 ${bean.name ?? ""} 吗"),
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
            onPressed: () {
              Navigator.of(context).pop();
              ref.watch(taskProvider.notifier).delCron(bean.sId!);
            },
          ),
        ],
      ),
    );
  }
}
