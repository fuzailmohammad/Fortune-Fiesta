import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/values/images.dart';
import 'package:fortune_fiesta/app/data/values/strings.dart';
import 'package:fortune_fiesta/utils/helper/exception_handler.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final rotationNumber = 0.obs;
  final tempScore = 0.obs;
  final scrollWheelOneController = FixedExtentScrollController(initialItem: 0);
  final scrollWheelTwoController = FixedExtentScrollController(initialItem: 0);
  final scrollWheelThreeController =
      FixedExtentScrollController(initialItem: 0);
  bool isSpinning = false;

  static const spinDuration = Duration(milliseconds: 50);
  static const periodicSpinDuration = Duration(milliseconds: 100);
  static const longSpinDuration = Duration(seconds: 3);

  int firstScore = 0;
  int secondScore = 0;
  int thirdScore = 0;

  Timer? timer;
  Timer? upperSliderTimer;

  int pageOne = 0;
  int pageTwo = 0;
  int pageThree = 0;

  int counter = 0;

  final _pinListOne = RxList<PinList>([]);
  final _pinListTwo = RxList<PinList>([]);
  final _pinListThree = RxList<PinList>([]);

  List<PinList> get pinListOne => _pinListOne;

  List<PinList> get pinListTwo => _pinListTwo;

  List<PinList> get pinListThree => _pinListThree;


  @override
  void onReady() {
    super.onReady();
    generateImage();
  }

  @override
  void onClose() {
    timer?.cancel();
  }

  generateImage() {
    startTimer();
    generateListOne();
    generateListTwo();
    generateListThree();
    _pinListOne.shuffle();
    _pinListTwo.shuffle();
    _pinListThree.shuffle();
  }

  generateListOne() {
    _pinListOne.add(PinList(imageName: Images.barZero, value: 0));
    _pinListOne.add(PinList(imageName: Images.barOne, value: 1));
    _pinListOne.add(PinList(imageName: Images.barTwo, value: 2));
    _pinListOne.add(PinList(imageName: Images.barThree, value: 3));
    _pinListOne.add(PinList(imageName: Images.barFour, value: 4));
    _pinListOne.add(PinList(imageName: Images.barFive, value: 5));
    _pinListOne.add(PinList(imageName: Images.barSix, value: 6));
    _pinListOne.add(PinList(imageName: Images.barSeven, value: 7));
    _pinListOne.add(PinList(imageName: Images.barEight, value: 8));
    _pinListOne.add(PinList(imageName: Images.barNine, value: 9));
  }

  generateListTwo() {
    _pinListTwo.add(PinList(imageName: Images.barZero, value: 0));
    _pinListTwo.add(PinList(imageName: Images.barOne, value: 1));
    _pinListTwo.add(PinList(imageName: Images.barTwo, value: 2));
    _pinListTwo.add(PinList(imageName: Images.barThree, value: 3));
    _pinListTwo.add(PinList(imageName: Images.barFour, value: 4));
    _pinListTwo.add(PinList(imageName: Images.barFive, value: 5));
    _pinListTwo.add(PinList(imageName: Images.barSix, value: 6));
    _pinListTwo.add(PinList(imageName: Images.barSeven, value: 7));
    _pinListTwo.add(PinList(imageName: Images.barEight, value: 8));
    _pinListTwo.add(PinList(imageName: Images.barNine, value: 9));
  }

  generateListThree() {
    _pinListThree.add(PinList(imageName: Images.barZero, value: 0));
    _pinListThree.add(PinList(imageName: Images.barOne, value: 1));
    _pinListThree.add(PinList(imageName: Images.barTwo, value: 2));
    _pinListThree.add(PinList(imageName: Images.barThree, value: 3));
    _pinListThree.add(PinList(imageName: Images.barFour, value: 4));
    _pinListThree.add(PinList(imageName: Images.barFive, value: 5));
    _pinListThree.add(PinList(imageName: Images.barSix, value: 6));
    _pinListThree.add(PinList(imageName: Images.barSeven, value: 7));
    _pinListThree.add(PinList(imageName: Images.barEight, value: 8));
    _pinListThree.add(PinList(imageName: Images.barNine, value: 9));
  }

  void startTimer() {
    timer = Timer.periodic(
      periodicSpinDuration,
      (_) {
        if (rotationNumber.value < 360) {
          rotationNumber.value = rotationNumber.value + 5;
        } else {
          rotationNumber.value = 0;
        }
      },
    );
  }

  spinWheel() async {
    if (!isSpinning) {
      isSpinning = true;
      _pinListOne.shuffle();
      _pinListTwo.shuffle();
      _pinListThree.shuffle();
      refresh();
      update();
      await spinningLogic();
      isSpinning = false;
    } else {
      HandleError.showError(ErrorMessages.pinSpinning);
    }
  }

  Future<void> spinningLogic() async {
    int totalItems = 10;
    upperSliderTimer = Timer.periodic(periodicSpinDuration, (timer) {
      scrollControl(scrollWheelOneController, counter);
      scrollControl(scrollWheelTwoController, counter);
      scrollControl(scrollWheelThreeController, counter);
      counter++;
      if (counter == totalItems) counter = 0;
    });
    await Future.delayed(longSpinDuration);
    upperSliderTimer?.cancel();
    scoreLogic();
  }

  scrollControl(FixedExtentScrollController controller, int counter) {
    controller.animateToItem(counter,
        duration: spinDuration, curve: Curves.easeInCubic);
  }

  scoreLogic() {
    int multiplier = 0;
    int grandTotal = firstScore + secondScore + thirdScore;
    if (firstScore == secondScore && secondScore == thirdScore) {
      multiplier = equalScoreCalculation(grandTotal);
      tempScore.value = tempScore.value + (grandTotal * multiplier);
    } else if (firstScore == secondScore ||
        secondScore == thirdScore ||
        firstScore == thirdScore) {
      multiplier = twoEqualScoreCalculation(grandTotal);
      tempScore.value = tempScore.value + (grandTotal * multiplier);
    } else {
      tempScore.value = tempScore.value + grandTotal;
    }
    firstScore = 0;
    secondScore = 0;
    thirdScore = 0;
  }

  debugPrintF() {
    scoreLogic();
  }

  int equalScoreCalculation(int total) {
    switch (total) {
      case 0:
        return 0;
      case 3:
        return 10;
      case 6:
        return 20;

      case 9:
        return 30;

      case 12:
        return 40;

      case 15:
        return 50;

      case 18:
        return 60;

      case 21:
        return 70;

      case 24:
        return 80;

      case 27:
        return 100;

      default:
        return 0;
    }
  }

  int twoEqualScoreCalculation(int total) {
    if (total < 9) {
      return 5;
    } else if (total < 18) {
      return 10;
    } else if (total < 27) {
      return 15;
    } else {
      return 0;
    }
  }
}

class PinList {
  PinList({
    required this.imageName,
    required this.value,
  });

  final String imageName;
  final int value;
}
