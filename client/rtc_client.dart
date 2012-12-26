library rtc_client;

import 'dart:html';
import 'dart:json';

import '../util/rtc_utils.dart';
import '../packet/packet.dart';

part "videocontainer.dart";
part "videomanager.dart";
part "peermanager.dart";
part "peerwrapper.dart";
part "datapeerwrapper.dart";
part "src/signalhandler.dart";
part "lib/simplesignalhandler.dart";

const int CLOSE_NORMAL = 1000; 
const int CLOSE_GOING_AWAY = 1001; 
const int CLOSE_PROTOCOL_ERROR = 1002; 
const int CLOSE_UNSUPPORTED = 1003;
const int RESERVED = 1004;
const int NO_STATUS = 1005;
const int ABNORMAL_CLOSE = 1006;
const int DATA_NOT_CONSISTENT = 1007;
const int POLICY_VIOLATION = 1008;
const int MESSAGE_TOO_LARGE = 1009;
const int NEGOTIATIONS_FAILED = 1010;
const int UNEXPECTED_CONDITION = 1011;
const int HANDSHAKE_FAILURE = 1015;

const bool DEBUG = true;

String WEBSOCKET_SERVER = DEBUG 
    ? "ws://127.0.0.1:8234/ws" 
    : "ws://app.faceseer.com:8234/ws";
