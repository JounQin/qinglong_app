import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/base_viewmodel.dart';
import 'package:qinglong_app/base/http/api.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/utils/extension.dart';

var envProvider = ChangeNotifierProvider((ref) => EnvViewModel());

class EnvViewModel extends BaseViewModel {
  static const String allStr = "全部";
  static const String disabledStr = "已禁用";
  static const String enabledStr = "已启用";
  List<EnvBean> list = [];
  List<EnvBean> disabledList = [];
  List<EnvBean> enabledList = [];

  Future<void> loadData([isLoading = true]) async {
    if (isLoading && list.isEmpty) {
      loading(notify: true);
    }

    HttpResponse<List<EnvBean>> result = await Api.envs("");

    if (result.success && result.bean != null) {
      list.clear();
      list.addAll(result.bean!);
      disabledList.clear();
      disabledList
          .addAll(list.where((element) => element.status == 1).toList());
      enabledList.clear();
      enabledList.addAll(list.where((element) => element.status == 0).toList());
      success();
    } else {
      list.clear();
      disabledList.clear();
      enabledList.clear();
      failed(result.message, notify: true);
    }
  }

  Future<void> delEnv(String id) async {
    HttpResponse<NullResponse> result = await Api.delEnv(id);
    if (result.success) {
      "删除成功".toast();
      loadData(false);
    } else {
      failed(result.message, notify: true);
    }
  }

  void updateEnv(EnvBean result) {
    loadData(false);
  }

  Future<void> enableEnv(String sId, int status) async {
    if (status == 1) {
      HttpResponse<NullResponse> response = await Api.enableEnv(sId);

      if (response.success) {
        "启用成功".toast();
        loadData(false);
      } else {
        failToast(response.message, notify: true);
      }
    } else {
      HttpResponse<NullResponse> response = await Api.disableEnv(sId);

      if (response.success) {
        "禁用成功".toast();
        loadData(false);
      } else {
        failToast(response.message, notify: true);
      }
    }
  }

  void update(String id, int newIndex, int oldIndex) async {
    await Api.moveEnv(id, oldIndex, newIndex);
    loadData(false);
  }
}
