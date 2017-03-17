// encoding: utf-8

library route_component;

import "dart:convert";
import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/exception/exceptions.dart";

const String TAG = "PCompiler";

/// Compiler Instruction for URL pattern compiler
enum CompilerInst {
  /// 'M'atch given string
  M,
  /// 'E'xtract string from matched pattern
  E,
  /// 'A'll pattern (*)
  A,
  /// 'T'erminal token, *.dart file
  T
}

/// URL pattern compiler
/// This class will compile URL (in String) to Pattern object.
///
/// Path separator is forward slash (/). Space(s) after/before pattern will be trimmed.
///
/// Following patterns are available and valid:
/// 1. * (Only allowed at tail. Only one occurrence is allowed. i.e. pattern '/users/*' is valid and will hook everything)
/// 2. / (translated into /index.dart)
/// 3. /users (translated into /users.dart)
/// 4. /users/ (translated into /users/index.dart)
/// 5. /users/{name} (translated into /users.dart with params = {name: (name here)})
/// 6. /users/account_info/{name} (translated into /users/account_info.dart with params = {name: (name here)})
/// 7. /users/account_info.dart/{name} (Sure, this is valid.)
/// 8. /users/account_info/{name}/{location}
/// (translated into /users/account_info.dart with params = {name: (name here), location: (location here)}. Only allows consecuted template(s). See below.)
/// 9. And with query string(?key1=value1&key2=value2...) with above patterns
///
/// Following patterns are not valid:
/// 1. Mixing .. or . in either pattern or URL
/// (not allowed for security reason)
/// 2. /users/{name}/not_admin/{name}
/// (Can not recognize which one is exact Dart-based servlet)
/// 3. /users/{full name}/{previous location}
/// (Do not include space directly for template name. If space is encoded with percent encoding, it is okay)
/// 4. /users/add/{なまえ}/{生日}/{사는곳}
/// (Non-ASCII characters in parameter template name, but parameter values with Non-ASCII characters are allowed when they are encoded in percent encoding.)
class URLPatternCompiler {
  static final RegExp _unwrapper = new RegExp(r"\{([a-zA-Z0-9%]+)\}");
  static final RegExp _leadingdots = new RegExp(r"^[.]+");

  List<CompilerInst> _inst;
  List<String> _matcher;

  String _dartLocation;

  String get dartLocation {
    return _dartLocation;
  }

  String get servletPath {
    return _dartLocation.substring(0, _dartLocation.length - 5);
  }

  URLPatternCompiler(String source) {
    _inst = new List<CompilerInst>();
    _matcher = new List<String>();

    _compileMatcher(source);

    if (_inst.length != _matcher.length) {
      var log = new Logger(TAG);

      log.e("Compilation failed. This can be a bug of URLPatternCompiler.");
      log.e("Compiled Instruction Array: ${_inst}");
      log.e("Compiled Matcher Array: ${_matcher}");

      throw new PatternCompilerError("Compilation failed due to compiler error. Please file this bug");
    }
  }
  void _pushData(CompilerInst inst, String stringMatched) {
    _inst.add(inst);
    _matcher.add(stringMatched);
  }

  void _compileMatcher(String pattern) {
    var tokens = pattern.split("/");
    var rebuiltPath = <String>[];
    var noMorePath = false;
    var pos_patternString = 0;

    for (var index = 0, length = tokens.length; index < length; index++) {
      var token = tokens[index];

      pos_patternString++;

      // Accept only one asterisk, at tail position
      if (token == "*") {
        if (!noMorePath) {
          _pushData(CompilerInst.A, token);

          rebuiltPath.add(token);
          break;
        }
        else {
          throw new PatternCompilerError("Since template string started, you can not use more asterisk in pattern.", 1, pos_patternString);
        }
      }

      // Disallow using dots(., ..) or leading dots (.file, ..file) in pattern
      if (_leadingdots.hasMatch(token)) {
        throw new PatternCompilerError("Leading dot(s) in pattern is not allowed", 1, pos_patternString);
      }

      if (token.startsWith("{")) {
        // validating closing curly bracket
        if (!token.endsWith("}")) {
          throw new PatternCompilerError("Enclose template brackets correctly, incorrect now. ($token)", 1, pos_patternString);
        }

        // last added path is a Dart servlet. This will conclude accepting
        // servlet path.
        noMorePath = true;

        if (rebuiltPath.isEmpty) {
          // This one will be a index.dart
          rebuiltPath.add("");

          _pushData(CompilerInst.T, "");
        }
        else {
          if (!rebuiltPath.last.endsWith(".dart")) {
            // Make last path item to Dart servlet

            var servlet = rebuiltPath.last + ".dart";

            // Make last item has '.dart' extension
            rebuiltPath.removeLast();
            rebuiltPath.add(servlet);

            // Make last item as a terminal item
            _inst.removeLast();
            _inst.add(CompilerInst.T);
          }
        }

        // And match place...
        Match unwrapped = _unwrapper.firstMatch(token);
        if ((unwrapped?.groupCount ?? 0) == 1) {
          pos_patternString += pattern.length;

          var templateName = unwrapped.group(1);

          _pushData(CompilerInst.E, templateName);
        }
        else {
          // Void template name
          throw new PatternCompilerError("Template name can not be empty or filled with space", 1, pos_patternString);
        }
      }
      else {
        // Check whether it can accept more path item
        if (noMorePath) {
          throw new PatternCompilerError("Can not accept more path, as template matching started before", 1, pos_patternString);
        }

        // detecting dangling brackets
        if (token.allMatches("[\{\}]")) {
          throw new PatternCompilerError("Incomplete template bracket(s) are found. ($pattern)", 1, pos_patternString);
        }

        if (token.isNotEmpty) {
          pos_patternString += pattern.length;
          rebuiltPath.add(token);
          _pushData(CompilerInst.M, token);
        }
        else {
          //noMorePath = true;
          rebuiltPath.add("");
          _pushData(CompilerInst.M, "");
        }
      }
    }

    if (rebuiltPath.last.isEmpty) {
      rebuiltPath.removeLast();
      rebuiltPath.add("index.dart");
    }

    _dartLocation = rebuiltPath.join("/");

    if (!_dartLocation.startsWith("/")) {
      _dartLocation = "/$_dartLocation";
    }
  }

  /// Process given path and return extracted parameteres including URL query params.
  /// If servlet path of given one does not equal to compiled one, this function will
  /// throw PatternCompilerError.
  Map<String, String> parse(String urlPath) {
    var basePath = urlPath.trim().split("?");
    var pathTokens = basePath[0].split("/");
    var rebuiltPath = <String>[];
    var rebuiltParam = <String, String>{};
    var pos_pathString = 0;
    var foundAsteriskMatching = false;

    try {
      for (var index = 0, length = pathTokens.length; index < length; index++) {
        var path = pathTokens[index];

        // Disallow using dots(., ..) or leading dots (.file, ..file) in path
        if (_leadingdots.hasMatch(path)) {
          throw new PatternCompilerError("Leading dot(s) in path is not allowed", 1, pos_pathString);
        }

        var inst = _inst[index];
        var matcher = _matcher[index];

        switch (inst) {
          case CompilerInst.M:
            if (path == matcher) {
              rebuiltPath.add(path);
            }
            else {
              throw new PatternCompilerError("Unmatched URL. (Expected: ${matcher}, Got: ${path})");
            }
            break;
          case CompilerInst.E:
            rebuiltParam[matcher] = path;
            break;
          case CompilerInst.A:
            foundAsteriskMatching = true;
            rebuiltPath.add(matcher);
            throw matcher; // expect '*' for this case.
            break;
          case CompilerInst.T:
            if (path == matcher) {
              if (!path.endsWith(".dart")) {
                path = "${path}.dart";
              }
              rebuiltPath.add(path);
            }
            else {
              throw new PatternCompilerError("Unmatched terminator. (Expected: ${matcher}, Got: ${path})");
            }
            break;
          default:
            ;
        }
      }
    }
    on PatternCompilerError catch (_) {
      rethrow;
    }
    catch (_) {
      // Nothing to do, for breaking nested loop
    }

    if (rebuiltPath.last.isEmpty) {
      rebuiltPath.removeLast();
      rebuiltPath.add("index.dart");
    }

    var parseddartLocation = rebuiltPath.join("/");

    if (!parseddartLocation.startsWith("/")) {
      parseddartLocation = "/${parseddartLocation}";
    }

    if (!foundAsteriskMatching && parseddartLocation != _dartLocation) {
      print(_inst);
      print(_matcher);
      print(_matcher.length);
      throw new PatternCompilerError("Unmatched dart servlet location (Expected: ${_dartLocation}, Got: ${parseddartLocation})");
    }

    // if urlPath has query string, parse it and add result to params
    if (basePath.length == 2) {
      // TODO: Get Encoding from configuration
      var param = Uri.splitQueryString(basePath[1], encoding: UTF8);
      rebuiltParam.addAll(param);
    }

    return rebuiltParam;
  }

  /// If testUrl starts with compiled servletPath, this servlet may respond with parsed data.
  bool respondable(String testUrl) {
    return testUrl.startsWith(servletPath);
  }
}
