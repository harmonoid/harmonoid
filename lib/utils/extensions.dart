/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Yehuda Kremer <yehudakremer@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///
extension IterableExtension<T> on Iterable<T> {
  /// Return distinct array by comparing hash codes.
  Iterable<T> distinct() {
    var distinct = <T>[];
    this.forEach((element) {
      if (!distinct.contains(element)) distinct.add(element);
    });

    return distinct;
  }
}
