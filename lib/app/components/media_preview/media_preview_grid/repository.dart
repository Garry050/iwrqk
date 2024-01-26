import '../../../data/enums/result.dart';
import '../../../data/enums/types.dart';
import '../../../data/models/account/settings/media_search_setting.dart';
import '../../../data/models/media/media.dart';
import '../../../data/models/account/settings/filter_setting.dart';
import '../../../data/models/account/settings/media_sort_setting.dart';
import '../../../data/providers/api_provider.dart';

class MediaPreviewGridRepository {
  MediaPreviewGridRepository();

  Future<GroupResult<MediaModel>> getPreviews({
    required int currentPage,
    required MediaSortSettingModel sortSetting,
    required MediaSourceType sourceType,
    bool applyFilter = false,
    FilterSettingModel? filterSetting,
  }) async {
    String path = "";
    MediaType mediaType = MediaType.video;
    Map<String, dynamic> query = {};
    bool isSubscribed = false;

    query = {"page": currentPage};

    if (sortSetting.orderType != null) {
      query.addAll({"sort": sortSetting.orderType!.value});
    }

    switch (sourceType) {
      case MediaSourceType.videos:
        path = "/videos";
        break;
      case MediaSourceType.images:
        mediaType = MediaType.image;
        path = "/images";
        break;
      case MediaSourceType.uploaderVideos:
        query.addAll({"user": sortSetting.userId!});
        path = "/videos";
        break;
      case MediaSourceType.uploaderImages:
        mediaType = MediaType.image;
        query.addAll({"user": sortSetting.userId!});
        path = "/images";
        break;
      case MediaSourceType.subscribedVideos:
        query.addAll({"subscribed": true});
        path = "/videos";
        isSubscribed = true;
        break;
      case MediaSourceType.subscribedImages:
        mediaType = MediaType.image;
        query.addAll({"subscribed": true});
        path = "/images";
        isSubscribed = true;
        break;
      default:
        break;
    }

    if (!(filterSetting?.isEmpty() ?? true) && !isSubscribed && applyFilter) {
      query.addAll({
        "rating": filterSetting!.ratingType?.value ?? RatingType.all.value,
      });
      if (filterSetting.year != null) {
        if (filterSetting.month != null) {
          query
              .addAll({"date": "${filterSetting.year}-${filterSetting.month}"});
        } else {
          query.addAll({"date": "${filterSetting.year}"});
        }
      }
      if (filterSetting.tags != null) {
        query.addAll({"tags": filterSetting.tags!.join(",")});
      }
    }

    return await ApiProvider.getMedia(
      path: path,
      queryParameters: query,
      type: mediaType,
    ).then((value) {
      List<MediaModel> previews = [];
      int count = 0;

      if (value.success) {
        previews = value.data!.results;
        count = value.data!.count;
      } else {
        throw Exception(value.message);
      }

      return GroupResult(results: previews, count: count);
    });
  }

  Future<GroupResult<MediaModel>> getSearchPreviews({
    required int currentPage,
    required MediaSearchSettingModel searchSetting,
  }) {
    MediaType mediaType = MediaType.video;

    if (searchSetting.searchType == SearchType.videos) {
      mediaType = MediaType.video;
    } else if (searchSetting.searchType == SearchType.images) {
      mediaType = MediaType.image;
    }

    return ApiProvider.searchMedia(
      keyword: searchSetting.keyword,
      type: mediaType,
      pageNum: currentPage,
      orderType: searchSetting.orderType,
    ).then((value) {
      List<MediaModel> previews = [];
      int count = 0;

      if (value.success) {
        previews = value.data!.results;
        count = value.data!.count;
      } else {
        throw Exception(value.message);
      }

      return GroupResult(results: previews, count: count);
    });
  }
}
