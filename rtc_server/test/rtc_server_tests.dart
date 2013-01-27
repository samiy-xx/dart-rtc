library rtc_server_tests;

import 'dart:io';
import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';
import 'package:unittest/mock.dart';
import "../lib/rtc_server.dart";
import "../../rtc_common/lib/rtc_common.dart";

//Mocks
part "mocks/testableserver.dart";
part "mocks/testablewebsocketconnection.dart";
part "mocks/mockchanneleventlistener.dart";

part "testfactory.dart";
part "tests/channeltests.dart";
part "tests/usertests.dart";
part "tests/queuechanneltests.dart";

void main() {
  new Logger().setLevel(LogLevel.ERROR);
  useVMConfiguration();
  new ChannelTests().run();
  new QueueChannelTests().run();
  new UserTests().run();
}