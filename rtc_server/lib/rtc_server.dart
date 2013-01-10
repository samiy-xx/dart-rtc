library rtc_server;

import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'dart:isolate';

import '../../rtc_common/lib/rtc_common.dart';
import '../../rtc_util/lib/rtc_util.dart';
import 'package:uuid/uuid.dart';


part "src/server.dart";
part "src/user.dart";
part "src/util.dart";
part "src/channel.dart";
part "src/basecontainer.dart";
part "src/basechannelcontainer.dart";
part "src/baseusercontainer.dart";

part "src/usercontainer.dart";
part "src/channelcontainer.dart";

part "src/channelserver.dart";
part "src/wheelserver.dart";
part "src/channeluser.dart";
part "src/wheeluser.dart";

const int DEAD_SOCKET_CHECK = 6000;
const int DEAD_SOCKET_KILL = DEAD_SOCKET_CHECK * 4;
const int RANDOM_ID_LENGTH = 8;

