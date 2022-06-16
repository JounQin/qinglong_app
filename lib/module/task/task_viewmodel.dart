import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

var taskProvider = ChangeNotifierProvider((ref) => TaskViewModel());

class TaskViewModel extends BaseViewModel {
  static const String allStr = "全部脚本";
  static const String runningStr = "正在运行";
  static const String neverStr = "从未运行";
  static const String notScriptStr = "拉库脚本";
  static const String disableStr = "禁用脚本";
  List<TaskBean> list = [];
  List<TaskBean> running = [];
  List<TaskBean> neverRunning = [];
  List<TaskBean> notScripts = [];
  List<TaskBean> disabled = [];

  Future<void> loadData([isLoading = true]) async {
    if (isLoading && list.isEmpty) {
      loading(notify: true);
    }

    HttpResponse<List<TaskBean>> result = await Api.crons();

    if (result.success && result.bean != null) {
      list.clear();
      list.addAll(result.bean!);
      sortList();
      success();
    } else {
      list.clear();
      failed(result.message, notify: true);
    }
  }

  void sortList() {
    List<TaskBean> p = [];
    List<TaskBean> r = [];
    List<TaskBean> d = [];

    for (int i = 0; i < list.length; i++) {
      if (list[i].isPinned == 1) {
        p.add(list.removeAt(i));
        i--;
        continue;
      }

      if (list[i].status == 0) {
        r.add(list.removeAt(i));
        i--;
        continue;
      }
      if (list[i].isDisabled == 1) {
        d.add(list.removeAt(i));
        i--;
        continue;
      }
    }

    p.sort((TaskBean a, TaskBean b) {
      bool c = DateTime.fromMillisecondsSinceEpoch(a.created ?? 0)
          .isBefore(DateTime.fromMillisecondsSinceEpoch(b.created ?? 0));
      if (c == true) {
        return 1;
      }
      return -1;
    });

    p.sort((a, b) {
      return (a.isDisabled ?? 0) - (b.isDisabled ?? 0);
    });

    p.sort((a, b) {
      if (a.status == 0 && b.status == 0) {
        bool c = DateTime.fromMillisecondsSinceEpoch(a.created ?? 0)
            .isBefore(DateTime.fromMillisecondsSinceEpoch(b.created ?? 0));
        if (c == true) {
          return 1;
        }
        return -1;
      } else {
        return (a.status ?? 0) - (b.status ?? 0);
      }
    });

    r.sort((a, b) {
      bool c = DateTime.fromMillisecondsSinceEpoch(a.created ?? 0)
          .isBefore(DateTime.fromMillisecondsSinceEpoch(b.created ?? 0));
      if (c == true) {
        return 1;
      }
      return -1;
    });

    d.sort((a, b) {
      bool c = DateTime.fromMillisecondsSinceEpoch(a.created ?? 0)
          .isBefore(DateTime.fromMillisecondsSinceEpoch(b.created ?? 0));
      if (c == true) {
        return 1;
      }
      return -1;
    });

    list.sort((a, b) {
      bool c = DateTime.fromMillisecondsSinceEpoch(a.created ?? 0)
          .isBefore(DateTime.fromMillisecondsSinceEpoch(b.created ?? 0));
      if (c == true) {
        return 1;
      }
      return -1;
    });

    list.insertAll(0, r);
    list.insertAll(0, p);
    list.addAll(d);

    running.clear();
    running.addAll(list.where((element) => element.status == 0));
    neverRunning.clear();
    neverRunning
        .addAll(list.where((element) => element.lastRunningTime == null));
    notScripts.clear();
    notScripts.addAll(list.where((element) => (element.command != null &&
        (element.command!.startsWith("ql repo") ||
            element.command!.startsWith("ql raw")))));
    disabled.clear();
    disabled.addAll(list.where((element) => element.isDisabled == 1));
  }

  Future<void> runCrons(String cron) async {
    HttpResponse<NullResponse> result = await Api.startTasks([cron]);
    if (result.success) {
      loadData(false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  Future<void> stopCrons(String cron) async {
    HttpResponse<NullResponse> result = await Api.stopTasks([cron]);
    if (result.success) {
      loadData(false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  Future<void> delCron(String id) async {
    HttpResponse<NullResponse> result = await Api.delTask(id);
    if (result.success) {
      "删除成功".toast();
      loadData(false);
    } else {
      failToast(result.message, notify: true);
    }
  }

  void updateBean(TaskBean result) {
    if (result.sId == null) {
      loadData(false);
      return;
    }
    TaskBean bean = list.firstWhere((element) => element.sId == result.sId);
    bean.name = result.name;
    bean.schedule = result.schedule;
    bean.command = result.command;
    notifyListeners();
  }

  Future<void> pinTask(String sId, int isPinned) async {
    if (isPinned == 1) {
      HttpResponse<NullResponse> response = await Api.unpinTask(sId);

      if (response.success) {
        "取消置顶成功".toast();
        loadData(false);
      } else {
        failToast(response.message, notify: true);
      }
    } else {
      HttpResponse<NullResponse> response = await Api.pinTask(sId);

      if (response.success) {
        "置顶成功".toast();
        loadData(false);
      } else {
        failToast(response.message, notify: true);
      }
    }
  }

  Future<void> enableTask(String sId, int isDisabled) async {
    if (isDisabled == 0) {
      HttpResponse<NullResponse> response = await Api.disableTask(sId);

      if (response.success) {
        "禁用成功".toast();
        loadData(false);
      } else {
        failToast(response.message, notify: true);
      }
    } else {
      HttpResponse<NullResponse> response = await Api.enableTask(sId);

      if (response.success) {
        "启用成功".toast();
        loadData(false);
      } else {
        failToast(response.message, notify: true);
      }
    }
  }
}
