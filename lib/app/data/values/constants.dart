import 'package:flutter/material.dart';

class Timeouts {
  Timeouts._privateConstructor();

  static const connectTimeout = 10000;
  static const receiveTimeout = 10000;
}

class GlobalKeys {
  GlobalKeys._privateConstructor();

  static final navigationKey = GlobalKey<NavigatorState>();
}
