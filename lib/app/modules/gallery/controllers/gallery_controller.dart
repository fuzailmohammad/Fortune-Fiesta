import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GalleryController extends GetxController {
  ScrollController mainScrollController = ScrollController();
  ScrollController bottomScrollController = ScrollController();

  final List<String> imageCollection = [
    'https://cdn.pixabay.com/photo/2022/02/26/12/35/egyptian-goose-chick-7035704_1280.jpg',
    'https://cdn.pixabay.com/photo/2024/01/29/20/40/cat-8540772_1280.jpg',
    'https://cdn.pixabay.com/photo/2010/12/13/10/05/berries-2277_1280.jpg',
    'https://cdn.pixabay.com/photo/2020/09/02/08/19/dinner-5537679_1280.png',
    'https://cdn.pixabay.com/photo/2016/09/07/11/37/sunset-1651426_1280.jpg',
    'https://cdn.pixabay.com/photo/2019/01/09/14/13/leaves-3923413_1280.jpg',
    'https://cdn.pixabay.com/photo/2012/06/19/10/32/owl-50267_1280.jpg',
    'https://cdn.pixabay.com/photo/2016/03/27/22/22/fox-1284512_1280.jpg',
  ].obs;

  RxInt selectedIndex = 0.obs;

  @override
  void onInit(){
    super.onInit();
  }

  @override
  void onClose() {
    mainScrollController.dispose();
    bottomScrollController.dispose();
    super.onClose();
  }



  void setSelectedIndex(int index) {
    selectedIndex.value = index;
    mainScrollController.animateTo(
      MediaQuery.of(Get.context!).size.width * index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }
}
