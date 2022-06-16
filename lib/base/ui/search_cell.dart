import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme.dart';

class SearchCell extends ConsumerStatefulWidget {
  final TextEditingController controller;

  const SearchCell({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  ConsumerState createState() => _SearchCellState();
}

class _SearchCellState extends ConsumerState<SearchCell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoSearchTextField(
      decoration: BoxDecoration(
        color: ref.watch(themeProvider).themeColor.blackAndWhite(),
        border: Border.all(width: 1, color: const Color(0xffC0C4CC)),
        borderRadius: BorderRadius.circular(
          7,
        ),
      ),
      onSuffixTap: () {
        widget.controller.text = "";
        setState(() {});
      },
      controller: widget.controller,
      padding: const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 5,
      ),
      suffixInsets: const EdgeInsets.only(
        right: 15,
      ),
      prefixIcon: Image.asset(
        "assets/images/icon_search.png",
        width: 18,
        fit: BoxFit.cover,
      ),
      prefixInsets: const EdgeInsets.only(
        left: 10,
        top: 2,
      ),
      placeholderStyle: TextStyle(
        fontSize: 14,
        color: ref.watch(themeProvider).themeColor.descColor(),
      ),
      style: const TextStyle(
        fontSize: 16,
      ),
      placeholder: "请输入内容",
    );
  }
}
