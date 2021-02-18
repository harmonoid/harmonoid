import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:harmonoid/main.dart';
import 'package:harmonoid/language/constants.dart';

Download download;


class DownloadTask {
  final Uri fileUri;
  final File saveLocation;
  final void Function(double progress) onProgress;
  final void Function() onCompleted;
  final dynamic extras;
  int downloadId;
  bool isStarted = false;
  bool isCompleted = false;
  int downloadedSize = 0;
  int fileSize = 0;
  double progress = 0.0;
  bool isSuccess = true;
  http.StreamedResponse _responseStream;

  DownloadTask({@required this.fileUri, @required this.saveLocation, this.downloadId, this.fileSize, this.extras, this.onProgress, this.onCompleted});

  Stream<DownloadTask> start() async* {
    http.Client httpClient = new http.Client();
    var streamConsumer = this.saveLocation.openWrite();
    this._responseStream = await httpClient.send(
      new http.Request('GET', this.fileUri),
    );
    this.fileSize = this._responseStream.contentLength;
    await for (List<int> responseChunk in this._responseStream.stream) {
      this.downloadedSize += responseChunk.length;
      if (this._responseStream.statusCode >= 200 && this._responseStream.statusCode < 300) {
        streamConsumer.add(responseChunk);
        this.progress = this.downloadedSize / this.fileSize;
        this.onProgress?.call(this.progress);
        yield this;
      }
      else {
        this.isSuccess = false;
        httpClient.close();
        if (await this.saveLocation.exists()) this.saveLocation.delete();
        throw 'Invalid status code: ${this._responseStream.statusCode}';
      }
    }
    if (this.isSuccess) {
      streamConsumer.close();
      this.isCompleted = true;
      this.onCompleted?.call();
    }
    yield this;
  }
}


class Download {
  List<DownloadTask> tasks = <DownloadTask>[];
  DownloadTask currentTask;
  Stream<DownloadTask> taskStream;
  bool isUnderProgress = false;

  String _toMegaBytes(int size) {
    return (size / (1024 * 1024)).toStringAsFixed(2);
  }

  Future<void> _showDownloadNotification({DownloadTask task}) async {
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
        ongoing: !task.isCompleted,
        showWhen: false,
        onlyAlertOnce: true,
        playSound: false,
        enableVibration: false,
      ),
    );
    await notification.show(
      task.downloadId,
      task.extras.trackName,
      task.isCompleted ? '${Constants.STRING_DOWNLOAD_COMPLETED}. ' : '' + '${this._toMegaBytes(task.downloadedSize)}/${this._toMegaBytes(task.fileSize)} MB',
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
    if (!this.isUnderProgress) this.start();
    this._isBatchModified = true;
    task.downloadId = this.tasks.length + 1;
    this.tasks.add(task);
  }

  void addTasks(List<DownloadTask> tasks, {bool start: true}) {
    if (!this.isUnderProgress) this.start();
    this._isBatchModified = true;
    tasks.map((DownloadTask task) {
      task.downloadId = this.tasks.length + 1;
      this.tasks.add(task);
    });
  }

  Stream<DownloadTask> _streamCurrentDownloadItem() async* {
    this._isBatchModified = false;
    this.isUnderProgress = true;
    for (DownloadTask task in this.tasks) {
      if (!task.isCompleted) {
        await for (DownloadTask progressedDownloadTask in task.start()) {
          this.currentTask = progressedDownloadTask;
          await this._showDownloadNotification(
            task: this.currentTask,
          );
          yield this.currentTask;
        }
        this.isUnderProgress = false;
        Future.delayed(Duration(seconds: 1), () async {
          this.currentTask.isCompleted = true;
          await this._showDownloadNotification(
            task: this.currentTask,
          );
        });
      }
      else {
        await this._showDownloadNotification(
          task: this.currentTask,
        );
        yield task;
      }
      if (this._isBatchModified) {
        this.taskStream = this._streamCurrentDownloadItem().asBroadcastStream();
      }
    }
  }

  bool _isBatchModified = false;
}
