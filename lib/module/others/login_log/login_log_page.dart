import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ql_app_bar.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/utils.dart';

import 'login_log_bean.dart';

/// @author NewTab
class LoginLogPage extends ConsumerStatefulWidget {
  const LoginLogPage({Key? key}) : super(key: key);

  @override
  _LoginLogPageState createState() => _LoginLogPageState();
}

class _LoginLogPageState extends ConsumerState<LoginLogPage>
    with LazyLoadState<LoginLogPage> {
  List<LoginLogBean> list = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: QlAppBar(
        canBack: true,
        backCall: () {
          Navigator.of(context).pop();
        },
        title: "登录日志",
      ),
      body: list.isEmpty
          ? const Center(
        child: CupertinoActivityIndicator(),
      )
          : ListView.separated(
        itemBuilder: (context, index) {
          LoginLogBean item = list[index];

          return Row(
            children: [
              const SizedBox(
                width: 15,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${item.address}",
                        style: TextStyle(
                          color: ref
                              .watch(themeProvider)
                              .themeColor
                              .titleColor(),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 2,
                        ),
                        child: Image.asset(
                          item.status == 0
                              ? "assets/images/icon_success.png"
                              : "assets/images/icon_fail.png",
                          width: 30,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SelectableText(
                    "${item.ip}",
                    selectionWidthStyle: BoxWidthStyle.max,
                    selectionHeightStyle: BoxHeightStyle.max,
                    style: TextStyle(
                      color:
                      ref.watch(themeProvider).themeColor.descColor(),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                Utils.formatMessageTime(item.timestamp ?? 0),
                style: TextStyle(
                  fontSize: 12,
                  color: ref.watch(themeProvider).themeColor.descColor(),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
            ],
          );
        },
        itemCount: list.length,
        separatorBuilder: (BuildContext context, int index) {
          return const Divider(
            indent: 15,
            height: 1,
          );
        },
      ),
    );
  }

  Future<void> loadData() async {
    HttpResponse<List<LoginLogBean>> response =
    await Api.loginLog();

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
