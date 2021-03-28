import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/constants/language.dart';


late Download download;


enum DownloadExceptionType {
  connection,
  statusCode,
}


class DownloadException {
  final int? statusCode;
  final String? message;
  final DownloadExceptionType? type;

  DownloadException({this.statusCode, this.message, this.type});
}


class DownloadTask {
  final Uri fileUri;
  final File saveLocation;
  final void Function(double progress)? onProgress;
  final void Function()? onCompleted;
  final void Function(DownloadException exception)? onException;
  final dynamic extras;
  DownloadException? exception;
  int? downloadId;
  bool isStarted = false;
  bool isCompleted = false;
  int downloadedSize = 0;
  int? fileSize = 0;
  double progress = 0.0;
  bool isSuccess = true;
  late http.StreamedResponse _responseStream;

  DownloadTask({required this.fileUri, required this.saveLocation, this.downloadId, this.fileSize, this.extras, this.onProgress, this.onCompleted, this.onException});

  Stream<DownloadTask> start() async* {
    http.Client httpClient = new http.Client();
    var streamConsumer = this.saveLocation.openWrite();
    try {
      this._responseStream = await httpClient.send(
        new http.Request('GET', this.fileUri),
      );
      this.fileSize = this._responseStream.contentLength;
      await for (List<int> responseChunk in this._responseStream.stream) {
        this.downloadedSize += responseChunk.length;
        if (this._responseStream.statusCode >= 200 && this._responseStream.statusCode < 300) {
          streamConsumer.add(responseChunk);
          this.progress = this.downloadedSize / this.fileSize!;
          this.onProgress?.call(this.progress);
          yield this;
        }
        else {
          this.exception = DownloadException(
            statusCode: this._responseStream.statusCode,
            message: 'Exception: Invalid status code: ${this._responseStream.statusCode}.',
            type: DownloadExceptionType.statusCode,
          );
          throw this.exception!;
        }
      }
      this.isSuccess = true;
      httpClient.close();
      streamConsumer.close();
      this.isCompleted = true;
      this.onCompleted?.call();
      yield this;
    }
    catch(exception) {
      this.isSuccess = false;
      httpClient.close();
      streamConsumer.close();
      this.isCompleted = true;
      if (await this.saveLocation.exists()) this.saveLocation.delete();
      if (exception is DownloadException) {
        throw this.exception!;
      }
      else {
        this.exception = DownloadException(
          statusCode: null,
          message: 'Exception: Could not connect to the host.',
          type: DownloadExceptionType.connection,
        );
        throw this.exception!;
      }
    }
  }
}


class Download {
  List<DownloadTask> tasks = <DownloadTask>[];
  DownloadTask? currentTask;
  Stream<DownloadTask>? taskStream;
  bool _isUnderProgress = false;

  String _toMegaBytes(int? size) {
    return ((size ?? 0.0) / (1024 * 1024)).toStringAsFixed(2);
  }

  Future<void> _showDownloadNotification({required DownloadTask task}) async {
    NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        'com.alexmercerind.harmonoid',
        'Harmonoid',
        '',
        subText: task.extras.albumName,
        icon: 'mipmap/ic_launcher',
        showProgress: !task.isCompleted,
        progress: (task.progress * 100).toInt(),
        maxProgress: 100,
        ongoing: !(task.isCompleted || task.progress == 1.0),
        showWhen: false,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
      ),
    );
    await notification.show(
      task.downloadId!,
      task.extras.trackName,
      task.isCompleted ? '${task.isSuccess ? language!.STRING_DOWNLOAD_COMPLETED : language!.STRING_DOWNLOAD_FAILED} ' : '' + '${this._toMegaBytes(task.downloadedSize)}/${this._toMegaBytes(task.fileSize)} MB',
      details,
      payload: '',
    );
  }

  static Future<void> init() async {
    download = new Download();
  }

  void start() {
    this.taskStream = this._streamCurrentDownloadItem().asBroadcastStream()..listen((task) {});
  }

  void addTask(DownloadTask task, {bool start: true}) {
    if (!this._isUnderProgress) this.start();
    this._isBatchModified = true;
    task.downloadId = this.tasks.length + 1;
    this._updatedTasks.add(task);
  }

  void addTasks(List<DownloadTask> tasks, {bool start: true}) {
    if (!this._isUnderProgress) this.start();
    this._isBatchModified = true;
    tasks.map((DownloadTask task) {
      task.downloadId = this.tasks.length + 1;
      this._updatedTasks.add(task);
    });
  }

  Stream<DownloadTask> _streamCurrentDownloadItem() async* {
    this.tasks = this._updatedTasks;
    this._isBatchModified = false;
    this._isUnderProgress = true;
    for (DownloadTask task in this.tasks) {
      if (!task.isCompleted) {
        try {
          this.currentTask = task;
          await for (DownloadTask progressedDownloadTask in task.start()) {
            this.currentTask = progressedDownloadTask;
            await this._showDownloadNotification(
              task: this.currentTask!,
            );
            yield this.currentTask!;
          }
          this._isUnderProgress = false;
          Future.delayed(Duration(seconds: 1), () async {
            this.currentTask!.isCompleted = true;
            await this._showDownloadNotification(
              task: this.currentTask!,
            );
          });
        }
        on DownloadException catch(exception) {
          Future.delayed(Duration(seconds: 1), () async {
            for (DownloadTask task in this._updatedTasks) {
              task.isSuccess = false;
              await this._showDownloadNotification(
                task: task,
              );
              task.onException?.call(exception);
            }
            this.tasks.clear();
            this.currentTask = null;
            this.taskStream = null;
            this._isUnderProgress = false;
            this._isBatchModified = false;
            this._updatedTasks.clear();
          });
          break;
        }
      }
      else {
        await this._showDownloadNotification(
          task: this.currentTask!,
        );
        yield task;
      }
      if (this._isBatchModified) {
        this.taskStream = this._streamCurrentDownloadItem().asBroadcastStream()..listen((task) {});
        break;
      }
    }
  }

  bool _isBatchModified = false;
  List<DownloadTask> _updatedTasks = <DownloadTask>[];
}

final FlutterLocalNotificationsPlugin notification = FlutterLocalNotificationsPlugin();
final InitializationSettings notificationSettings = InitializationSettings(
  android: AndroidInitializationSettings('mipmap/ic_launcher'),
);
