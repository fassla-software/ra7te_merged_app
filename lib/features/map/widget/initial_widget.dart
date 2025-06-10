import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_text_field.dart';
import 'package:ride_sharing_user_app/common_widgets/expandable_bottom_sheet.dar.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/home/controllers/category_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/parcel/widgets/fare_input_widget.dart';
import 'package:ride_sharing_user_app/features/payment/controllers/payment_controller.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/ride/widgets/ride_category.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/features/splash/domain/models/config_model.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class InitialWidget extends StatefulWidget {
  final GlobalKey<ExpandableBottomSheetState> expandableKey;
  const InitialWidget({super.key, required this.expandableKey});

  @override
  State<InitialWidget> createState() => _InitialWidgetState();
}

class _InitialWidgetState extends State<InitialWidget> {
  String? zoneExtraFareReason;
  @override
  void initState() {
    var rideController = Get.find<RideController>();
    if (Get.find<PaymentController>().paymentType == 'wallet' &&
        (rideController.discountAmount.toDouble() > 0
                ? rideController.discountFare
                : rideController.estimatedFare) >
            Get.find<ProfileController>()
                .profileModel!
                .data!
                .wallet!
                .walletBalance!) {
      Get.find<PaymentController>().setPaymentType(0);
    }
    zoneExtraFareReason = _getExtraFairReason(
        Get.find<ConfigController>().config?.zoneExtraFare,
        Get.find<LocationController>().zoneID);

    // Ensure categories are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<CategoryController>().getCategoryList();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RideController>(builder: (rideController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        return Column(mainAxisSize: MainAxisSize.min, children: [
          // Route Information Card

          RideCategoryWidget(onTap: (value) async {
            if (rideController.isCouponApplicable) {
              await Future.delayed(const Duration(milliseconds: 500));
              widget.expandableKey.currentState?.expand(duration: 1000);
            } else {
              widget.expandableKey.currentState?.contract(duration: 500);
              widget.expandableKey.currentState?.expand(duration: 1000);
            }
          }),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          _buildRouteCard(locationController),

          if (rideController.isCouponApplicable) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeSmall,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(Dimensions.paddingSizeSmall),
                  ),
                  child: Text('coupon_applied'.tr,
                      style: textBold.copyWith(
                          color: Theme.of(context).primaryColor))),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
          ],
          const SizedBox(height: Dimensions.paddingSizeDefault),

          CustomTextField(
            prefix: false,
            borderRadius: Dimensions.radiusSmall,
            hintText: "add_code".tr,
            controller: rideController.noteController,
            onTap: () async {
              await Future.delayed(const Duration(milliseconds: 500));
              widget.expandableKey.currentState?.expand(duration: 1000);
            },
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),

          rideController.isLoading || rideController.isSubmit
              ? Center(
                  child: SpinKitCircle(
                      color: Theme.of(context).primaryColor, size: 40.0))
              : (Get.find<ConfigController>().config!.bidOnFare!)
                  ? FareInputWidget(
                      expandableKey: widget.expandableKey,
                      fromRide: true,
                      fare: rideController.discountAmount.toDouble() > 0
                          ? rideController.discountFare.toString()
                          : rideController.estimatedFare.toString(),
                    )
                  : ButtonWidget(
                      buttonText: "find_rider".tr,
                      onPressed: () {
                        rideController
                            .submitRideRequest(
                                rideController.noteController.text, false)
                            .then((value) {
                          if (value.statusCode == 200) {
                            Get.find<AuthController>()
                                .saveFindingRideCreatedTime();
                            rideController
                                .updateRideCurrentState(RideState.findingRider);
                            Get.find<MapController>().initializeData();
                            Get.find<MapController>().setOwnCurrentLocation();
                            Get.find<MapController>().notifyMapController();
                          }
                        });
                      }),
        ]);
      });
    });
  }

  Widget _buildRouteCard(LocationController locationController) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Get.isDarkMode
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.white,
                  Colors.white.withOpacity(0.95),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // From Location
          _buildLocationRow(
            icon: Icons.radio_button_checked,
            iconColor: const Color(0xFF10B981),
            address: locationController.fromAddress?.address ?? '',
            label: 'From',
          ),

          const SizedBox(height: 12),

          // Route Line
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Container(
              width: 2,
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF10B981).withOpacity(0.3),
                    Theme.of(context).primaryColorDark.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // To Location
          _buildLocationRow(
            icon: Icons.place,
            iconColor: Theme.of(context).primaryColorDark,
            address: locationController.toAddress?.address ?? '',
            label: 'To',
          ),

          // Extra routes if any
          if (locationController.extraRouteAddress?.address?.isNotEmpty ??
              false) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Container(
                width: 2,
                height: 15,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildLocationRow(
              icon: Icons.add_location_alt,
              iconColor: const Color(0xFF8B5CF6),
              address: locationController.extraRouteAddress?.address ?? '',
              label: 'Stop',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String address,
    required String label,
  }) {
    return Row(
      children: [
        // Icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: iconColor.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 16,
          ),
        ),

        const SizedBox(width: 12),

        // Address Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode
                      ? Colors.white.withOpacity(0.6)
                      : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                address.isEmpty ? 'Select location' : address,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: address.isEmpty
                      ? (Get.isDarkMode
                          ? Colors.white.withOpacity(0.4)
                          : Colors.grey[500])
                      : (Get.isDarkMode
                          ? Colors.white.withOpacity(0.9)
                          : Colors.black),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String? _getExtraFairReason(List<ZoneExtraFare>? list, String? zoneId) {
    for (int i = 0; i < (list?.length ?? 0); i++) {
      if (list?[i].zoneId == zoneId || list?[i].zoneId == 'all') {
        return list?[i].reason ?? '';
      }
    }
    return null;
  }
}
