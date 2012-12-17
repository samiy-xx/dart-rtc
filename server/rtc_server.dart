library rtc_server;

import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'dart:isolate';
import '../packet/packet.dart';
import '../util/rtc_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:args/args.dart';

part "server.dart";
part "roomserver.dart";
part "wheelserver.dart";
part "facebookserver.dart";
part "user.dart";
part "roomuser.dart";
part "util.dart";
part "room.dart";
part "container.dart";

const int DEAD_SOCKET_CHECK = 60000 * 5;
const int DEAD_SOCKET_KILL = DEAD_SOCKET_CHECK * 2;
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
  Server server;
  if (type == "wheel") {
    
    server = new WheelServer();
  } else if (type == "room") {
    server = new RoomServer();
  } else {
    //server = new FacebookServer();
  }
    
  try {
    server.listen("0.0.0.0", p);
  } on Exception catch (e) {   
    new Logger().Error("Exception: $e");
  } catch(e) {
    new Logger().Error("Exception: $e");
  }
}