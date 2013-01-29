library rtc_client_tests;

import 'dart:html';
import '../packages/unittest/unittest.dart';
import '../packages/unittest/html_enhanced_config.dart';
import '../packages/unittest/mock.dart';
import '../lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';

part 'mocks/chunksender.dart';
part 'mocks/binaryeventlistener.dart';

part 'tests/packettests.dart';
part 'tests/binarywritertests.dart';
part 'tests/binaryreadertests.dart';

void run() {
  useHtmlEnhancedConfiguration();
  
  new PacketTests().run();
  new BinaryWriterTests().run();
  new BinaryReaderTests().run();
}