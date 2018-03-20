# redux_logging

[![Build Status](https://travis-ci.org/brianegan/redux_logging.svg?branch=master)](https://travis-ci.org/brianegan/redux_logging) [![codecov](https://codecov.io/gh/brianegan/redux_logging/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/redux_logging)

Connects a [Logger](https://pub.dartlang.org/packages/logging) to a [Redux](https://pub.dartlang.org/packages/redux) Store. Can also simply print the latest state / action changes.

Logs every Action that is dispatched to the Store, along with the current `State`.

By default, this class does not print anything to your console or send data to a web service, such as Fabric or Sentry. It simply logs entries to a `Logger` instance.

If you simply want to print the latest action and state to your console / terminal, create a `new LoggingMiddleware.printer()` and pass it to your Store upon creation.

If you want more control over where the logged data is sent, you can listen to your Logger's `onRecord` Stream.

## Dart Versions

  * Dart 1 support: 0.1.x
  * Dart 2 Support: 0.2.x+

### Simple Printing example

If you just want an easy way to print actions to your console / terminal as they are dispatched, use the `new LoggingMiddleware.printer()` factory.

```dart
import "package:redux/redux.dart";
import 'package:redux_logging/redux_logging.dart';

final store = new Store<int>(
  (int state, dynamic action) => state + 1,
  initialValue: 0,
  middleware: [new LoggingMiddleware.printer()]
);

store.dispatch("Hi"); // prints {Action: "Hi", Store: 1, Timestamp: ...}
```

### Example

If you only want to log actions to a `Logger`, and choose how to handle the output, use the default constructor.

```dart
import 'package:logging/logging.dart';
import "package:redux/redux.dart";
import 'package:redux_logging/redux_logging.dart';

// Create your own Logger
final logger = new Logger("Redux Logger");

// Pass it to your Middleware
final middleware = new LoggingMiddleware(logger: logger);
final store = new Store<int>(
  (int state, dynamic action) => state + 1,
  initialState: 0,
  middleware: [middleware],
);

// Note: One quirk about listening to a logger instance is that you're
// actually listening to the Singleton instance of *all* loggers.
logger.onRecord
  // Filter down to [LogRecord]s sent to your logger instance
  .where((record) => record.loggerName == logger.name)
  // Print them out (or do something more interesting!)
  .listen((loggingMiddlewareRecord) => print(loggingMiddlewareRecord));
```

### Formatting the log message

This library includes two formatters out of the box:

  - `LoggingMiddleware.singleLineFormatter`
  - `LoggingMiddleware.multiLineFormatter`

You can optionally control the format of the message that will be logged by implementing your own `MessageFormatter` and passing it to the `LoggingMiddleware` constructor. It is a simple function that takes three parameters: the State, Action, and Timestamp.

### Formatting Example

```dart
import "package:redux/redux.dart";
import 'package:redux_logging/redux_logging.dart';

// Create a formatter that only prints out the dispatched action
String onlyLogActionFormatter<State>(
  State state,
  dynamic action,
  DateTime timestamp,
) {
  return "{Action: $action}";
}

// Create your middleware using the formatter.
final middleware = new LoggingMiddleware(formatter: onlyLogActionFormatter);

// Add the middleware with your formatter to your Store
final store = new Store<int>(
  (int state, dynamic action) => state + 1,
  initialState: 0,
  middleware: [middleware],
);
```
