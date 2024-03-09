import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gallery_controller.dart';

class GalleryView extends GetView<GalleryController> {
  const GalleryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GalleryView'),
        centerTitle: true,
      ),
      body: Obx(
            () => Column(
          children: [
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const PageScrollPhysics(),
                controller: controller.mainScrollController,
                itemCount: controller.imageCollection.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: const EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.width,
                    width: MediaQuery.of(context).size.width,
                    child: Image.network(
                      controller.imageCollection[index],
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.all(10),
              height: 80,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                controller: controller.bottomScrollController,
                itemCount: controller.imageCollection.length,
                separatorBuilder: (ctx, idx) {
                  return const SizedBox(width: 5);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      controller.setSelectedIndex(index);
                    },
                    child: Obx(() => Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controller.selectedIndex.value == index ? Colors.black : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Image.network(
                        controller.imageCollection[index],
                        fit: BoxFit.cover,
                      ),
                    ),)
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
