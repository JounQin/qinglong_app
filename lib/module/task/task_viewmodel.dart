import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

var taskProvider = ChangeNotifierProvider((ref) => TaskViewModel());
Map<int, int> sort = {
  0: 0,
  5: 1,
  3: 2,
  1: 3,
  4: 4,
};

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
    if (isLoading) {
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
    list.sort((TaskBean a, TaskBean b) {
      int? sortA = (a.isPinned == 1 && a.status != 0)
          ? 5
          : (a.isDisabled == 1 && a.status != 0)
              ? 4
              : a.status;
      int? sortB = (b.isPinned == 1 && b.status != 0)
          ? 5
          : (b.isDisabled == 1 && b.status != 0)
              ? 4
              : b.status;

      return sort[sortA!]! - sort[sortB!]!;
    });

    for (int i = 0; i < list.length; i++) {
      if (list[i].isPinned == 1) {
        list.insert(0, list.removeAt(i));
      }
    }

    running.clear();
    running.addAll(list.where((element) => element.status == 0));
    neverRunning.clear();
    neverRunning.addAll(list.where((element) => element.lastRunningTime == null));
    notScripts.clear();
    notScripts.addAll(list.where((element) => (element.command != null && (element.command!.startsWith("ql repo") || element.command!.startsWith("ql raw")))));
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
