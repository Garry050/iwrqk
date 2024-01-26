import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';

import '../../../../../i18n/strings.g.dart';
import '../../../../components/network_image.dart';
import '../../../../data/enums/types.dart';
import '../../../../data/models/download_task.dart';
import '../../../../data/models/offline/download_task_media.dart';
import '../../../../data/services/download_service.dart';
import '../../../../utils/display_util.dart';

class DownloadTaskDialog extends StatelessWidget {
  final MediaDownloadTask taskData;
  final void Function()? onPaused;
  final void Function()? onResumed;
  final void Function()? onDeleted;
  final void Function()? onRetry;
  final void Function()? onOpen;
  final void Function()? onShare;

  DownloadTaskDialog({
    super.key,
    required this.taskData,
    this.onPaused,
    this.onResumed,
    this.onDeleted,
    this.onRetry,
    this.onOpen,
    this.onShare,
  });

  final DownloadService _downloadService = Get.find();

  DownloadTaskMediaModel get media => taskData.offlineMedia;

  String get taskId => taskData.taskId;

  Widget _buildStateWidget(BuildContext context) {
    final taskStatus = _downloadService.downloadTasksStatus[taskId];

    return Obx(() {
      if (taskStatus != null) {
        int downloadedSize = media.size * taskStatus.value.progress ~/ 100;
        int totalSize = media.size;
        double progress = 0;

        late Widget statusWidget;

        switch (taskStatus.value.status) {
          case DownloadTaskStatus.enqueued:
            statusWidget = Text(
              t.download.enqueued,
            );
          case DownloadTaskStatus.running:
            statusWidget = Text(
              "${t.download.downloading} ${DisplayUtil.getDownloadFileSizeProgress(downloadedSize, totalSize)}",
            );

            progress = taskStatus.value.progress / 100;
          case DownloadTaskStatus.paused:
            statusWidget = Text(
              "${t.download.paused} ${DisplayUtil.getDownloadFileSizeProgress(downloadedSize, totalSize)}",
            );

            progress = taskStatus.value.progress / 100;
          case DownloadTaskStatus.failed:
            statusWidget = Text(
              t.download.failed,
            );
          case DownloadTaskStatus.complete:
            statusWidget = Text(
                "${t.download.finished} ${DisplayUtil.getDownloadFileSizeProgress(downloadedSize, totalSize)}");

            progress = 1;
          default:
            statusWidget = Text(
              t.download.unknown,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.red,
              ),
            );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
              value: progress,
            ),
            const SizedBox(height: 12),
            statusWidget,
          ],
        );
      } else {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LinearProgressIndicator(
              value: 0,
            ),
            const SizedBox(height: 12),
            Text(
              t.download.unknown,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ],
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskStatus = _downloadService.downloadTasksStatus[taskId];

    return Dialog(
      elevation: 0,
      backgroundColor: Theme.of(context).colorScheme.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      media.title,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    style: IconButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.onInverseSurface),
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            if (taskStatus?.value.status == DownloadTaskStatus.complete) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(24)),
                  child: Container(
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: media.coverUrl != null
                        ? NetworkImg(
                            imageUrl: media.coverUrl!,
                            aspectRatio: 16 / 9,
                            fit: BoxFit.cover,
                            isAdult: media.ratingType == RatingType.ecchi.value,
                          )
                        : const AspectRatio(aspectRatio: 16 / 9),
                  ),
                ),
              ),
            ] else
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 4),
                child: _buildStateWidget(context),
              ),
            Obx(
              () => ButtonBar(
                alignment: MainAxisAlignment.end,
                children: [
                  if (taskStatus?.value.status == null ||
                      taskStatus?.value.status == DownloadTaskStatus.failed ||
                      taskStatus?.value.status ==
                          DownloadTaskStatus.paused) ...[
                    IconButton(
                      onPressed: () {
                        onRetry?.call();
                        Get.back();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    IconButton(
                      onPressed: () {
                        onDeleted?.call();
                        Get.back();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ] else if (taskStatus?.value.status ==
                      DownloadTaskStatus.complete) ...[
                    IconButton(
                      onPressed: () {
                        onDeleted?.call();
                        Get.back();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                    IconButton(
                      onPressed: onOpen,
                      icon: const Icon(Icons.open_in_browser),
                    ),
                    IconButton(
                      onPressed: onShare,
                      icon: const Icon(Icons.share),
                    ),
                  ] else ...[
                    IconButton(
                      onPressed: onPaused,
                      icon:
                          taskStatus?.value.status == DownloadTaskStatus.paused
                              ? const Icon(Icons.play_arrow)
                              : const Icon(Icons.pause),
                    ),
                    IconButton(
                      onPressed: () {
                        onDeleted?.call();
                        Get.back();
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
