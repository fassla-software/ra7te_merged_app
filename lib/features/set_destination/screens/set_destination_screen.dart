import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_search_field.dart';
import 'package:ride_sharing_user_app/features/dashboard/screens/dashboard_screen.dart';
import 'package:ride_sharing_user_app/features/home/widgets/home_my_address.dart';
import 'package:ride_sharing_user_app/features/map/screens/map_screen.dart';
import 'package:ride_sharing_user_app/features/parcel/controllers/parcel_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/widget/input_field_for_set_route.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/route_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/address/domain/models/address_model.dart';
import 'package:ride_sharing_user_app/features/address/controllers/address_controller.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';
import 'package:ride_sharing_user_app/features/location/view/pick_map_screen.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/divider_widget.dart';
import 'dart:math' as math;

class SetDestinationScreen extends StatefulWidget {
  final Address? address;
  final String? searchText;
  const SetDestinationScreen({super.key, this.address, this.searchText});

  @override
  State<SetDestinationScreen> createState() => _SetDestinationScreenState();
}

class _SetDestinationScreenState extends State<SetDestinationScreen> {
  FocusNode pickLocationFocus = FocusNode();
  FocusNode destinationLocationFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    Get.find<LocationController>().initAddLocationData();
    Get.find<LocationController>().initTextControllers();
    Get.find<LocationController>().getLastAddressList(); // Load trip history
    Get.find<RideController>().clearExtraRoute();
    Get.find<MapController>().initializeData();
    Get.find<RideController>().initData();
    Get.find<ParcelController>().updatePaymentPerson(false, notify: false);
    Get.find<LocationController>()
        .setPickUp(Get.find<LocationController>().getUserAddress());
    if (widget.address != null) {
      Get.find<LocationController>().setDestination(widget.address);
    }
    if (widget.searchText != null) {
      Get.find<LocationController>()
          .setDestination(Address(address: widget.searchText));
      Future.delayed(const Duration(seconds: 1)).then((_) {
        Get.find<LocationController>().searchLocation(
            context, widget.searchText ?? '',
            type: LocationType.to);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor:
            Get.isDarkMode ? const Color(0xFFF8F9FA) : const Color(0xFF0A0A0A),
        body: BodyWidget(
          appBar: AppBarWidget(
            title: 'select_location'.tr,
            onBackPressed: () {
              if (Navigator.canPop(context)) {
                Get.back();
              } else {
                Get.offAll(() => const DashboardScreen());
              }
            },
          ),
          body: GetBuilder<LocationController>(builder: (locationController) {
            return GetBuilder<RideController>(builder: (rideController) {
              return Stack(clipBehavior: Clip.none, children: [
                SingleChildScrollView(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Header Section
                  Container(
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Get.isDarkMode
                            ? Colors.white.withOpacity(0.1)
                            : Colors.black.withOpacity(0.06),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Get.isDarkMode
                              ? Colors.black.withOpacity(0.4)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(children: [
                      // Trip Type Header with Black Accents
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).primaryColorDark,
                                    Colors.black.withOpacity(0.2),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'where_to_go'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF1A1A1A),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context)
                                        .primaryColorDark
                                        .withOpacity(0.1),
                                    Colors.black.withOpacity(0.02),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.black.withOpacity(0.08),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'ride'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Route Input Section
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: Get.isDarkMode
                                ? [
                                    const Color(0xFF1A1A1A),
                                    const Color(0xFF0F0F0F),
                                  ]
                                : [
                                    const Color(0xFFF8F9FA),
                                    Colors.white,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Get.isDarkMode
                                ? Colors.black.withOpacity(0.3)
                                : Colors.black.withOpacity(0.05),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(children: [
                          // From Location
                          _buildModernLocationInput(
                            controller:
                                locationController.pickupLocationController,
                            focusNode: pickLocationFocus,
                            icon: Icons.my_location_rounded,
                            label: 'pick_location'.tr,
                            isPickup: true,
                            locationController: locationController,
                            rideController: rideController,
                            context: context,
                          ),

                          // Route Connector
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Container(
                                  width: 1.5,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        const Color(0xFF10B981)
                                            .withOpacity(0.2),
                                        Theme.of(context)
                                            .primaryColorDark
                                            .withOpacity(0.4),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Extra Routes
                          if (locationController.extraOneRoute) ...[
                            _buildModernLocationInput(
                              controller:
                                  locationController.extraRouteOneController,
                              focusNode: FocusNode(),
                              icon: Icons.add_location_alt_rounded,
                              label: 'extra_route_one'.tr,
                              isPickup: false,
                              locationController: locationController,
                              rideController: rideController,
                              context: context,
                              isExtra: true,
                              onRemove: () => locationController.setExtraRoute(
                                  remove: true),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 24),
                                  Container(
                                    width: 2,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.3),
                                          Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (locationController.extraTwoRoute) ...[
                            _buildModernLocationInput(
                              controller:
                                  locationController.extraRouteTwoController,
                              focusNode: FocusNode(),
                              icon: Icons.add_location_alt_rounded,
                              label: 'extra_route_two'.tr,
                              isPickup: false,
                              locationController: locationController,
                              rideController: rideController,
                              context: context,
                              isExtra: true,
                              onRemove: () => locationController.setExtraRoute(
                                  remove: true),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  const SizedBox(width: 24),
                                  Container(
                                    width: 2,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.3),
                                          Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          // To Location with Entrance Integration
                          Row(
                            children: [
                              Expanded(
                                child: _buildModernLocationInput(
                                  controller: locationController
                                      .destinationLocationController,
                                  focusNode: destinationLocationFocus,
                                  icon: Icons.location_on_rounded,
                                  label: 'destination'.tr,
                                  isPickup: false,
                                  locationController: locationController,
                                  rideController: rideController,
                                  context: context,
                                ),
                              ),
                              // Address Dropdown Button
                              Container(
                                margin: const EdgeInsets.only(left: 6),
                                child: _buildAddressDropdownButton(
                                    locationController),
                              ),
                              if (!locationController.extraTwoRoute &&
                                  (Get.find<ConfigController>()
                                          .config!
                                          .addIntermediatePoint ??
                                      false))
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  child:
                                      _buildAddStopButton(locationController),
                                ),
                            ],
                          ),

                          // Entrance Section - Redesigned
                          const SizedBox(height: 12),
                          if (locationController.addEntrance) ...[
                            _buildEntranceInput(locationController),
                          ] else ...[
                            _buildModernEntranceButton(locationController),
                          ],
                        ]),
                      ),

                      const SizedBox(height: 12),
                    ]),
                  ),

                  // Saved Addresses Section with Black Accents
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: Get.isDarkMode
                            ? [
                                Colors.black.withOpacity(0.1),
                                Colors.transparent,
                              ]
                            : [
                                Colors.black.withOpacity(0.02),
                                Colors.transparent,
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 16,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.3),
                                    Theme.of(context).primaryColorDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Trips'.tr,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Get.isDarkMode
                                    ? Colors.white.withOpacity(0.9)
                                    : const Color(0xFF1A1A1A),
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const HomeMyAddress(addressPage: AddressPage.home),
                      ],
                    ),
                  ),

                  const SizedBox(height: 100),
                ])),

                // Bottom Action Button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode
                          ? const Color(0xFF0A0A0A)
                          : const Color(0xFFF8F9FA),
                      border: Border(
                        top: BorderSide(
                          color: Get.isDarkMode
                              ? Colors.white.withOpacity(0.1)
                              : Colors.black.withOpacity(0.06),
                          width: 1,
                        ),
                      ),
                    ),
                    child: _buildContinueButton(
                        locationController, rideController, context),
                  ),
                ),

                // Search Results Overlay
                locationController.resultShow
                    ? Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: _buildSearchResultsOverlay(locationController),
                      )
                    : const SizedBox(),
              ]);
            });
          }),
        ));
  }

  Widget _buildModernLocationInput({
    required TextEditingController controller,
    required FocusNode focusNode,
    required IconData icon,
    required String label,
    required bool isPickup,
    required LocationController locationController,
    required RideController rideController,
    required BuildContext context,
    bool isExtra = false,
    VoidCallback? onRemove,
  }) {
    // Define unique colors and icons for each type
    Color getIconColor() {
      if (isPickup) return const Color(0xFF10B981); // Emerald green for pickup
      if (isExtra) return const Color(0xFF8B5CF6); // Purple for extra stops
      return Theme.of(context).primaryColorDark; // Gold for destination
    }

    IconData getMainIcon() {
      if (isPickup)
        return Icons.radio_button_checked; // Current location indicator
      if (isExtra) return Icons.add_location_alt_outlined; // Extra stop
      return Icons.place_outlined; // Destination pin
    }

    String getIconLabel() {
      if (isPickup) return "Current Location";
      if (isExtra) return "Stop";
      return "Destination";
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          // Location Icon - smaller and more elegant
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: getIconColor().withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: getIconColor().withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Icon(
              getMainIcon(),
              color: getIconColor(),
              size: 16,
            ),
          ),

          const SizedBox(width: 8),

          // Input Field - thinner and more modern
          Expanded(
            child: Container(
              height: 38, // Much thinner height
              decoration: BoxDecoration(
                color: Get.isDarkMode
                    ? Colors.white.withOpacity(0.03)
                    : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Get.isDarkMode
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04),
                  width: 1,
                ),
              ),
              child: TextField(
                readOnly: rideController.rideDetails != null,
                focusNode: focusNode,
                controller: controller,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Get.isDarkMode
                      ? Colors.white.withOpacity(0.9)
                      : const Color(0xFF1F2937),
                ),
                decoration: InputDecoration(
                  hintText: label,
                  hintStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Get.isDarkMode
                        ? Colors.white.withOpacity(0.4)
                        : const Color(0xFF9CA3AF),
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
                onChanged: (value) async {
                  LocationType type = isPickup
                      ? LocationType.from
                      : isExtra
                          ? (controller ==
                                  locationController.extraRouteOneController
                              ? LocationType.extraOne
                              : LocationType.extraTwo)
                          : LocationType.to;
                  await locationController.searchLocation(context, value,
                      type: type);
                },
                onTap: () {
                  if (rideController.rideDetails != null) {
                    showCustomSnackBar('your_ride_is_ongoing_complete'.tr,
                        isError: true);
                  }
                },
              ),
            ),
          ),

          // Action Buttons - smaller and more refined
          const SizedBox(width: 6),

          if (onRemove != null) ...[
            _buildActionButton(
              icon: Icons.close_rounded,
              onTap: onRemove,
              color: Colors.red.withOpacity(0.1),
              iconColor: Colors.red,
              size: 28,
            ),
          ] else ...[
            _buildActionButton(
              icon: Icons
                  .gps_fixed_rounded, // GPS icon for "use current location"
              onTap: () {
                if (rideController.rideDetails != null) {
                  showCustomSnackBar('your_ride_is_ongoing_complete'.tr,
                      isError: true);
                } else {
                  LocationType type =
                      isPickup ? LocationType.from : LocationType.to;
                  RouteHelper.goPageAndHideTextField(
                    context,
                    PickMapScreen(
                      type: type,
                      oldLocationExist:
                          locationController.pickPosition.latitude > 0,
                    ),
                  );
                }
              },
              color: const Color(0xFF6366F1)
                  .withOpacity(0.1), // Indigo for map action
              iconColor: const Color(0xFF6366F1),
              size: 28,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    required Color iconColor,
    double size = 32,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: size * 0.5),
      ),
    );
  }

  Widget _buildAddressDropdownButton(LocationController locationController) {
    return GetBuilder<AddressController>(
      builder: (addressController) {
        return PopupMenuButton<Address>(
          offset: const Offset(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Get.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          elevation: 8,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.black.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColorDark.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              Icons.bookmark_outline_rounded,
              color: Theme.of(context).primaryColorDark,
              size: 16,
            ),
          ),
          itemBuilder: (BuildContext context) {
            if (addressController.addressList == null ||
                addressController.addressList!.isEmpty) {
              return [
                PopupMenuItem<Address>(
                  enabled: false,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_off_rounded,
                          color: Get.isDarkMode
                              ? Colors.white.withOpacity(0.5)
                              : Colors.black.withOpacity(0.5),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'no_address_found'.tr,
                          style: TextStyle(
                            color: Get.isDarkMode
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            }

            return addressController.addressList!.map((Address address) {
              return PopupMenuItem<Address>(
                value: address,
                child: Container(
                  width: 280,
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                  child: Row(
                    children: [
                      // Icon Container
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.15),
                              Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          address.addressLabel == 'home'
                              ? Icons.home_rounded
                              : address.addressLabel == 'office'
                                  ? Icons.work_rounded
                                  : Icons.location_on_rounded,
                          color: Theme.of(context).primaryColorDark,
                          size: 16,
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Address Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Label
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                address.addressLabel!.tr,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColorDark,
                                ),
                              ),
                            ),

                            const SizedBox(height: 4),

                            // Address
                            Text(
                              address.address ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Get.isDarkMode
                                    ? Colors.white.withOpacity(0.8)
                                    : const Color(0xFF374151),
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Selection Arrow
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color:
                            Theme.of(context).primaryColorDark.withOpacity(0.6),
                        size: 12,
                      ),
                    ],
                  ),
                ),
              );
            }).toList();
          },
          onSelected: (Address address) {
            // Set the selected address as destination (original way)
            locationController.setDestination(address);
          },
        );
      },
    );
  }

  Widget _buildAddStopButton(LocationController locationController) {
    return InkWell(
      onTap: () => locationController.setExtraRoute(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColorDark,
              Theme.of(context).primaryColorDark.withOpacity(0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColorDark.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 16,
        ),
      ),
    );
  }

  Widget _buildEntranceInput(LocationController locationController) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Get.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Get.isDarkMode
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
          width: 1,
        ),
      ),
      child: TextField(
        controller: locationController.entranceController,
        focusNode: locationController.entranceNode,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Get.isDarkMode
              ? Colors.white.withOpacity(0.9)
              : const Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          hintText: 'enter_entrance'.tr,
          hintStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: Get.isDarkMode
                ? Colors.white.withOpacity(0.4)
                : const Color(0xFF9CA3AF),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildModernEntranceButton(LocationController locationController) {
    return Container(
      width: double.infinity,
      child: InkWell(
        onTap: () => locationController.setAddEntrance(),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.02),
                Colors.black.withOpacity(0.06),
                Colors.black.withOpacity(0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.black.withOpacity(0.08),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Modern entrance icon
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.1),
                      Colors.black.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.black.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.door_front_door_outlined,
                  color: Colors.black.withOpacity(0.7),
                  size: 14,
                ),
              ),

              const SizedBox(width: 10),

              // Text
              Expanded(
                child: Text(
                  'add_entrance'.tr,
                  style: TextStyle(
                    color: Get.isDarkMode
                        ? Colors.white.withOpacity(0.7)
                        : Colors.black.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),

              // Arrow
              Icon(
                Icons.add_rounded,
                color: Colors.black.withOpacity(0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddEntranceButton(LocationController locationController) {
    return InkWell(
      onTap: () => locationController.setAddEntrance(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).primaryColorDark.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_rounded,
              color: Theme.of(context).primaryColorDark,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'add_entrance'.tr,
              style: TextStyle(
                color: Theme.of(context).primaryColorDark,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton(
    LocationController locationController,
    RideController rideController,
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1A),
            Colors.black,
            const Color(0xFF0A0A0A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColorDark.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Theme.of(context).primaryColorDark.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
          // Inner glow effect
          BoxShadow(
            color: Theme.of(context).primaryColorDark.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 0),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {
            _handleContinuePress(locationController, rideController, context);
          },
          borderRadius: BorderRadius.circular(16),
          splashColor: Theme.of(context).primaryColorDark.withOpacity(0.2),
          highlightColor: Theme.of(context).primaryColorDark.withOpacity(0.1),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              // Subtle inner border glow
              border: Border.all(
                color: Theme.of(context).primaryColorDark.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: rideController.loading
                ? Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColorDark,
                        strokeWidth: 2.5,
                      ),
                    ),
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icon with elegant styling
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.2),
                                Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.navigation_rounded,
                            color: Theme.of(context).primaryColorDark,
                            size: 18,
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Text with premium styling
                        Text(
                          'done'.tr.toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Theme.of(context)
                                    .primaryColorDark
                                    .withOpacity(0.3),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Arrow with glow
                        Icon(
                          Icons.arrow_forward_rounded,
                          color: Theme.of(context).primaryColorDark,
                          size: 20,
                          shadows: [
                            Shadow(
                              color: Theme.of(context)
                                  .primaryColorDark
                                  .withOpacity(0.5),
                              offset: const Offset(0, 0),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ],
                    )),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResultsOverlay(LocationController locationController) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 120, 20, 0),
      decoration: BoxDecoration(
        color: Get.isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Get.isDarkMode
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.06),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Get.isDarkMode
                ? Colors.black.withOpacity(0.4)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.builder(
        itemCount: locationController.predictionList.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              locationController.setLocation(
                fromSearch: true,
                locationController.predictionList[index].placeId!,
                locationController.predictionList[index].description!,
                null,
                type: locationController.locationType,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColorDark.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Theme.of(context).primaryColorDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      locationController.predictionList[index].description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Get.isDarkMode
                            ? Colors.white.withOpacity(0.9)
                            : const Color(0xFF1A1A1A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleContinuePress(
    LocationController locationController,
    RideController rideController,
    BuildContext context,
  ) {
    if (Get.find<ConfigController>().config!.maintenanceMode != null &&
        Get.find<ConfigController>()
                .config!
                .maintenanceMode!
                .maintenanceStatus ==
            1 &&
        Get.find<ConfigController>()
                .config!
                .maintenanceMode!
                .selectedMaintenanceSystem!
                .userApp ==
            1) {
      showCustomSnackBar('maintenance_mode_on_for_ride'.tr, isError: true);
    } else {
      if (locationController.fromAddress == null ||
          locationController.fromAddress!.address == null ||
          locationController.fromAddress!.address!.isEmpty) {
        showCustomSnackBar('pickup_location_is_required'.tr);
        FocusScope.of(context).requestFocus(pickLocationFocus);
      } else if (locationController.pickupLocationController.text.isEmpty) {
        showCustomSnackBar('pickup_location_is_required'.tr);
        FocusScope.of(context).requestFocus(pickLocationFocus);
      } else if (locationController.toAddress == null ||
          locationController.toAddress!.address == null ||
          locationController.toAddress!.address!.isEmpty) {
        showCustomSnackBar('destination_location_is_required'.tr);
        FocusScope.of(context).requestFocus(destinationLocationFocus);
      } else if (locationController
          .destinationLocationController.text.isEmpty) {
        showCustomSnackBar('destination_location_is_required'.tr);
        FocusScope.of(context).requestFocus(destinationLocationFocus);
      } else {
        rideController.getEstimatedFare(false).then((value) {
          if (value.statusCode == 200) {
            Get.find<LocationController>().initAddLocationData();
            Get.find<LocationController>()
                .setLastAddressList(locationController.toAddress!.address!);
            Get.to(() => const MapScreen(
                  fromScreen: MapScreenType.ride,
                  isShowCurrentPosition: false,
                ));
            Get.find<RideController>()
                .updateRideCurrentState(RideState.initial);
          }
        });
      }
    }
  }
}
