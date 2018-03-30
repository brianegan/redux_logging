library redux_logging;

import 'package:logging/logging.dart';
import 'package:redux/redux.dart';

/// Connects a [Logger] to a Redux Store.
///
/// Every action that is dispatched will be logged to the [Logger], along with
/// the new [State] that was created as a result of the action reaching your
/// [Store]'s reducer.
///
/// By default, this class does not print anything to your console or to a web
/// service, such as Fabric or Sentry. It simply logs entries to a [Logger]
/// instance.
///
/// You can then listen to the [Logger.onRecord] Stream, and print to the
/// console or send these actions to a web service.
///
/// If you simply want to print the latest action and state to your console /
/// terminal, create a `new LoggingMiddleware.printer()` and pass it to your
/// Store upon creation.
///
/// ### Simple Printing example
///
/// If you just want an easy way to print actions as they are dispatched to your
/// console / terminal, use the `new LoggingMiddleware.printer()` factory.
///
///     final store = new Store<int>(
///       (int state, action) => state + 1,
///       initialValue: 0,
///       middleware: [new LoggingMiddleware.printer()]
///     );
///
///     store.dispatch("Hi"); // prints {Action: "Hi", Store: 1, Timestamp: ...}
///
/// ### Example
///
/// If you only want to log actions to a [Logger], use the default constructor.
///
///     // Create your own Logger
///     final logger = new Logger("Redux Logger");
///
///     // Pass it to your Middleware
///     final middleware = new LoggingMiddleware(logger: logger);
///     final store = new Store<int>(
///       (int state, action) => state + 1,
///       initialState: 0,
///       middleware: [middleware],
///     );
///
///     // Note: One quirk about listening to a logger instance is that you're
///     // actually listening to the Singleton instance of *all* loggers.
///     logger.onRecord
///       // Filter down to [LogRecord]s sent to your logger instance
///       .where((record) => record.loggerName == logger.name)
///       // Print them out (or do something more interesting!)
///       .listen((loggingMiddlewareRecord) => print(loggingMiddlewareRecord));
class LoggingMiddleware<State> extends MiddlewareClass<State> {
  /// The [Logger] instance that actions will be logged to.
  final Logger logger;

  /// The log [Level] at which the actions will be recorded
  final Level level;

  /// A function that formats the String for printing
  final MessageFormatter<State> formatter;

  /// The default constructor. It will only log actions to the given [Logger],
  /// but it will not print to the console or anything else.
  LoggingMiddleware({
    Logger logger,
    this.level = Level.INFO,
    this.formatter = singleLineFormatter,
  }) : this.logger = logger ?? new Logger("LoggingMiddleware");

  /// A helper factory for creating a piece of LoggingMiddleware that only
  /// prints to the console.
  factory LoggingMiddleware.printer({
    Logger logger,
    Level level = Level.INFO,
    MessageFormatter<State> formatter = singleLineFormatter,
  }) {
    final middleware = new LoggingMiddleware<State>(
      logger: logger,
      level: level,
      formatter: formatter,
    );

    middleware.logger.onRecord
        .where((record) => record.loggerName == middleware.logger.name)
        .listen(print);

    return middleware;
  }

  /// A simple formatter that puts all data on one line
  static String singleLineFormatter(
    dynamic state,
    dynamic action,
    DateTime timestamp,
  ) {
    return "{Action: $action, State: $state, ts: ${new DateTime.now()}}";
  }

  /// A formatter that puts each attribute on it's own line
  static String multiLineFormatter(
    dynamic state,
    dynamic action,
    DateTime timestamp,
  ) {
    return "{\n" +
        "  Action: $action,\n" +
        "  State: $state,\n" +
        "  Timestamp: ${new DateTime.now()}\n" +
        "}";
  }

  @override
  void call(Store<State> store, dynamic action, NextDispatcher next) {
    next(action);

    logger.log(level, formatter(store.state, action, new DateTime.now()));
  }
}

/// A function that formats the message that will be logged. By default, the
/// action, state, and timestamp will be printed on a single line.
///
/// This package ships with two formatters out of the box:
///
///   - [LoggingMiddleware.singleLineFormatter]
///   - [LoggingMiddleware.multiLineFormatter]
///
/// ### Example
///
///     // Create a formatter that only prints out the dispatched action
///     String onlyLogActionFormatter<State>(
///         State state,
///         action,
///         DateTime timestamp,
///         ) {
///       return "{Action: $action}";
///     }
///
///     // Create your middleware using the formatter.
///     final middleware = new LoggingMiddleware(formatter: onlyLogActionFormatter);
///
///     // Add the middleware to your Store
///     final store = new Store<int>(
///           (int state, action) => state + 1,
///       initialState: 0,
///       middleware: [middleware],
///     );
typedef String MessageFormatter<State>(
  State state,
  dynamic action,
  DateTime timestamp,
);
