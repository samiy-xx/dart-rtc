library rtc_common_tests;

import 'dart:io';
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:unittest/mock.dart';
import "../lib/rtc_common.dart";

part "mocks/mockeventlistener.dart";
part "mocks/mockmockeventlistener.dart"; // =)

part "tests/packettests.dart";
part "tests/eventtests.dart";
part "tests/packethandlertests.dart";

void main() {
  useVMConfiguration();
  new PacketTests().run();
  new EventTests().run();
  new PacketHandlerTests().run();
}

