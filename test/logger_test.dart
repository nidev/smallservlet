@TestOn("vm")
import "dart:mirrors";
import "package:test/test.dart";
import "package:smallservlet/src/platform_util.dart";
import "package:smallservlet/src/logger.dart";
import "package:smallservlet/src/log_writer/interface.dart";

/**
 * Specially crafted LogWriter for testing.
 * The instance of this class does print nothing out but store messages in internal buffer.
 * Use message getter to get last written one.
 */
class DummyLogWriter extends LogWriter {
  String _buffer = null;

  String get buffer {
    return _buffer;
  }

  void clearBufferProperty() {
    _buffer = null;
  }

  @override
  void write(String msg) {
    _buffer = msg;
  }

  @override
  void writeLn(String msg) {
    _buffer = msg + PlatformUtil.newLine;
  }
}

void main() {
  group("'Constants validation' test", () {
    test("Has 4 enum values in LOG_LEVELS", () {
      expect(LOG_LEVELS.values.length, equals(4));
    });

    test("Has 4 keys in LOG_LEVELS_FROM_STRING", () {
      expect(LOG_LEVELS_FROM_STRING.length, equals(4));
    });

    test("Has string keys on LOG_LEVELS_FROM_STRING", () {
      ["debug", "notify", "warn", "error"].forEach((name) => expect(LOG_LEVELS_FROM_STRING.containsKey(name), equals(true)));
    });

    test("Has exact matched enum value in LOG_LEVELS_FROM_STRING", () {
      expect(LOG_LEVELS_FROM_STRING["debug"], equals(LOG_LEVELS.DEBUG));
      expect(LOG_LEVELS_FROM_STRING["notify"], equals(LOG_LEVELS.NOTIFY));
      expect(LOG_LEVELS_FROM_STRING["warn"], equals(LOG_LEVELS.WARN));
      expect(LOG_LEVELS_FROM_STRING["error"], equals(LOG_LEVELS.ERROR));
    });
  });

  group("'Logger class global logLevels feature' test", () {
    test("Has all available logLevles enabled", () {
      LOG_LEVELS.values.forEach(
        (logLvEnum) =>
          expect(Logger.logLevels.contains(logLvEnum), equals(true)));
    });
  });

  group("'Logger factory (single instance per tag)' test", () {
    final String TAG = "testLogger";
    final String A_DIFFERENT_TAG = "examLogger";

    Logger testLogger;
    setUp(() => testLogger = new Logger(TAG));

    test("Checks same hashCode on previous and new logger on same tag", () {
      Logger testLogger_sameTag = new Logger(TAG);
      expect(testLogger.hashCode, equals(testLogger_sameTag.hashCode));
    });

    test("Checks same hashCode on previous and new logger on same tag", () {
      Logger testLogger_differentTag = new Logger(A_DIFFERENT_TAG);
      expect(testLogger.hashCode, isNot(equals(testLogger_differentTag.hashCode)));
    });

    tearDown(() => testLogger = null);
  });

  group("'Logging level control' test", () {
    final String TAG = "testLogger_logLevel";
    final Map<LOG_LEVELS, Symbol> reflectionSyms = {
      LOG_LEVELS.DEBUG: #d,
      LOG_LEVELS.NOTIFY: #n,
      LOG_LEVELS.WARN: #w,
      LOG_LEVELS.ERROR: #e
    };

    DummyLogWriter dummyLogWriter = new DummyLogWriter();
    Logger testLogger = new Logger(TAG, logWriter: dummyLogWriter);


    setUp(() => Logger.logLevels.clear());

    test("Logs nothing when no level is enabled", () {
      expect(Logger.logLevels.isEmpty, isTrue);

      InstanceMirror im = reflect(testLogger);
      reflectionSyms.values.forEach((symbol) {
        dummyLogWriter.clearBufferProperty();
        
        im.invoke(symbol, [""]);
        expect(dummyLogWriter._buffer, isNull);
      });
    });

    test("Logs only that level when that is the only one enabled", () { 
      reflectionSyms.forEach((lvEnum, logFnSym) {
        Logger.logLevels.clear();
        expect(Logger.logLevels.isEmpty, isTrue);

        Logger.logLevels.add(lvEnum);
        expect(Logger.logLevels.contains(lvEnum), isTrue);

        InstanceMirror im = reflect(testLogger);
        reflectionSyms.values.forEach((symbol) {
          dummyLogWriter.clearBufferProperty();
          
          im.invoke(symbol, ["A"]);
          if (symbol == logFnSym) {
            expect(dummyLogWriter._buffer, allOf(isNotNull));
          }
          else {
            expect(dummyLogWriter._buffer, isNull);
          }
        });
      });
    });
  });
}