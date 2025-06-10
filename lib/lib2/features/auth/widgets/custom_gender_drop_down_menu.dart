import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CustomGenderDropDownMenu extends StatelessWidget {
  const CustomGenderDropDownMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      return Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.2),
            width: 0.5,
          ),
          color: Theme.of(context).cardColor,
        ),
        child: Row(
          children: [
            // Prefix icon container (matching CustomTextField)
            Container(
              width: 70,
              height: 50,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  bottomLeft: Radius.circular(50),
                ),
              ),
              child: Icon(
                authController.selectedGender == 'male'
                    ? Icons.male
                    : Icons.female,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
            ),
            // Dropdown
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: authController.selectedGender,
                    isExpanded: true,
                    hint: Text(
                      'select_gender'.tr,
                      style: textRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    style: textRegular.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      fontSize: Dimensions.fontSizeDefault,
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'male',
                        child: Row(
                          children: [
                            Icon(
                              Icons.male,
                              color: Theme.of(context).primaryColor,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text('male'.tr),
                          ],
                        ),
                      ),
                      DropdownMenuItem<String>(
                        value: 'female',
                        child: Row(
                          children: [
                            Text(
                              'female'.tr,
                              style: textRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeDefault,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        authController.setSelectedGender(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
