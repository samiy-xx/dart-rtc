import 'dart:html';
import '../single/demo_client.dart';

void main() {
  Resizer r = new Resizer(query("#box"), 100, 100, 100, 100);
  r.requestNewPosition(0, 0);
  r.requestNewSize(500, 500);
}

