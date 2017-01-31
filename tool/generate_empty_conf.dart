// encoding: utf-8
import "dart:io";
import "package:path/path.dart" as Path;
import "package:smallservlet/src/config.dart";

final String SCRIPT_NAME = Path.basename(Platform.script.path);
const List<String> SUPPORTED_EXTENSIONS = const [".json", ".yaml"];

void main(List<String> arguments) {
  if (arguments.length == 0) {
    print("Configuration generator for SmallServlet");
    print("Usage:");
    print("    ${SCRIPT_NAME} (filename).json");
    print("    ${SCRIPT_NAME} (filename).yaml");
    exit(255);
  }

  final String fileName = arguments[0];
  final String estimatedOutputFormat = Path.extension(fileName).toLowerCase();

  SSConfiguration config = new SSConfiguration();

  switch (estimatedOutputFormat) {
    case ".json":
      config.writeToJSON(".", fileName).then((file) => "Saved");
      break;
    case ".yaml":
      config.writeToYAML(".", fileName).then((file) => "Saved");
      break;
    default:
      print("Unsupported format: ${estimatedOutputFormat}");
      exit(255);
  }

  print("Done");
}
