import os
import sys
import json

if __name__ == "__main__":
    string = sys.argv[1]
    keys = []
    if input(f"Remove {string}?\n") in ["y", "Y"]:
        file_names = os.listdir("assets/translations/translations")
        for file_name in file_names:
            if ".json" in file_name and file_name != "index.json":
                with open(
                    f"assets/translations/translations/{file_name}",
                    "r+",
                    encoding="utf_8",
                    errors="ignore",
                ) as file:
                    language = dict(json.loads(file.read()))
                    file.close()
                    language.pop(string)
                    keys = list(language.keys())
                    with open(
                        f"assets/translations/translations/{file_name}",
                        "w",
                        encoding="utf_8",
                        errors="ignore",
                    ) as writeable:
                        writeable.write(
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
                    """// ignore_for_file: non_constant_identifier_names

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
                file.close()
                with open(
                    "lib/constants/language.dart",
                    "r+",
                    encoding="utf_8",
                    errors="ignore",
                ) as writeable:
                    writeable.write(
                        contents.split("final map = json.decode(data);")[0]
                        + "final map = json.decode(data);\n"
                    )
                    for key in keys:
                        writeable.write(f"    {key} = map['{key}']!;\n")
                    writeable.write(
                        """    current = value;
    notifyListeners();
  }

  /// Currently selected & displayed [Language].
  late LanguageData current;

  @override
  // ignore: must_call_super
  void dispose() {}
}
"""
                    )
