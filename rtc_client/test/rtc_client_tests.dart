library rtc_client_tests;

import 'dart:html';
import '../packages/unittest/unittest.dart';
import '../packages/unittest/html_enhanced_config.dart';
import '../packages/unittest/mock.dart';
import '../lib/rtc_client.dart';
import '../../rtc_common/lib/rtc_common.dart';
part 'packettests.dart';

void run() {
  useHtmlEnhancedConfiguration();
  
  new PacketTests().run();
}