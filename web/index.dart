library webclient;

import 'dart:html';
import '../client/rtc_client.dart';

part "websignalhandler.dart";
part "webvideomanager.dart";

void main() {
  VideoManager vm = new WebVideoManager();
  SignalHandler sh = new WebSignalHandler();
  PeerManager peerManager = new PeerManager();
}

