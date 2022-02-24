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
                language[string] = value
                keys = list(language.keys())
                file.seek(0)
                file.write(
                    json.dumps(
                        dict(sorted(language.items())),
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
                """/*class Strings {
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
