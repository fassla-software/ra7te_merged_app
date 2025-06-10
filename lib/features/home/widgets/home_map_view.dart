import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_sharing_user_app/features/map/controllers/map_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/theme/theme_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/features/location/controllers/location_controller.dart';

class HomeMapView extends StatefulWidget {
  final String title;
  const HomeMapView({super.key, required this.title});

  @override
  HomeMapViewState createState() => HomeMapViewState();
}

class HomeMapViewState extends State<HomeMapView> {
  GoogleMapController? _mapController;
  int isFirstCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(builder: (mapController) {
      return GetBuilder<LocationController>(builder: (locationController) {
        Completer<GoogleMapController> mapCompleter =
            Completer<GoogleMapController>();
        if (mapController.mapController != null) {
          mapCompleter.complete(mapController.mapController);
        }
        return mapController.nearestDeliveryManMarkers != null
            ? Padding(
                padding: const EdgeInsets.only(
                    bottom: Dimensions.paddingSizeDefault),
                child: Column(children: [
                  Expanded(
                    child: GoogleMap(
                      style: Get.isDarkMode
                          ? Get.find<ThemeController>().darkMap
                          : Get.find<ThemeController>().lightMap,
                      markers: mapController.nearestDeliveryManMarkers!.toSet(),
                      initialCameraPosition: CameraPosition(
                          target: LatLng(
                            Get.find<LocationController>().position.latitude !=
                                    0
                                ? Get.find<LocationController>()
                                    .position
                                    .latitude
                                : Get.find<LocationController>()
                                        .getUserAddress()
                                        ?.latitude ??
                                    0,
                            Get.find<LocationController>().position.longitude !=
                                    0
                                ? Get.find<LocationController>()
                                    .position
                                    .longitude
                                : Get.find<LocationController>()
                                        .getUserAddress()
                                        ?.longitude ??
                                    0,
                          ),
                          zoom: 16),
                      minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                      onMapCreated: (gController) {
                        _mapController = gController;
                        // Use current position for center bounds, fallback to saved address
                        double lat = Get.find<LocationController>()
                                    .position
                                    .latitude !=
                                0
                            ? Get.find<LocationController>().position.latitude
                            : Get.find<LocationController>()
                                    .getUserAddress()
                                    ?.latitude ??
                                0;
                        double lng = Get.find<LocationController>()
                                    .position
                                    .longitude !=
                                0
                            ? Get.find<LocationController>().position.longitude
                            : Get.find<LocationController>()
                                    .getUserAddress()
                                    ?.longitude ??
                                0;

                        calculateCenterBound(lat, lng);
                        mapController.setMapController(gController);
                      },
                      myLocationEnabled: true,

                      myLocationButtonEnabled: false,
                      zoomGesturesEnabled: true,
                      scrollGesturesEnabled: true, // تفعيل السحب على الخريطة
                      rotateGesturesEnabled: true, // تفعيل الدوران
                      tiltGesturesEnabled: true, // تفعيل الإمالة
                    ),
                  )
                ]),
              )
            : GoogleMap(
                style: Get.isDarkMode
                    ? Get.find<ThemeController>().darkMap
                    : Get.find<ThemeController>().lightMap,
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                      Get.find<LocationController>()
                              .getUserAddress()
                              ?.latitude ??
                          0,
                      Get.find<LocationController>()
                              .getUserAddress()
                              ?.longitude ??
                          0,
                    ),
                    zoom: 16),
                minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
              );
      });
    });
  }

  LatLng calculateCenterBound(double lat, double lng) {
    double searchRadius =
        (Get.find<ConfigController>().config?.searchRadius ?? 0) / 2;
    // Calculating coordinates for center left , center right ,center top, center bottom
    List<LatLng> list = [];
    list.add(calculateOffset(
        LatLng(lat, lng), searchRadius, 270)); // 270 degrees (West lat-lng)
    list.add(calculateOffset(
        LatLng(lat, lng), searchRadius, 90)); // 270 degrees (East  lat-lng)
    list.add(calculateOffset(
        LatLng(lat, lng), searchRadius, 180)); // 270 degrees (South  lat-lng)
    list.add(calculateOffset(
        LatLng(lat, lng), searchRadius, 360)); // 270 degrees (North  lat-lng)
    LatLngBounds bounds =
        Get.find<MapController>().boundWithMaximumLatLngPoint(list);
    LatLng centerBounds = LatLng(
      (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
      (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
    );

    if (isFirstCount == 0) {
      isFirstCount++;
      Get.find<MapController>()
          .zoomToFit(_mapController, bounds, centerBounds, 0);
    }
    return centerBounds;
  }

  LatLng calculateOffset(LatLng center, double distance, double bearing) {
    const double earthRadius = 6371.0; // Radius of the Earth in kilometers
    double radLat = radians(center.latitude);
    double radLon = radians(center.longitude);
    double radBearing = radians(bearing);
    double newLat = asin(sin(radLat) * cos(distance / earthRadius) +
        cos(radLat) * sin(distance / earthRadius) * cos(radBearing));
    double newLon = radLon +
        atan2(sin(radBearing) * sin(distance / earthRadius) * cos(radLat),
            cos(distance / earthRadius) - sin(radLat) * sin(newLat));
    return LatLng(degrees(newLat), degrees(newLon));
  }

  double radians(double degrees) {
    return degrees * pi / 180;
  }

  double degrees(double radians) {
    return radians * 180 / pi;
  }
}
