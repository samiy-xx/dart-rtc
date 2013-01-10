import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'dart:isolate';

import '../lib/rtc_server.dart';
import '../../rtc_util/lib/rtc_util.dart';
import 'package:args/args.dart';

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