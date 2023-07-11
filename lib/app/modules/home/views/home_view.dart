import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fortune_fiesta/app/data/values/images.dart';
import 'package:fortune_fiesta/app/theme/app_colors.dart';
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
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Obx(
                () => Container(
                  height: Get.width - 50,
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
                            AppColors.machineGradientOne,
                            AppColors.machineGradientTwo,
                            AppColors.machineGradientOne
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter
                      ),
                    ),
                    child: Obx(() {
                      if (!controller.isImageGenerated.value) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      } else {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                                width: (Get.width - 60) / 3,
                                height: Get.width - 60,
                                child: ListWheelScrollView(
                                  physics: const FixedExtentScrollPhysics(),
                                    useMagnifier: true,
                                    itemExtent: 100,
                                    diameterRatio: 1.2,
                                    children: controller.imageWidgetOne,
                                    onSelectedItemChanged: (index) => print('One: $index'),
                                )),
                            SizedBox(
                              width: (Get.width - 60) / 3,
                              height: Get.width - 60,
                              child: ListWheelScrollView(
                                physics: const FixedExtentScrollPhysics(),
                                  useMagnifier: true,
                                  itemExtent: 100,
                                  diameterRatio: 1.2,
                                  children: controller.imageWidgetsTwo,onSelectedItemChanged: (index) => print('Two: $index'),),
                            ),
                            SizedBox(
                              width: (Get.width - 60) / 3,
                              height: Get.width - 60,
                              child: ListWheelScrollView(
                                controller: controller.scrollWheelController,
                                physics: const NeverScrollableScrollPhysics(),
                                  useMagnifier: true,
                                  itemExtent: 100,
                                  diameterRatio: 1.2,
                                  children: controller.imageWidgetsThree,onSelectedItemChanged: (index) => print('Three: $index'),),
                            ),
                          ],
                        );
                      }
                    }),
                  ),
                ),
              ),
              PrimaryFilledButton(text: "text", onTap: controller.spinWheel)
            ],
          ),
        ),
      ),
    );
  }
}
