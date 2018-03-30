import 'dart:async';

import 'package:logging/logging.dart';
import "package:redux/redux.dart";
import 'package:redux_logging/redux_logging.dart';
import "package:test/test.dart";

void main() {
  group("Logging Middleware", () {
    int addReducer(int state, dynamic action) =>
        action is int ? state + action : state;

    test("logs actions and state to the given logger", () async {
      final middleware = new LoggingMiddleware<int>.printer();
      final store = new Store<int>(
        addReducer,
        initialState: 1,
        middleware: [middleware],
      );

      scheduleMicrotask(() {
        store.dispatch(1);
      });

      await expect(
        middleware.logger.onRecord,
        emits(new logMessageContains(["{Action: 1, State: 2,"])),
      );
    });

    test("can be configured with the correct logging level", () async {
      final logger = new Logger("Test");
      final store = new Store<int>(
        addReducer,
        initialState: 0,
        middleware: [
          new LoggingMiddleware<int>.printer(
            logger: logger,
            level: Level.SEVERE,
            formatter: LoggingMiddleware.multiLineFormatter,
          )
        ],
      );

      scheduleMicrotask(() {
        store.dispatch(1);
      });

      await expect(
        logger.onRecord,
        emits(new logLevel(Level.SEVERE)),
      );
    });
  });
}

class logMessageContains extends Matcher {
  final List<Pattern> patterns;

  logMessageContains(this.patterns);

  @override
  Description describe(Description description) {
    return description
        .add('is a LogRecord with a message that contains: "$patterns"');
  }

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is LogRecord) {
      return patterns.every((pattern) => item.message.contains(pattern));
    }

    return false;
  }
}

class logLevel extends Matcher {
  final Level level;

  logLevel(this.level);

  @override
  Description describe(Description description) {
    return description.add('is a LogRecord with the level: $level');
  }

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is LogRecord) {
      return item.level == level;
    }

    return false;
  }
}
