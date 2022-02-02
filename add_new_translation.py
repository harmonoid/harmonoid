import os
import sys
import json

if __name__ == "__main__":
    string, value = sys.argv[1], sys.argv[2]
    keys = []
    if input(f"Add {string} = {value}?\n") in ["y", "Y"]:
        file_names = os.listdir("assets/translations")
        for file_name in file_names:
            with open(
                f"assets/translations/{file_name}",
                "r+",
                encoding="utf_8",
                errors="ignore",
            ) as file:
                language = dict(json.loads(file.read()))
                try:
                    Language.instance.pop("PLAYLISTS")
                except:
                    pass
                language[string] = value
                keys = list(Language.instance.keys())
                file.seek(0)
                file.write(
                    json.dumps(
                        dict(sorted(Language.instance.items())),
                        indent=2,
                        ensure_ascii=False,
                    )
                    + "\n"
                )
        keys.sort()
        with open(
            "lib/constants/strings.dart", "w", encoding="utf_8", errors="ignore"
        ) as file:
            file.write(
                """/* 
 *  This file is part of Harmonoid (https://github.com/harmonoid/harmonoid).
 *  
 *  Harmonoid is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *  
 *  Harmonoid is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *  
 *  You should have received a copy of the GNU General Public License
 *  along with Harmonoid. If not, see <https://www.gnu.org/licenses/>.
 * 
 *  Copyright 2020-2022, Hitesh Kumar Saini <saini123hitesh@gmail.com>.
 */

// ignore_for_file: non_constant_identifier_names

class Strings {
"""
            )
            for key in keys:
                file.write(f"  late String {key};\n")
            file.write("}\n")
        with open(
            "lib/constants/language.dart", "r+", encoding="utf_8", errors="ignore"
        ) as file:
            contents = file.read()
            file.seek(0)
            file.write(
                contents.split("var asset = jsonDecode(string);")[0]
                + "var asset = jsonDecode(string);\n"
            )
            for key in keys:
                file.write(f"    this.{key} = asset['{key}']!;\n")
            file.write(
                """    Configuration.instance.save(languageRegion: languageRegion);
    this.current = languageRegion;
    this.notifyListeners();
  }

  late LanguageRegion current;

  @override
  // ignore: must_call_super
  void dispose() {}
}
"""
            )
