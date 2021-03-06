import "dart:convert";
import "dart:io";
import "dart:async";
import "package:smallservlet/src/platform_util.dart";
import "package:smallservlet/src/logger.dart";
import "package:yaml/yaml.dart" as Yaml;
import "package:path/path.dart" as Path;

const String TAG = "Config";
const String CFG_BIND__HOST = "bind.host";
const String CFG_BIND__PORT = "bind.port";
const String CFG_CACHE__SIZE = "cache.size";
const String CFG_CACHE__LIFESECONDS = "cache.lifeseconds";
const String CFG_REDIS__HOST = "redis.host";
const String CFG_REDIS__PORT = "redis.port";
const String CFG_REDIS__KEY = "redis.key";
const String CFG_REDIS__PASSWORD = "redis.password";
const String CFG_LOGLEVELS = "loglevels";
const String CFG_MAX_CONNECTION = "max_connection";
const String CFG_ROOTDIR = "rootdir";

const List<String> ConfigurationKeys = const [
  CFG_BIND__HOST,
  CFG_BIND__PORT,
  CFG_CACHE__SIZE,
  CFG_CACHE__LIFESECONDS,
  CFG_REDIS__HOST,
  CFG_REDIS__PORT,
  CFG_REDIS__PASSWORD,
  CFG_REDIS__KEY,
  CFG_LOGLEVELS,
  CFG_MAX_CONNECTION,
  CFG_ROOTDIR
];

class SSConfiguration {
  String _Filename;
  String _Dir;
  Map<String, Object> _configMap;

  SSConfiguration() {
    _Filename = "-memory-";
    _Dir = ":memory:";

    // Initializing
    _configMap = new Map<String, Object>.fromIterable(ConfigurationKeys,
      key: (anyObject) => anyObject.toString(),
      value: (anyObject) => ""
    );
  }

  SSConfiguration.fromFile(String dir, String fname) {
    _Dir = dir;
    _Filename = fname;

    String contents = _readFile();

    if (fname.endsWith(".json")) {
      var jsonDecoder = new JsonDecoder();
      _configMap = jsonDecoder.convert(contents);
    }
    else if (fname.endsWith(".yaml")) {
      _configMap = Yaml.loadYaml(contents);
    }
    else {
      throw new Exception("Unsupported file extension. Should be either .json or .yaml");
    }

    if (!_validateConfigMap(_configMap)) {
      throw new Exception("Configuration validation failed. See above warnings.");
    }
  }

  bool _validateConfigMap(Map<String, Object> map) {
    Logger log = new Logger("Config");

    List<String> insufficients = [];
    List<String> unused_keys = [];

    ConfigurationKeys.forEach((key) {
      if (!map.containsKey(key)) {
        log.w("Missing required key: ${key}");
        insufficients.add(key);
      }
    });

    map.keys.forEach((key) {
      if (!ConfigurationKeys.contains(key)) {
        log.w("Unused key: ${key}");
        unused_keys.add(key);
      }
    });

    return (insufficients.length == 0);
  }

  String _readFile() {
    File srcFile = new File(Path.join(_Dir, _Filename));

    if (srcFile.existsSync()) {
      return srcFile.readAsStringSync();
    }
    else {
      throw new Exception("File not exist for loading configuration: ${Path.join(_Dir, _Filename)}");
    }
  }

  Future<File> writeToJSON(String dir, String filename) async {
    File targetFile = new File(Path.join(dir, filename));
    Logger log = new Logger(TAG);

    if (await targetFile.exists()) {
      log.w("File exists. Writing configuration will overwrite the file: ${filename}");
    }

    JsonEncoder encoder = new JsonEncoder.withIndent("  ", (unencodable) => "");

    String serialized = encoder.convert(_configMap).replaceAll("\n", PlatformUtil.newLine);

    return targetFile.writeAsString(serialized,
      mode: FileMode.write,
      encoding: Encoding.getByName("UTF-8"),
      flush: true);
  }

  Future<File> writeToYAML(String dir, String filename) async {
    File targetFile = new File(Path.join(dir, filename));
    Logger log = new Logger(TAG);

    if (await targetFile.exists()) {
      log.w("File exists. Writing configuration will overwrite the file: ${filename}");
    }

    StringBuffer stringBuffer = new StringBuffer();
    _configMap.forEach((key, value) {
      stringBuffer.write("${key}: ${value.toString()}");
      stringBuffer.write(PlatformUtil.newLine);
    });

    return targetFile.writeAsString(stringBuffer.toString(),
      mode: FileMode.write,
      encoding: Encoding.getByName("UTF-8"),
      flush: true);
  }

  /**
   * If value can be converted to number, this will return number type.
   * In other cases, this function returns String with no exception.
   */
  dynamic operator[](String key) {
    RegExp goodNumber = new RegExp(r"^[0-9]+$");
    String value = _configMap[key].toString();

    if (goodNumber.hasMatch(value)) {
      return int.parse(value);
    }

    return value;
  }
}
