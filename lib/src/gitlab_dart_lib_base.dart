// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  final bool fake;

  Awesome({this.fake = false});

  bool get isAwesome => fake ? false : true;
}
