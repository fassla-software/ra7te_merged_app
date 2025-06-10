import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/category_widget.dart';

class RideCategoryWidget extends StatelessWidget {
  final Function(void)? onTap;
  const RideCategoryWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<CategoryController>(builder: (categoryController) {
        return categoryController.categoryList != null
            ? categoryController.categoryList!.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColorDark,
                                    Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Choose your ride',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Ride Categories List - Vertical ListView
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: List.generate(
                            categoryController.categoryList!.length,
                            (index) => CategoryWidget(
                              index: index,
                              fromSelect: true,
                              category: categoryController.categoryList![index],
                              isSelected:
                                  rideController.rideCategoryIndex == index,
                              onTap: onTap,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    height: 120,
                    alignment: Alignment.center,
                    child: Text(
                      'no_category_found'.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: Get.isDarkMode
                            ? Colors.white.withOpacity(0.7)
                            : Colors.grey[600],
                      ),
                    ),
                  )
            : Container(
                height: 80,
                alignment: Alignment.center,
                child: SpinKitCircle(
                  color: Theme.of(context).primaryColor,
                  size: 40.0,
                ),
              );
      });
    });
  }
}
