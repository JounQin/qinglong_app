import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:qinglong_app/module/change_account_page.dart';
import 'package:qinglong_app/module/config/config_edit_page.dart';
import 'package:qinglong_app/module/env/add_env_page.dart';
import 'package:qinglong_app/module/env/env_bean.dart';
import 'package:qinglong_app/module/env/env_detail_page.dart';
import 'package:qinglong_app/module/home/home_page.dart';
import 'package:qinglong_app/module/login/login_page.dart';
import 'package:qinglong_app/module/others/about_page.dart';
import 'package:qinglong_app/module/others/dependencies/add_dependency_page.dart';
import 'package:qinglong_app/module/others/dependencies/dependency_page.dart';
import 'package:qinglong_app/module/others/login_log/login_log_page.dart';
import 'package:qinglong_app/module/others/scripts/script_detail_page.dart';
import 'package:qinglong_app/module/others/scripts/script_edit_page.dart';
import 'package:qinglong_app/module/others/scripts/script_page.dart';
import 'package:qinglong_app/module/others/task_log/task_log_detail_page.dart';
import 'package:qinglong_app/module/others/task_log/task_log_page.dart';
import 'package:qinglong_app/module/others/theme_page.dart';
import 'package:qinglong_app/module/others/update_password_page.dart';
import 'package:qinglong_app/module/task/add_task_page.dart';
import 'package:qinglong_app/module/task/task_bean.dart';
import 'package:qinglong_app/module/task/task_detail/task_detail_page.dart';

class Routes {
  static const String routeHomePage = "/home/homepage";
  static const String routeLogin = "/login";
  static const String routeAddTask = "/task/add";
  static const String routeTaskDetail = "/task/detail";
  static const String routeEnvDetail = "/env/detail";
  static const String routeAddDependency = "/task/dependency";
  static const String routeAddEnv = "/env/add";
  static const String routeConfigEdit = "/config/edit";
  static const String routeLoginLog = "/log/login";
  static const String routeTaskLog = "/log/task";
  static const String routeTaskLogDetail = "/log/taskDetail";
  static const String routeScript = "/script";
  static const String routeScriptDetail = "/script/detail";
  static const String routeScriptUpdate = "/script/update";
  static const String routeScriptAdd = "/script/add";
  static const String routeDependency = "/Dependency";
  static const String routeUpdatePassword = "/updatePassword";
  static const String routeAbout = "/about";
  static const String routeTheme = "/theme";
  static const String routeChangeAccount = "/changeAccount";

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeHomePage:
        return MaterialPageRoute(builder: (context) => const HomePage());
      case routeLogin:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (context) => const LoginPage(
                    doNotLoadLocalData: true,
                  ));
        } else {
          return MaterialPageRoute(builder: (context) => const LoginPage());
        }
      case routeChangeAccount:
        return MaterialPageRoute(
          builder: (context) => const ChangeAccountPage(),
        );
      case routeAddTask:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (context) => AddTaskPage(
                    taskBean: settings.arguments as TaskBean,
                  ));
        } else {
          return MaterialPageRoute(builder: (context) => const AddTaskPage());
        }
      case routeAddDependency:
        return MaterialPageRoute(
            builder: (context) => const AddDependencyPage());
      case routeAddEnv:
        if (settings.arguments != null) {
          return MaterialPageRoute(
              builder: (context) => AddEnvPage(
                    envBean: settings.arguments as EnvBean,
                  ));
        } else {
          return MaterialPageRoute(builder: (context) => const AddEnvPage());
        }
      case routeConfigEdit:
        return MaterialPageRoute(
          builder: (context) => ConfigEditPage(
            (settings.arguments as Map)["title"],
            (settings.arguments as Map)["content"],
          ),
        );
      case routeLoginLog:
        return MaterialPageRoute(
          builder: (context) => const LoginLogPage(),
        );
      case routeTaskLog:
        return MaterialPageRoute(
          builder: (context) => const TaskLogPage(),
        );
      case routeScript:
        return MaterialPageRoute(
          builder: (context) => const ScriptPage(),
        );
      case routeDependency:
        return MaterialPageRoute(
          builder: (context) => const DependencyPage(),
        );
      case routeTaskLogDetail:
        return MaterialPageRoute(
          builder: (context) => TaskLogDetailPage(
            title: (settings.arguments as Map)['title'],
            path: (settings.arguments as Map)['path'],
          ),
        );
      case routeScriptDetail:
        return MaterialPageRoute(
          builder: (context) => ScriptDetailPage(
            title: (settings.arguments as Map)["title"],
            path: (settings.arguments as Map)["path"],
          ),
        );
      case routeTaskDetail:
        return MaterialPageRoute(
          builder: (context) => TaskDetailPage(
            settings.arguments as TaskBean,
          ),
        );
      case routeEnvDetail:
        return MaterialPageRoute(
          builder: (context) => EnvDetailPage(
            settings.arguments as EnvBean,
          ),
        );
      case routeUpdatePassword:
        return MaterialPageRoute(
          builder: (context) => const UpdatePasswordPage(),
        );
      case routeAbout:
        return MaterialPageRoute(
          builder: (context) => const AboutPage(),
        );
      case routeTheme:
        return MaterialPageRoute(
          builder: (context) => const ThemePage(),
        );
      case routeScriptUpdate:
        return MaterialPageRoute(
          builder: (context) => ScriptEditPage(
            (settings.arguments as Map)["title"],
            (settings.arguments as Map)["path"],
            (settings.arguments as Map)["content"],
          ),
        );
    }

    return null;
  }
}
