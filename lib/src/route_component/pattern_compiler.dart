// encoding: utf-8

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
/// 1. Mixing .. or . in pattern
/// (not allowed for security reason)
/// 2. /users/{name}/not_admin/{name}
/// (Can not recognize which one is exact Dart-based servlet)
/// 3. /users/{full name}/{previous location}
/// (Do not include space directly for template name. If space is encoded with percent encoding, it is okay)
/// 4. /users/add/{なまえ}/{生日}/{사는곳}
/// (Non-ASCII characters in parameter template name, but parameter values with Non-ASCII characters are allowed when they are encoded in percent encoding.)
class URLPattern {
  URLPattern() {
    throw new UnimplementedError();
  }

  URLPattern.compileFromString(String pattern) {
    throw new UnimplementedError();
  }
}