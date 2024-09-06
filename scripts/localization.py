import os
import sys
import json


def localization():
    operation = sys.argv[1]
    if operation == "add":
        key, value = sys.argv[2], sys.argv[3]
        if input(f"Add {key} = {value}?\n").upper() != "Y":
            return 
    if operation == "remove":
        key, value = sys.argv[2], None
        if input(f"Remove {key}?\n").upper() != "Y":
            return

    file_names = os.listdir("../assets/localizations/localizations")

    for file_name in file_names:
        if file_name.endswith(".json") and not file_name.startswith("index"):
            file_path = f"../assets/localizations/localizations/{file_name}"

            keys: list[str] = []
            localization: dict[str, str] = {}

            with open(file_path, "r", encoding="utf_8", errors="ignore") as file:
                localization = dict(sorted(dict(json.loads(file.read())).items()))
                keys = list(localization.keys())

            if value is not None:
                localization[key] = value
            else:
                localization.pop(key, None)

            with open(file_path, "w", encoding="utf_8", errors="ignore") as file:
                file.write(json.dumps(dict(sorted(localization.items())), indent=2, ensure_ascii=False) + "\n")

            with open("../lib/localization/values.g.dart", "w", encoding="utf_8", errors="ignore") as file:
                contents = [
                    "// AUTO GENERATED FILE, DO NOT EDIT.",
                    "",
                    "// ignore_for_file: non_constant_identifier_names",
                    "",
                    "part of 'localization.dart';",
                    "",
                    "class Values {",
                    "\n".join(f"  late String {key};" for key in keys),
                    "}",
                    "",
                ]
                file.write("\n".join(contents))

            with open("../lib/localization/localization.g.dart", "w", encoding="utf_8", errors="ignore") as file:
                contents = [
                    "// AUTO GENERATED FILE, DO NOT EDIT.",
                    "",
                    "part of 'localization.dart';",
                    "",
                    "class LocalizationBase extends Values {",
                    "",
                    "  late LocalizationData current;",
                    "",
                    "  Future<void> set({required LocalizationData value}) async {",
                    "    final data = await rootBundle.loadString('assets/translations/translations/${value.code}.json');",
                    "    final map = json.decode(data);",
                    "\n".join(f"    {key} = map['{key}']!;" for key in keys),
                    "  }",
                    "}",
                    "",
                ]
                file.write("\n".join(contents))


if __name__ == "__main__":
    localization()
