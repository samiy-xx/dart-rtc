import 'dart:io';
import 'dart:json';
import 'dart:math';
import 'dart:isolate';

import '../lib/rtc_server.dart';
import '../../rtc_util/lib/rtc_util.dart';
import 'package:args/args.dart';

/*
 * Starts a wheel server
 */
void main() { 
  ArgParser argParser = new ArgParser();
  argParser.addOption('port', abbr: 'p', help: 'Port to use', defaultsTo: '8234');
  argParser.addOption('ip', abbr: 'i', help: 'Ip to use', defaultsTo: '0.0.0.0');
  var args = argParser.parse(new Options().arguments);
  
  String port = args['port'];
  int p = int.parse(port);
  
  String ip = args['ip'];
  
  Server server = new WheelServer();
  try {
    server.listen(ip, p);
  } catch(e, s) {
    new Logger().Error("Exception: $e $s");
  }
}



