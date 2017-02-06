// encoding: utf-8
const String TAG = "Version";

const VERSION_MAJOR = 1;
const VERSION_MINOR = 0;
const String VERSION_STRING = "${VERSION_MAJOR}.${VERSION_MINOR}";

enum VersionComparisonResult { HIGHER, EQUAL, LOWER }

/**
 *
 */
class VersionData implements Comparable {
  int _major = 0;
  int _minor = 0;

  VersionData(this._major, this._minor);
  VersionData.fromString(String version) {
    List<String> splitString = version.split(".");
    if (splitString.length != 2) {
      throw new Exception("Expect a version string (format: X.YY)");
    }

    _major = int.parse(splitString[0]);
    _minor = int.parse(splitString[1]);
  }

  bool operator<(VersionData other) {
    return (this._major < other._major)
      || (this._major == other._major && this._minor <= other._minor);
  }

  bool operator==(VersionData other) {
    return (this._major == other._major && this._minor == other._minor);
  }

  bool operator>(VersionData other) {
    return (this._major > other._major)
      || (this._major == other._major && this._minor >= other._minor);
  }

  bool operator>=(VersionData other) {
    return this > other || this == other;
  }

  bool operator <=(VersionData other) {
    return this < other || this == other;
  }

  int getMajorVersion() => _major;
  int getMinorVersion() => _minor;

  @override
  String toString() {
    return "${this._major}.${this._minor}";
  }

  @override
  int compareTo(other) {
    if (this < other) {
      return -1;
    }
    else if (this == other) {
      return 0;
    }
    else {
      return -1;
    }
  }
}

/**
 *
 */
VersionComparisonResult compareVersionString(String from, String to) {
  VersionData a = new VersionData.fromString(from);
  VersionData b = new VersionData.fromString(to);

  if (a > b) {
    return VersionComparisonResult.HIGHER;
  }
  else if (a == b) {
    return VersionComparisonResult.EQUAL;
  }
  else {
    return VersionComparisonResult.LOWER;
  }
}

/**
 *
 */
VersionData getPackageVersion() {
  return new VersionData(VERSION_MAJOR, VERSION_MINOR);
}
