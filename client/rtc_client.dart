library rtc_client;

import 'dart:html';
import 'dart:json';

import '../util/rtc_utils.dart';
import '../packet/packet.dart';

part "videocontainer.dart";
part "videomanager.dart";
part "peermanager.dart";
part "peerwrapper.dart";
part "src/signalhandler.dart";
part "lib/simplesignalhandler.dart";

const bool DEBUG = true;
String WEBSOCKET_SERVER = DEBUG 
    ? "ws://127.0.0.1:8234/ws" 
    : "ws://app.faceseer.com:8234/ws";
