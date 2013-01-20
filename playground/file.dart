import 'dart:html';
import 'single/demo_client.dart';
import '../rtc_common/lib/rtc_common.dart';

void main() {
  DndManager dnd = new DndManager();
  FileManager fm = new FileManager(dnd);
  dnd.fm = fm;
}

