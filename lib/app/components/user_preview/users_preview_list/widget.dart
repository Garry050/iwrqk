import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/enums/types.dart';
import '../../../data/models/account/settings/users_sort_setting.dart';
import '../../iwr_refresh/widget.dart';
import '../user_preview.dart';
import 'controller.dart';

class UsersPreviewList extends StatefulWidget {
  final UsersSourceType sourceType;
  final UsersSortSetting sortSetting;
  final String tag;
  final bool isSearch;

  UsersPreviewList({
    required this.sourceType,
    required this.sortSetting,
    required this.tag,
    this.isSearch = false,
  }) : super(key: PageStorageKey<String>(tag));

  @override
  State<StatefulWidget> createState() => _UsersPreviewListState();
}

class _UsersPreviewListState extends State<UsersPreviewList>
    with AutomaticKeepAliveClientMixin {
  late UsersPreviewListController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<UsersPreviewListController>(tag: widget.tag);
    _controller.initConfig(
        widget.sortSetting, widget.sourceType, widget.isSearch);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IwrRefresh(
      controller: _controller,
      scrollController: _controller.scrollController,
      builder: (data, scrollController) {
        return CustomScrollView(
          controller: scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return UserPreview(
                    user: data[index],
                  );
                },
                childCount: data.length,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
