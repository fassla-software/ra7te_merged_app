import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:ride_sharing_user_app/features/home/domain/models/categoty_model.dart';
import 'package:ride_sharing_user_app/features/ride/controllers/ride_controller.dart';
import 'package:ride_sharing_user_app/features/set_destination/screens/set_destination_screen.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class CategoryWidget extends StatefulWidget {
  final Category category;
  final bool? isSelected;
  final bool fromSelect;
  final int index;
  final Function(void)? onTap;

  const CategoryWidget({
    super.key,
    required this.category,
    this.isSelected,
    this.fromSelect = false,
    required this.index,
    this.onTap,
  });

  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    // Start animation with slight delay based on index
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;
    final isSelected = widget.isSelected ?? false;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () {
                    Get.find<RideController>()
                        .setRideCategoryIndex(widget.index);
                    if (!widget.fromSelect) {
                      Get.to(() => const SetDestinationScreen());
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: isDark
                            ? [
                                Colors.white.withOpacity(0.05),
                                Colors.white.withOpacity(0.02),
                              ]
                            : [
                                Colors.white,
                                Colors.white.withOpacity(0.98),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColorDark
                            : isDark
                                ? Colors.white.withOpacity(0.08)
                                : Colors.black.withOpacity(0.05),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected) ...[
                          BoxShadow(
                            color: Theme.of(context)
                                .primaryColorDark
                                .withOpacity(0.25),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ] else ...[
                          BoxShadow(
                            color: isDark
                                ? Colors.black.withOpacity(0.2)
                                : Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                            spreadRadius: 0,
                          ),
                        ],
                      ],
                    ),
                    child: Row(
                      children: [
                        // Left Side - Vehicle Image
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isSelected
                                  ? [
                                      Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.2),
                                      Theme.of(context)
                                          .primaryColorDark
                                          .withOpacity(0.1),
                                    ]
                                  : [
                                      Colors.grey.withOpacity(0.08),
                                      Colors.grey.withOpacity(0.04),
                                    ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context)
                                      .primaryColorDark
                                      .withOpacity(0.3)
                                  : Colors.grey.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Stack(
                              children: [
                                // Vehicle Image
                                Positioned.fill(
                                  child: widget.category.id == '0'
                                      ? Image.asset(
                                          widget.category.image ?? '',
                                          fit: BoxFit.cover,
                                        )
                                      : ImageWidget(
                                          image:
                                              '${Get.find<ConfigController>().config?.imageBaseUrl?.vehicleCategory}/${widget.category.image}',
                                          height: 60,
                                          width: 60,
                                          fit: BoxFit.cover,
                                        ),
                                ),
                                // Offer Badge
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.orange,
                                          Colors.deepOrange,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.4),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.local_offer,
                                      color: Colors.white,
                                      size: 8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 18),

                        // Middle - Vehicle Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Vehicle Name
                              Text(
                                widget.category.name ?? '',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : Colors.black,
                                  letterSpacing: 0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 6),

                              // Distance and Time Info
                              GetBuilder<RideController>(
                                builder: (rideController) {
                                  return Row(
                                    children: [
                                      // Distance
                                      if (rideController
                                          .estimatedDistance.isNotEmpty) ...[
                                        Icon(
                                          Icons.route_rounded,
                                          size: 12,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.6)
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${rideController.estimatedDistance} km',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected
                                                ? Colors.black.withOpacity(0.7)
                                                : isDark
                                                    ? Colors.white
                                                        .withOpacity(0.6)
                                                    : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                      ],

                                      // Time
                                      if (rideController
                                          .estimatedDuration.isNotEmpty) ...[
                                        Icon(
                                          Icons.access_time_rounded,
                                          size: 12,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.6)
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rideController.estimatedDuration,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],

                                      // Fallback when no distance/time available
                                      if (rideController
                                              .estimatedDistance.isEmpty &&
                                          rideController
                                              .estimatedDuration.isEmpty) ...[
                                        Icon(
                                          Icons.local_taxi_rounded,
                                          size: 12,
                                          color: isDark
                                              ? Colors.white.withOpacity(0.6)
                                              : Colors.grey[600],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Available now',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isDark
                                                ? Colors.white.withOpacity(0.6)
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // Right Side - Fare and Selection
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Estimated Fare
                            GetBuilder<RideController>(
                              builder: (rideController) {
                                if (rideController.estimatedFare > 0) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.1),
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
                                    child: Text(
                                      '${rideController.estimatedFare.toStringAsFixed(0)} EGP',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),

                            const SizedBox(height: 8),

                            // Selection Indicator
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: isSelected
                                    ? LinearGradient(
                                        colors: [
                                          Theme.of(context).primaryColorDark,
                                          Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.8),
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                      ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).primaryColorDark
                                      : isDark
                                          ? Colors.white.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .primaryColorDark
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
