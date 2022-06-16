import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/ui/lazy_load_state.dart';
import 'package:share_plus/share_plus.dart';

class InTimeLogPage extends StatefulWidget {
  final String cronId;
  final bool needTimer;
  final String title;

  const InTimeLogPage(this.cronId, this.needTimer, this.title, {Key? key})
      : super(key: key);

  @override
  _InTimeLogPageState createState() => _InTimeLogPageState();
}

class _InTimeLogPageState extends State<InTimeLogPage>
    with LazyLoadState<InTimeLogPage> {
  Timer? _timer;

  String? content;

  @override
  void initState() {
    super.initState();
  }

  bool isRequest = false;
  bool canRequest = true;

  getLogData() async {
    if (!canRequest) return;
    if (isRequest) return;
    isRequest = true;
    HttpResponse<String> response = await Api.inTimeLog(widget.cronId);
    if (response.success) {
      content = response.bean;
      setState(() {});
    }
    isRequest = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 15,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      CupertinoIcons.chevron_down,
                      size: 18,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Share.share(content ?? "");
                    },
                    child: const Icon(
                      CupertinoIcons.share,
                      size: 16,
                    ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              if (content == null)
                const Expanded(
                  child: Center(
                    child: CupertinoActivityIndicator(),
                  ),
                )
              else
                Expanded(
                  child: SingleChildScrollView(
                    primary: true,
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          content!,
                          scrollPhysics: const NeverScrollableScrollPhysics(),
                          onSelectionChanged: (TextSelection selection,
                              SelectionChangedCause? cause) {
                            final int newStart = min(
                                selection.baseOffset, selection.extentOffset);
                            final int newEnd = max(
                                selection.baseOffset, selection.extentOffset);
                            if (newEnd == newStart) {
                              canRequest = true;
                            } else {
                              canRequest = false;
                            }
                          },
                          selectionHeightStyle: BoxHeightStyle.max,
                          selectionWidthStyle: BoxWidthStyle.max,
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 400,
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onLazyLoad() {
    if (widget.needTimer) {
      _timer = Timer.periodic(
        const Duration(seconds: 2),
        (timer) {
          getLogData();
        },
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        getLogData();
      });
    }
  }
}
