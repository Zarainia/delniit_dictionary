import 'package:delniit_dictionary/constants.dart' as constants;

bool _to_bool(String? value) => value! == "true";

int _to_int(String? value) => int.parse(value!);

double _to_double(String? value) => double.parse(value!);

class Settings {
  String theme_name = "dark";
  double sidebar_width = constants.DRAWER_WIDTH;

  bool regex_search = false;
  bool case_insensitive = true;

  String note = "";

  Settings();

  factory Settings.fromJson(Map<String, String> json) {
    var settings = Settings();
    if (json.containsKey("theme_name")) settings.theme_name = json["theme_name"]!;
    if (json.containsKey("sidebar_width")) settings.sidebar_width = _to_double(json["sidebar_width"]);

    if (json.containsKey("regex_search")) settings.regex_search = _to_bool(json["regex_search"]);
    if (json.containsKey("case_insensitive")) settings.case_insensitive = _to_bool(json["case_insensitive"]);

    if (json.containsKey("note")) settings.note = json["note"]!;

    return settings;
  }

  Map<String, dynamic> toJson() {
    return {
      "theme_name": theme_name,
      "sidebar_width": sidebar_width,
      "regex_search": regex_search,
      "case_insensitive": case_insensitive,
    };
  }
}
