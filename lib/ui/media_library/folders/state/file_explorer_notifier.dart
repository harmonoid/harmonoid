import 'package:adaptive_layouts/adaptive_layouts.dart';
import 'package:flutter/widgets.dart';
import 'package:harmonoid/core/configuration/configuration.dart';

class FileExplorerNotifier extends ChangeNotifier {
  FileExplorerNotifier();

  FileExplorerViewType viewType = Configuration.instance.mediaLibraryFolderFileExplorerViewType;
  FileExplorerSortType sortType = Configuration.instance.mediaLibraryFolderFileExplorerSortType;
  bool sortAscending = Configuration.instance.mediaLibraryFolderFileExplorerSortAscending;
  bool showHiddenFiles = Configuration.instance.mediaLibraryFolderFileExplorerShowHiddenFiles;

  void setViewType(FileExplorerViewType value) {
    viewType = value;
    notifyListeners();
    Configuration.instance.set(mediaLibraryFolderFileExplorerViewType: value);
  }

  void setSortType(FileExplorerSortType value) {
    sortType = value;
    notifyListeners();
    Configuration.instance.set(mediaLibraryFolderFileExplorerSortType: value);
  }

  void setSortAscending(bool value) {
    sortAscending = value;
    notifyListeners();
    Configuration.instance.set(mediaLibraryFolderFileExplorerSortAscending: value);
  }

  void setShowHiddenFiles(bool value) {
    showHiddenFiles = value;
    notifyListeners();
    Configuration.instance.set(mediaLibraryFolderFileExplorerShowHiddenFiles: value);
  }
}
