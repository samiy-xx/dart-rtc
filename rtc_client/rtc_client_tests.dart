library rtc_client_tests;

import 'packages/unittest/unittest.dart';
import 'packages/unittest/html_config.dart';
import 'packages/unittest/mock.dart';

import 'dart:html';


part "tests/packettests.dart";

void main() {
  useHtmlConfiguration();
  new PacketTests().run();
  
}