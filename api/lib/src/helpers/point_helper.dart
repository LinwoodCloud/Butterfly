import 'dart:math';

extension PointHelper on Point<double> {
  Point<double> operator -() => Point(-x, -y);
  Point<double> operator /(double other) => Point(x / other, y / other);

  double distanceToLine(Point first, Point secon) {
    final a = secon.y - first.y;
    final b = first.x - secon.x;
    final c = secon.x * first.y - first.x * secon.y;
    final d = (a * x + b * y + c) / sqrt(a * a + b * b);
    print(d);
    return d;
  }
}
