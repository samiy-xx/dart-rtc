library rtc_client;

import 'dart:html';
import 'dart:json' as json;
import 'dart:async';
import '../../rtc_common/lib/rtc_common.dart';

part 'src/peer/peermanager.dart';
part 'src/peer/peerwrapper.dart';
part 'src/peer/datapeerwrapper.dart';
part 'src/peer/binarydata.dart';
part 'src/peer/binaryreadstate.dart';
part 'src/peer/binarydatatype.dart';
part 'src/peer/binarydatareader.dart';
part 'src/peer/binarydatawriter.dart';

part 'src/event/peereventlistener.dart';
part 'src/event/signalingeventlistener.dart';
part 'src/event/datasourceeventlistener.dart';
part 'src/event/binarydataeventlistener.dart';
part 'src/event/rtcevent.dart';
part 'src/event/mediastreamevent.dart';
part 'src/event/signalingevent.dart';
part 'src/event/peerevent.dart';
part 'src/event/datasourceevent.dart';
part 'src/event/initializationevent.dart';
part 'src/event/packetevent.dart';
part 'src/event/queueevent.dart';

part 'src/signaling/signalhandler.dart';
part 'src/signaling/basesignalhandler.dart';
part 'src/signaling/channelsignalhandler.dart';
part 'src/signaling/simplesignalhandler.dart';
part 'src/signaling/wheelsignalhandler.dart';
part 'src/signaling/queuesignalhandler.dart';
part 'src/signaling/streamingsignalhandler.dart';

part 'src/datasource/datasource.dart';
part 'src/datasource/websocketdatasource.dart';

part 'src/exception/notimplementedexception.dart';

part 'api/queueclient.dart';

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
    : "ws://bananafarm.org:8234/ws";
typedef void PeerMediaEventListenerType(MediaStream ms, String id, bool main);