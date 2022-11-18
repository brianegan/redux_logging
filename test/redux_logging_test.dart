import 'dart:async';

import 'package:logging/logging.dart';
import 'package:redux/redux.dart';
import 'package:redux_logging/redux_logging.dart';
import 'package:test/test.dart';

void main() {
  group('Logging Middleware', () {
    int addReducer(int state, dynamic action) =>
        action is int ? state + action : state;

    test('logs actions and state to the given logger', () async {
      final middleware = LoggingMiddleware<int>.printer();
      final store = Store<int>(
        addReducer,
        initialState: 1,
        middleware: [middleware],
      );

      scheduleMicrotask(() {
        store.dispatch(1);
      });

      await expectLater(
        middleware.logger.onRecord,
        emits(LogMessageContains('{Action: 1, State: 2,')),
      );
    });

    test('can be configured with the correct logging level', () async {
      final logger = Logger('Test');
      final store = Store<int>(
        addReducer,
        initialState: 0,
        middleware: [
          LoggingMiddleware<int>.printer(
            logger: logger,
            level: Level.SEVERE,
            formatter: LoggingMiddleware.multiLineFormatter,
          )
        ],
      );

      scheduleMicrotask(() {
        store.dispatch(1);
      });

      await expectLater(
        logger.onRecord,
        emits(LogLevel(Level.SEVERE)),
      );
    });

    test('prints actions in correct order', () async {
      var loggingMiddleware = LoggingMiddleware<String>.printer();
      void middleware(
        Store<String> store,
        dynamic action,
        NextDispatcher next,
      ) {
        next(action);

        if (action == 'I') {
          store.dispatch('U');
        }
      }

      final store = Store<String>(
        (String state, dynamic action) => state,
        initialState: '',
        middleware: [middleware, loggingMiddleware],
      );

      scheduleMicrotask(() {
        store.dispatch('I');
      });

      await expectLater(
        loggingMiddleware.logger.onRecord,
        emitsInOrder(<Matcher>[
          LogMessageContains('I'),
          LogMessageContains('U'),
        ]),
      );
    });
  });
}

class LogMessageContains extends Matcher {
  final Pattern pattern;

  LogMessageContains(this.pattern);

  @override
  Description describe(Description description) {
    return description
        .add('is a LogRecord with a message that contains: "$pattern"');
  }

  @override
  bool matches(dynamic item, Map matchState) {
    if (item is LogRecord) {
      return item.message.contains(pattern);
    }

    return false;
  }
}

class LogLevel extends Matcher {
  final Level level;

  LogLevel(this.level);

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
