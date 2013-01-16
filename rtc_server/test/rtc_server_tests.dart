library rtc_server_tests;

import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:unittest/mock.dart';
import "../lib/rtc_server.dart";
import "../../rtc_common/lib/rtc_common.dart";

//Mocks
part "mocks/testableserver.dart";

part "channeltests.dart";
part "usertests.dart";
void main() {
  useVmConfiguration();
  new ChannelTests().run();
  new UserTests().run();
}