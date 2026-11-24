/// Boosters are a fixed allowance granted fresh at the start of every level.
/// Using hint, shuffle or magic lowers the star rating; undo does not.
enum BoosterType {
  hint('Hint', 3),
  undo('Undo', 5),
  shuffle('Shuffle', 2),
  magic('Magic', 1);

  final String label;
  final int perLevel;

  const BoosterType(this.label, this.perLevel);
}
