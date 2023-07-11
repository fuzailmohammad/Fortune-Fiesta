import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/values/images.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final rotationNumber = 0.obs;
  final isImageGenerated = false.obs;
  List<Widget> imageWidgetOne = [];
  List<Widget> imageWidgetsTwo = [];
  List<Widget> imageWidgetsThree = [];
  final scrollWheelController = FixedExtentScrollController(initialItem: 0);

  Timer? timer;
  Timer? upperSliderTimer;

  final List<String> pin = [
    Images.barZero,
    Images.barOne,
    Images.barTwo,
    Images.barThree,
    Images.barFour,
    Images.barFive,
    Images.barSix,
    Images.barSeven,
    Images.barEight,
    Images.barNine,
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    generateImage();
  }

  @override
  void onClose() {
    timer?.cancel();
  }

  List<Widget> generateImageWidgetsList() {
    return pin.map((image) => Image(image: AssetImage(image))).toList();
  }

  generateImage() async {
    startTimer();
    pin.shuffle();
    imageWidgetOne.addAll(generateImageWidgetsList());
    pin.shuffle();
    imageWidgetsTwo.addAll(generateImageWidgetsList());
    pin.shuffle();
    imageWidgetsThree.addAll(generateImageWidgetsList());
    isImageGenerated.value = true;
  }

  void startTimer() {
    timer = Timer.periodic(
      const Duration(milliseconds: 100),
          (_) {
        if (rotationNumber.value < 360) {
          rotationNumber.value = rotationNumber.value + 5;
        } else {
          rotationNumber.value = 0;
        }
      },
    );
  }

  spinWheel() {
    int totalitems = 10; //total length of items
    int counter = 0;
    if (counter <= totalitems) {
      upperSliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
        scrollWheelController.animateToItem(counter,
            duration: const Duration(milliseconds: 500), curve: Curves.easeInCubic);
        counter++;
        if (counter == totalitems) counter = 0;
      });
    }
  }
}