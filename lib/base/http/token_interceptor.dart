import 'package:dio/dio.dart';
import 'package:qinglong_app/base/http/url.dart';
import 'package:qinglong_app/main.dart';

import '../userinfo_viewmodel.dart';

class TokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers["User-Agent"] = "qinglong_client";

    options.headers["Content-Type"] = "application/json;charset=UTF-8";

    if (!Url.inWhiteList(options.path)) {
      options.queryParameters["t"] =
          (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    }

    if (!Url.inLoginList(options.path)) {
      if (getIt<UserInfoViewModel>().token != null &&
          getIt<UserInfoViewModel>().token!.isNotEmpty) {
        options.headers["Authorization"] =
            "Bearer " + getIt<UserInfoViewModel>().token!;
      }
    }
    return handler.next(options);
  }
}
