library rtc_server_tests;
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import "../lib/rtc_server.dart";
import "../../rtc_common/lib/rtc_common.dart";
part "channeltests.dart";

void main() {
  useVmConfiguration();
  new ChannelTests().run();
}