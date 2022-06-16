import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/search_cell.dart';
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
        viewModel.loadData();
      },
    );
  }

  Widget body(TaskViewModel model, List<TaskBean> list, WidgetRef ref) {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: () async {
        return model.loadData(false);
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
                  (item.name
                          ?.toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ??
                      false) ||
                  (item.command
                          ?.toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ??
                      false) ||
                  (item.schedule
                          ?.contains(_searchController.text.toLowerCase()) ??
                      false)) {
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
                  (item.name
                          ?.toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ??
                      false) ||
                  (item.command
                          ?.toLowerCase()
                          .contains(_searchController.text.toLowerCase()) ??
                      false) ||
                  (item.schedule
                          ?.contains(_searchController.text.toLowerCase()) ??
                      false)) {
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
      color: ref.watch(themeProvider).themeColor.settingBgColor(),
      padding: const EdgeInsets.only(
        left: 15,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: SearchCell(
                controller: _searchController,
              ),
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
                      color: currentState == TaskViewModel.allStr
                          ? ref.watch(themeProvider).primaryColor
                          : ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 14,
                    ),
                  ),
                  value: TaskViewModel.allStr,
                ),
                PopupMenuItem(
                  child: Text(
                    TaskViewModel.runningStr,
                    style: TextStyle(
                      color: currentState == TaskViewModel.runningStr
                          ? ref.watch(themeProvider).primaryColor
                          : ref.watch(themeProvider).themeColor.titleColor(),
                      fontSize: 14,
                    ),
                  ),
                  value: TaskViewModel.runningStr,
                ),
                PopupMenuItem(
                  child: Text(
                    TaskViewModel.neverStr,
                    style: TextStyle(
                      color: currentState == TaskViewModel.neverStr
                          ? ref.watch(themeProvider).primaryColor
                          : ref.watch(themeProvider).themeColor.titleColor(),
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
                              : ref
                                  .watch(themeProvider)
                                  .themeColor
                                  .titleColor(),
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
                      color: currentState == TaskViewModel.disableStr
                          ? ref.watch(themeProvider).primaryColor
                          : ref.watch(themeProvider).themeColor.titleColor(),
                    ),
                  ),
                  value: TaskViewModel.disableStr,
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
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
      color: bean.isPinned == 1
          ? ref.watch(themeProvider).themeColor.pinColor()
          : ref.watch(themeProvider).themeColor.settingBgColor(),
      child: Slidable(
        key: ValueKey(bean.sId),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.7,
          children: [
            SlidableAction(
              backgroundColor: const Color(0xff5D5E70),
              onPressed: (_) {
                WidgetsBinding.instance.endOfFrame.then((timeStamp) {
                  Navigator.of(context)
                      .pushNamed(Routes.routeAddTask, arguments: bean);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.pencil_outline,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffF19A39),
              onPressed: (_) {
                pinTask(context);
              },
              foregroundColor: Colors.white,
              icon: (bean.isPinned ?? 0) == 0
                  ? CupertinoIcons.pin
                  : CupertinoIcons.pin_slash,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffA356D6),
              onPressed: (_) {
                enableTask(context);
              },
              foregroundColor: Colors.white,
              icon: bean.isDisabled! == 0
                  ? Icons.dnd_forwardslash
                  : Icons.check_circle_outline_sharp,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffEA4D3E),
              onPressed: (_) {
                delTask(context, ref);
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
                if (bean.status! == 1) {
                  startCron(
                    context,
                    ref,
                  );
                } else {
                  stopCron(
                    context,
                    ref,
                  );
                }
              },
              foregroundColor: Colors.white,
              icon: bean.status! == 1
                  ? CupertinoIcons.memories
                  : CupertinoIcons.stop_circle,
            ),
            SlidableAction(
              backgroundColor: const Color(0xff606467),
              onPressed: (_) {
                Future.delayed(
                    const Duration(
                      milliseconds: 250,
                    ), () {
                  logCron(context, ref);
                });
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.text_justifyleft,
            ),
          ],
        ),
        child: Material(
          color: bean.isPinned == 1
              ? ref.watch(themeProvider).themeColor.pinColor()
              : ref.watch(themeProvider).themeColor.settingBgColor(),
          child: InkWell(
            onTap: () {
              Navigator.of(context)
                  .pushNamed(Routes.routeTaskDetail, arguments: bean);
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.transparent,
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
                            ConstrainedBox(
                              constraints: BoxConstraints.loose(
                                Size.fromWidth(
                                  MediaQuery.of(context).size.width / 2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  bean.name ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    color: ref
                                        .watch(themeProvider)
                                        .themeColor
                                        .titleColor(),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 7,
                            ),
                            bean.status == 0
                                ? Image.asset(
                                    "assets/images/icon_running.png",
                                    fit: BoxFit.cover,
                                    width: 45,
                                  )
                                : Image.asset(
                                    "assets/images/icon_idle.png",
                                    fit: BoxFit.cover,
                                    width: 45,
                                  ),
                            const SizedBox(
                              width: 7,
                            ),
                            bean.isDisabled == 1
                                ? Image.asset(
                                    "assets/images/icon_task_disable.png",
                                    fit: BoxFit.cover,
                                    width: 45,
                                  )
                                : const SizedBox.shrink()
                          ],
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Text(
                          (bean.lastExecutionTime == null ||
                                  bean.lastExecutionTime == 0)
                              ? "-"
                              : Utils.formatMessageTime(
                                  bean.lastExecutionTime!),
                          maxLines: 1,
                          style: TextStyle(
                            overflow: TextOverflow.ellipsis,
                            color:
                                ref.watch(themeProvider).themeColor.descColor(),
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
    await ref.read(taskProvider).runCrons(bean.sId!);
    Future.delayed(const Duration(milliseconds: 250), () {
      logCron(context, ref);
    });
  }

  stopCron(BuildContext context, WidgetRef ref) {
    ref.read(taskProvider).stopCrons(bean.sId!);
  }

  logCron(BuildContext context, WidgetRef ref) {
    showCupertinoModalBottomSheet(
      expand: true,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => InTimeLogPage(
        bean.sId!,
        true,
        bean.name ?? "",
      ),
    );
  }

  void enableTask(BuildContext context) {
    ref.read(taskProvider).enableTask(bean.sId!, bean.isDisabled!);
  }

  void pinTask(BuildContext context) {
    ref.read(taskProvider).pinTask(bean.sId!, bean.isPinned!);
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
