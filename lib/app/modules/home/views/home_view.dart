import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/values/images.dart';
import 'package:fortune_fiesta/app/data/values/strings.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';
import 'package:fortune_fiesta/app/theme/styles.dart';
import 'package:fortune_fiesta/widgets/buttons/primary_filled_button.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                Images.homeBackground,
              ),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: AppColors.white.withOpacity(0.8),
        appBar: AppBar(
          title: const Text('Fortune Fiesta'),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppColors.gradientTwo,
                ),
                child: Center(
                    child: Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: AppColors.gradientThree,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Obx(() => Text(
                      controller.tempScore.value.toString(),
                      style: Styles.tsGoldenBold18,
                    ),)
                  ],
                )),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(
                () => Container(
                  height: Get.width - 100,
                  width: Get.width,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: const [
                        AppColors.gradientOne,
                        AppColors.gradientTwo,
                        AppColors.gradientThree,
                        AppColors.gradientFour,
                        AppColors.gradientFive
                      ],
                      transform: GradientRotation(
                          controller.rotationNumber.value * pi / 180),
                    ),
                  ),
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                          colors: [
                            AppColors.goldenMachineOne,
                            AppColors.goldenMachineTwo,
                            AppColors.goldenMachineThree,
                            AppColors.goldenMachineTwo,
                            AppColors.goldenMachineOne,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(
                          () => PinScrollWidget(
                            onSelectedItemChanged: (int value) {
                              controller.pageOne = value;
                              controller.firstScore = controller.pinListOne[value].value;
                            },
                            controller: controller.scrollWheelOneController,
                            childCount: controller.pinListOne.length,
                            builder: (BuildContext context, int index) {
                              return ImageBox(
                                image: controller.pinListOne[index].imageName,
                              );
                            },
                          ),
                        ),
                        Obx(
                          () => PinScrollWidget(
                            onSelectedItemChanged: (int value) {
                              controller.secondScore = controller.pinListTwo[value].value;
                              controller.pageTwo = value;
                            },
                            controller: controller.scrollWheelTwoController,
                            childCount: controller.pinListTwo.length,
                            builder: (BuildContext context, int index) {
                              return ImageBox(
                                image: controller.pinListTwo[index].imageName,
                              );
                            },
                          ),
                        ),
                        Obx(
                          () => PinScrollWidget(
                            onSelectedItemChanged: (int value) {
                              controller.thirdScore = controller.pinListThree[value].value;
                              controller.pageThree = value;
                            },
                            controller: controller.scrollWheelThreeController,
                            childCount: controller.pinListThree.length,
                            builder: (BuildContext context, int index) {
                              return ImageBox(
                                image: controller.pinListThree[index].imageName,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              PrimaryFilledButton(
                  text: Strings.spin, onTap: controller.spinWheel),
              // PrimaryFilledButton(
              //     text: Strings.spin, onTap: controller.debugPrintF)
            ],
          ),
        ),
      ),
    );
  }
}

class PinScrollWidget extends StatelessWidget {
  const PinScrollWidget({
    super.key,
    required this.onSelectedItemChanged,
    required this.controller,
    required this.childCount,
    required this.builder,
  });

  final ValueChanged<int> onSelectedItemChanged;
  final ScrollController controller;
  final int childCount;
  final NullableIndexedWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: (Get.width - 40) / 3,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.black,
          width: 3
        )
      ),
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        physics: const NeverScrollableScrollPhysics(),
        useMagnifier: true,
        itemExtent: 100,
        diameterRatio: 1.2,
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: childCount,
          builder: builder,
        ),
      ),
    );
  }
}

class ImageBox extends StatelessWidget {
  const ImageBox({
    super.key,
    required this.image,
  });

  final String image;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Image(image: AssetImage(image)),
    );
  }
}
