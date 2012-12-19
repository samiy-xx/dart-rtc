library rtc_server;

import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'dart:isolate';


import '../packet/packet.dart';
import '../util/rtc_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:args/args.dart';

part "src/server.dart";
part "src/user.dart";
part "src/util.dart";
part "src/channel.dart";
part "src/basecontainer.dart";
part "src/basechannelcontainer.dart";
part "src/baseusercontainer.dart";

part "src/roomusercontainer.dart";
part "src/usercontainer.dart";
part "src/channelcontainer.dart";

part "lib/channelserver.dart";
part "lib/roomserver.dart";
part "lib/wheelserver.dart";
part "lib/facebookserver.dart";
part "lib/channeluser.dart";
part "lib/wheeluser.dart";

const int DEAD_SOCKET_CHECK = 6000;
const int DEAD_SOCKET_KILL = DEAD_SOCKET_CHECK * 4;
const int RANDOM_ID_LENGTH = 8;

void main() {
  ArgParser argParser = new ArgParser();
  argParser.addOption('port', abbr: 'p', help: 'Port to use', defaultsTo: '8234');
  argParser.addOption('type', abbr: 't', help: 'Server type', defaultsTo: 'wheel');
  
  var args = argParser.parse(new Options().arguments);
  String port = args['port'];
  String type = args['type'];
  
  int p = int.parse(port);
  new Logger().Info("Server process starting");
  new Logger().Info("Server type=$type");
  
  Server server = null;
  if (type == "wheel") {
    server = new WheelServer();
  } else if (type == "room") {
    server = new RoomServer();
  } else  if (type == "channel") {
    server = new ChannelServer();
  } else {
    //server = new FacebookServer();
  }
  
  try {
    if (server != null)
      server.listen("0.0.0.0", p);
    else
      new Logger().Info("Server type was not set or not found");
  } on Exception catch (e) {   
    new Logger().Error("Exception: $e");
  } catch(e) {
    new Logger().Error("Exception: $e");
  }
}