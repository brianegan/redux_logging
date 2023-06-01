# Changelog

## 0.5.1

  - Widen Dart environment
  - Widen logging dependency constraint 
  - Replace the discontinued pedantic package by lints
  - Move from Travis to github actions
  - Update deps for Dart 3

## 0.5.0

  - Breaking Change: updated to redux 5.0.0
  - Breaking Change: added null-safety

## 0.4.0

  - Breaking Change: Support Redux 4.x - 5.0
  - Lazy evaluation for message in logger

## 0.3.1

  - BugFix: Add docs explaining logging middleware needs to be last in chain

## 0.3.0

  - Bump to Redux 3.0.0
  - Fix Dart 2 bug

## 0.2.0

  - Dart 2 support

## 0.1.4

  - Fix formatter for printer

## 0.1.3

  - Move to Github

## 0.1.2

  - Fix examples

## 0.1.1

  - Include description in `pubspec.yaml`

## 0.1.0

  - Initial version, a `LoggingMiddleware` for Redux, which connects the dispatched actions to to a `Logger`. 
  - Includes a `printer` factory, which prints all logged messages to the your console / terminal.
