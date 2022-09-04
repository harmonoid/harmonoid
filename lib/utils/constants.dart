/// This file is a part of Harmonoid (https://github.com/harmonoid/harmonoid).
///
/// Copyright © 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
/// All rights reserved.
///
/// Use of this source code is governed by the End-User License Agreement for Harmonoid that can be found in the EULA.txt file.
///

/// Play Store listing strips the few features to be compliant with Google Play Store policies.
/// This constant is used to determine whether the app is being compiled for Play Store listing or not.
///
const kPlayStore = bool.fromEnvironment('PLAY_STORE');
