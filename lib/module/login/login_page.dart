import 'package:dio_log/dio_log.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qinglong_app/base/http/http.dart';
import 'package:qinglong_app/base/routes.dart';
import 'package:qinglong_app/base/theme.dart';
import 'package:qinglong_app/base/userinfo_viewmodel.dart';
import 'package:qinglong_app/main.dart';
import 'package:qinglong_app/utils/extension.dart';
import 'package:qinglong_app/utils/login_helper.dart';
import 'package:qinglong_app/utils/utils.dart';
import 'package:flip_card/flip_card.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool doNotLoadLocalData;

  const LoginPage({
    Key? key,
    this.doNotLoadLocalData = false,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cIdController = TextEditingController();
  final TextEditingController _cSecretController = TextEditingController();
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  bool rememberPassword = false;

  bool useSecretLogin = false;

  @override
  void initState() {
    super.initState();
    if (!widget.doNotLoadLocalData) {
      _hostController.text = getIt<UserInfoViewModel>().host ?? "";
      useSecretLogin = getIt<UserInfoViewModel>().useSecretLogined;
      if (getIt<UserInfoViewModel>().userName != null && getIt<UserInfoViewModel>().userName!.isNotEmpty) {
        if (getIt<UserInfoViewModel>().useSecretLogined) {
          _cIdController.text = getIt<UserInfoViewModel>().userName!;
        } else {
          _userNameController.text = getIt<UserInfoViewModel>().userName!;
        }
        rememberPassword = true;
      } else {
        rememberPassword = false;
      }
      if (getIt<UserInfoViewModel>().passWord != null && getIt<UserInfoViewModel>().passWord!.isNotEmpty) {
        if (getIt<UserInfoViewModel>().useSecretLogined) {
          _cSecretController.text = getIt<UserInfoViewModel>().passWord!;
        } else {
          _passwordController.text = getIt<UserInfoViewModel>().passWord!;
        }
      }
    }
    getIt<UserInfoViewModel>().updateToken("");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (useSecretLogin) {
        cardKey.currentState?.toggleCard();
      }
    });
  }

  GlobalKey<AnimatorWidgetState> loginKey = GlobalKey<AnimatorWidgetState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: ref.watch(themeProvider).darkMode == true ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: ColoredBox(
          color: ref.watch(themeProvider).themeColor.settingBgColor(),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                useSecretLogin ? "client_id登录" : "账号登录",
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: ref.watch(themeProvider).themeColor.titleColor(),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onDoubleTap: () {
                              if (debugBtnIsShow()) {
                                dismissDebugBtn();
                              } else {
                                showDebugBtn(context, btnColor: ref.watch(themeProvider).primaryColor);
                              }
                              WidgetsBinding.instance.endOfFrame;
                            },
                            child: Image.asset(
                              "assets/images/ql.png",
                              height: 45,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 40,
                            child: Text(
                              "域名",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 30,
                          ),
                          Expanded(
                            child: TextField(
                              onChanged: (_) {
                                setState(() {});
                              },
                              controller: _hostController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.all(4),
                                hintText: "http://1.1.1.1:5700",
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                  color: ref.watch(themeProvider).themeColor.descColor(),
                                ),
                              ),
                              autofocus: false,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color(0xff999999),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      FlipCard(
                        key: cardKey,
                        flipOnTouch: false,
                        onFlipDone: (back) {
                          useSecretLogin = back;
                          setState(() {});
                        },
                        direction: FlipDirection.HORIZONTAL,
                        front: SizedBox(
                          height: 110,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    child: Text(
                                      "账户",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                    width: 40,
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      controller: _userNameController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(4),
                                        hintText: "请输入账户",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: ref.watch(themeProvider).themeColor.descColor(),
                                        ),
                                      ),
                                      autofocus: false,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xff999999),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 40,
                                    child: Text(
                                      "密码",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(4),
                                        hintText: "请输入密码",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: ref.watch(themeProvider).themeColor.descColor(),
                                        ),
                                      ),
                                      autofocus: false,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xff999999),
                              ),
                            ],
                          ),
                        ),
                        back: SizedBox(
                          height: 110,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 40,
                                    child: Text(
                                      "id",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 30,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      controller: _cIdController,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(4),
                                        hintText: "请输入client_id",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: ref.watch(themeProvider).themeColor.descColor(),
                                        ),
                                      ),
                                      autofocus: false,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xff999999),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 50,
                                    child: Text(
                                      "secret",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: TextField(
                                      onChanged: (_) {
                                        setState(() {});
                                      },
                                      controller: _cSecretController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.all(4),
                                        hintText: "请输入client_secret",
                                        hintStyle: TextStyle(
                                          fontSize: 16,
                                          color: ref.watch(themeProvider).themeColor.descColor(),
                                        ),
                                      ),
                                      autofocus: false,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: Color(0xff999999),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: rememberPassword,
                        onChanged: (checked) {
                          rememberPassword = checked ?? false;
                          setState(() {});
                        },
                      ),
                      const Text(
                        "记住密码",
                        style: TextStyle(
                          color: Color(0xff555555),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          cardKey.currentState?.toggleCard();
                          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                            setState(() {});
                          });
                        },
                        child: Text(
                          loginByUserName() ? "client_id登录" : "账号登录",
                          style: const TextStyle(
                            color: Color(0xff555555),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Shake(
                  preferences: const AnimationPreferences(autoPlay: AnimationPlayStates.None),
                  key: loginKey,
                  child: Center(
                    child: Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.8,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: canClickLoginBtn()
                              ? [
                                  const Color(0xff5DD16F),
                                  const Color(0xff089556),
                                ]
                              : [
                                  const Color(0xff5DD16F).withOpacity(0.6),
                                  const Color(0xff089556).withOpacity(0.6),
                                ],
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width - 80,
                        child: IgnorePointer(
                          ignoring: !canClickLoginBtn(),
                          child: Builder(
                            builder: (context) {
                              return CupertinoButton(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 5,
                                ),
                                child: isLoading
                                    ? const CupertinoActivityIndicator()
                                    : const Text(
                                        "登 录",
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                        ),
                                      ),
                                onPressed: () async {
                                  Http.pushedLoginPage = false;
                                  Utils.hideKeyBoard(context);
                                  if (loginByUserName()) {
                                    login(_userNameController.text, _passwordController.text);
                                  } else {
                                    login(_cIdController.text, _cSecretController.text);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                (getIt<UserInfoViewModel>().historyAccounts.isEmpty)
                    ? const SizedBox.shrink()
                    : SafeArea(
                        top: false,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: Center(
                            child: Material(
                              color: Colors.transparent,
                              child: PopupMenuButton<UserInfoBean>(
                                onSelected: (UserInfoBean result) {
                                  selected(result);
                                },
                                itemBuilder: (BuildContext context) => <PopupMenuEntry<UserInfoBean>>[
                                  ...getIt<UserInfoViewModel>()
                                      .historyAccounts
                                      .map(
                                        (e) => PopupMenuItem<UserInfoBean>(
                                          value: e,
                                          child: buildCell(context, e),
                                        ),
                                      )
                                      .toList(),
                                ],
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      "assets/images/icon_history.png",
                                      fit: BoxFit.cover,
                                      width: 16,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "历史账号",
                                      style: TextStyle(
                                        color: Color(0xff555555),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isLoading = false;

  bool loginByUserName() {
    return !useSecretLogin;
  }

  LoginHelper? helper;

  Future<void> login(String userName, String password) async {
    isLoading = true;
    setState(() {});

    helper = LoginHelper(useSecretLogin, _hostController.text, userName, password, rememberPassword);
    var response = await helper!.login();
    dealLoginResponse(response);
  }

  void dealLoginResponse(int response) {
    isLoading = false;
    if (response == LoginHelper.success) {
      Navigator.of(context).pushReplacementNamed(Routes.routeHomePage);
    } else if (response == LoginHelper.failed) {
      loginFailed();
    } else {
      twoFact();
    }
  }

  void loginFailed() {
    isLoading = false;
    loginKey.currentState?.forward();
    setState(() {});
  }

  bool canClickLoginBtn() {
    if (isLoading) return false;

    if (_hostController.text.isEmpty) return false;
    if (!loginByUserName()) {
      return _cIdController.text.isNotEmpty && _cSecretController.text.isNotEmpty;
    } else {
      return _userNameController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    }
  }

  void twoFact() {
    String twoFact = "";
    showCupertinoDialog(
        context: context,
        builder: (_) => CupertinoAlertDialog(
              title: const Text("两步验证"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: Colors.transparent,
                    child: TextField(
                      onChanged: (value) {
                        twoFact = value;
                      },
                      maxLines: 1,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                        hintText: "请输入code",
                      ),
                      autofocus: true,
                    ),
                  ),
                ],
              ),
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
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    if (helper != null) {
                      var response = await helper!.loginTwice(twoFact);
                      dealLoginResponse(response);
                    } else {
                      "状态异常，请重新点登录按钮".toast();
                    }
                  },
                ),
              ],
            )).then((value) {
      if (value == null) {
        isLoading = false;
        setState(() {});
      }
    });
  }

  Widget buildCell(BuildContext context, UserInfoBean bean) {
    return ListTile(
      title: Text(
        bean.host ?? "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Text(
          bean.userName ?? "",
        ),
      ),
      contentPadding: EdgeInsets.zero,
      trailing: GestureDetector(
        onTap: () {
          getIt<UserInfoViewModel>().removeHistoryAccount(bean.host);
          Navigator.pop(context);

          setState(() {});
        },
        child: const Icon(
          CupertinoIcons.clear_thick,
          size: 20,
        ),
      ),
    );
  }

  void selected(UserInfoBean result) {
    _hostController.text = result.host ?? "";
    if (result.useSecretLogined) {
      _cIdController.text = result.userName ?? "";
      _cSecretController.text = result.password ?? "";
      if (cardKey.currentState?.isFront ?? false) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          cardKey.currentState?.toggleCard();
        });
      }
    } else {
      _userNameController.text = result.userName ?? "";
      _passwordController.text = result.password ?? "";
      if (!(cardKey.currentState?.isFront ?? false)) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          cardKey.currentState?.toggleCard();
        });
      }
    }
    rememberPassword = true;
    setState(() {});
  }
}
