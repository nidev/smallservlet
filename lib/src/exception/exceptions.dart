// encoding: utf-8

/// Base class for SmallServlet
/// BaseError contains 3 fields: when(When the error is created), errorMsg and errorReference(Reference link or document ID).
/// None of those fields is mandatory. You may just create an object from this class and just let it be thrown.
/// Extend BaseError to display various error message, see [PatternCompilerError].
class BaseError {
  /// The DateTime represents when this object is constructed. (Automatically created, immutable)
  final DateTime when;
  /// Error message (optional, immutable since created)
  final String errorMsg;
  /// Error reference link or document ID (optional, immutable since created)
  final String errorReference;

  BaseError([String errorMsg = "", String reference = ""]) :
    when = new DateTime.now(),
    errorMsg = errorMsg,
    errorReference = reference;
}

class SmallServletError extends BaseError {}

class PatternCompilerError extends BaseError {
  PatternCompilerError(String errorMsg, [int rowNum = 0, int columnNum = 0]) : super("$errorMsg at line $rowNum, column $columnNum.");
}
