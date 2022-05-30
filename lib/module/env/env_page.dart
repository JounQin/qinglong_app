import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:qinglong_app/base/base_state_widget.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/empty_widget.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/module/env/env_viewmodel.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';

class EnvPage extends StatefulWidget {
  const EnvPage({Key? key}) : super(key: key);

  @override
  _EnvPageState createState() => _EnvPageState();
}

class _EnvPageState extends State<EnvPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BaseStateWidget<EnvViewModel>(
      builder: (ref, model, child) {
        List<EnvItemCell> list = [];

        for (int i = 0; i < model.list.length; i++) {
          EnvBean value = model.list[i];
          if (_searchController.text.isEmpty ||
              (value.name?.contains(_searchController.text) ?? false) ||
              (value.value?.contains(_searchController.text) ?? false) ||
              (value.remarks?.contains(_searchController.text) ?? false)) {
            list.add(EnvItemCell(
              value,
              i,
              ref,
              key: ValueKey(value.sId),
            ));
          }
        }

        return model.list.isEmpty
            ? const EmptyWidget()
            : RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  return model.loadData(false);
                },
                child: SlidableAutoCloseBehavior(
                  child: ReorderableListView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    header: searchCell(ref),
                    onReorder: (int oldIndex, int newIndex) {
                      if (list.length != model.list.length) {
                        "请先清空搜索关键词".toast();
                        return;
                      }

                      setState(() {
                        //交换数据
                        if (newIndex > oldIndex) {
                          newIndex -= 1;
                        }
                        final EnvBean item = model.list.removeAt(oldIndex);
                        model.list.insert(newIndex, item);
                        model.update(item.sId ?? "", newIndex, oldIndex);
                      });
                    },
                    children: list,
                  ),
                ),
              );
      },
      model: envProvider,
      onReady: (viewModel) {
        viewModel.loadData();
      },
    );
  }

  Widget searchCell(WidgetRef context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),
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
    );
  }
}

class EnvItemCell extends StatelessWidget {
  final EnvBean bean;
  final int index;
  final WidgetRef ref;

  const EnvItemCell(this.bean, this.index, this.ref, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: ref.watch(themeProvider).themeColor.settingBgColor(),
      child: Slidable(
        key: ValueKey(bean.sId),
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              backgroundColor: const Color(0xff5D5E70),
              onPressed: (_) {
                Navigator.of(context).pushNamed(Routes.routeAddEnv, arguments: bean);
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.pencil_outline,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffA356D6),
              onPressed: (_) {
                enableEnv(context);
              },
              foregroundColor: Colors.white,
              icon: bean.status == 0 ? Icons.dnd_forwardslash : Icons.check_circle_outline_sharp,
            ),
            SlidableAction(
              backgroundColor: const Color(0xffEA4D3E),
              onPressed: (_) {
                delEnv(context, ref);
              },
              foregroundColor: Colors.white,
              icon: CupertinoIcons.delete,
            ),
          ],
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: ref.watch(themeProvider).themeColor.settingBgColor(),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamed(Routes.routeEnvDetail, arguments: bean);
                  },
                  child: Container(
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
                                children: [
                                  bean.status == 1
                                      ? const Icon(
                                          Icons.dnd_forwardslash,
                                          size: 18,
                                          color: Color(0xffEA4D3E),
                                        )
                                      : Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            border: Border.all(color: ref.watch(themeProvider).primaryColor, width: 1),
                                          ),
                                          child: Text(
                                            "${getIndexByIndex(context, index)}",
                                            style: TextStyle(color: ref.watch(themeProvider).primaryColor, fontSize: 12),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      bean.name ?? "",
                                      maxLines: 1,
                                      style: TextStyle(
                                        overflow: TextOverflow.ellipsis,
                                        color: ref.watch(themeProvider).themeColor.titleColor(),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Visibility(
                                      visible: bean.remarks != null && bean.remarks!.isNotEmpty,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Text(
                                          "(${bean.remarks})",
                                          maxLines: 1,
                                          style: TextStyle(
                                            height: 1,
                                            overflow: TextOverflow.ellipsis,
                                            color: ref.watch(themeProvider).themeColor.descColor(),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Material(
                              color: Colors.transparent,
                              child: Text(
                                Utils.formatGMTTime(bean.timestamp ?? ""),
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
                          height: 15,
                        ),
                        Material(
                          color: Colors.transparent,
                          child: Text(
                            bean.value ?? "",
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
                  ),
                ),
              ),
              const Divider(
                height: 1,
                indent: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void enableEnv(BuildContext context) {
    ref.read(envProvider).enableEnv(bean.sId!, bean.status!);
  }

  void delEnv(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      useRootNavigator: false,
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text("确认删除"),
        content: Text("确认删除环境变量 ${bean.name ?? ""} 吗"),
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
              ref.read(envProvider).delEnv(bean.sId!);
            },
          ),
        ],
      ),
    );
  }

  int getIndexByIndex(BuildContext context, int index) {
    var list = ref.watch(envProvider.notifier).list;
    int result = 0;

    for (int i = 0; i <= index; i++) {
      if (list.length > index && list[i].status == 0) {
        result++;
      }
    }

    return result;
  }
}
