import json


def to_camel_case(snake_str):
    components = snake_str.split("_")
    return components[0] + "".join(x.title() for x in components[1:])


def to_upper_camel_case(snake_str):
    return "".join(x.title() for x in snake_str.split("_"))


def configuration_gen(json_data):
    class_content = []
    getter_methods = []
    set_method_content = []
    get_defaults_method_content = []
    private_fields = []
    keys = []

    for item in json_data:
        key = item["key"]
        dart_type = item["dartType"]
        camel_case_key = to_camel_case(key.lower())
        getter_methods.append(
            f"  {dart_type} get {camel_case_key} => _{camel_case_key}!;"
        )

        value = camel_case_key
        if item['serializedType'] == 'Integer' and item['dartType'] != 'int':
            value = f'{camel_case_key}.index'
        if item['serializedType'] == 'Json' and item['dartType'].startswith('Set<') and item['dartType'].endswith('>'):
            value = f'{camel_case_key}.toJson()'

        set_method_content.append(
            f"""    if ({camel_case_key} != null) {{
      _{camel_case_key} = {camel_case_key};
      await db.setValue(kKey{to_upper_camel_case(key)}, kType{item['serializedType']}, {item['serializedType'].lower()}Value: {value});
    }}"""
        )
        get_defaults_method_content.append(
            f"      /* {item['serializedType'].ljust(7)} */ kKey{to_upper_camel_case(key)}: {item['default']},"
        )
        private_fields.append(f"  {dart_type}? _{camel_case_key};")
        keys.append(f"const kKey{to_upper_camel_case(key)} = '{key}';")
    class_content = [
        "// AUTO GENERATED FILE, DO NOT EDIT.",
        "",
        "part of 'configuration.dart';",
        "",
        "class ConfigurationBase {",
        "",
        "  final Directory directory;",
        "  final Database db;",
        "",
        "  static bool get isMobile => Platform.isAndroid || Platform.isIOS;",
        "  static bool get isDesktop => Platform.isLinux || Platform.isMacOS || Platform.isWindows;",
        "",
        "  ConfigurationBase({required this.directory, required this.db});",
        "",
        "\n".join(getter_methods),
        "",
        "  Future<void> set({",
        ",\n".join(
            f"    {item['dartType']}? {to_camel_case(item['key'].lower())}"
            for item in json_data
        )
        + ",",
        "  }) async {",
        "\n".join(set_method_content),
        "  }",
        "",
        "  Future<Map<String, dynamic>> getDefaults() async {",
        "    return {",
        "\n".join(get_defaults_method_content),
        "    };",
        "  }",
        "",
        "\n".join(private_fields),
        "}",
        "",
        "// ----- Keys -----",
        "",
        "\n".join(keys),
        "",
    ]

    return "\n".join(class_content)


if __name__ == "__main__":
    input_file = "configuration_keys.json"
    output_file = "../lib/core/configuration/configuration.g.dart"
    input = open(input_file, "r")
    output = open(output_file, "w")
    output.write(configuration_gen(json.loads(input.read())))
