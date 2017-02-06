// encoding: utf-8
const String TAG = "Version";

const VERSION_MAJOR = 1;
const VERSION_MINOR = 0;
const String VERSION_STRING = "${VERSION_MAJOR}.${VERSION_MINOR}";

enum VersionComparisonResult { HIGHER, EQUAL, LOWER }

/**
 *
 */
class VersionData {
  int major = 0;
  int minor = 0;

  VersionData(this.major, this.minor);
  VersionData.fromString(String version) {
    List<String> splitString = version.split(".");
    if (splitString.length != 2) {
      throw new Exception("Expect a version string (format: X.YY)");
    }

    major = int.parse(splitString[0]);
    minor = int.parse(splitString[1]);
  }

  bool operator<(VersionData other) {
    return (this.major < other.major)
      || (this.major == other.major && this.minor <= other.minor);
  }

  bool operator==(VersionData other) {
    return (this.major == other.major && this.minor == other.minor);
  }

  bool operator>(VersionData other) {
    return (this.major > other.major)
      || (this.major == other.major && this.minor >= other.minor);
  }

  bool operator>=(VersionData other) {
    return this > other || this == other;
  }

  bool operator <=(VersionData other) {
    return this < other || this == other;
  }

  String toString() {
    return "${this.major}.${this.minor}";
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
