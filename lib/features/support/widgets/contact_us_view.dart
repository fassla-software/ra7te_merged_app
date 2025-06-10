import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/support/widgets/contact_with_widget.dart';
import 'package:ride_sharing_user_app/helper/open_whatapp.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/button_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({super.key});

  // Common transport app issues
  final List<Map<String, dynamic>> _commonIssues = const [
    {
      'title': 'Driver Not Arriving',
      'subtitle': 'Driver hasn\'t arrived at pickup location',
      'icon': Icons.location_off,
      'color': Colors.red,
    },
    {
      'title': 'Wrong Pickup Location',
      'subtitle': 'Driver went to wrong pickup address',
      'icon': Icons.wrong_location,
      'color': Colors.orange,
    },
    {
      'title': 'Payment Issues',
      'subtitle': 'Problems with payment processing',
      'icon': Icons.payment,
      'color': Colors.blue,
    },
    {
      'title': 'Car Breakdown',
      'subtitle': 'Vehicle broke down during trip',
      'icon': Icons.car_crash,
      'color': Colors.red,
    },
    {
      'title': 'Driver Behavior',
      'subtitle': 'Issues with driver conduct',
      'icon': Icons.person_remove,
      'color': Colors.purple,
    },
    {
      'title': 'App Technical Issues',
      'subtitle': 'App crashes or technical problems',
      'icon': Icons.bug_report,
      'color': Colors.grey,
    },
    {
      'title': 'Booking Cancelled',
      'subtitle': 'Unexpected booking cancellation',
      'icon': Icons.cancel,
      'color': Colors.orange,
    },
    {
      'title': 'Fare Disputes',
      'subtitle': 'Disagreement about trip fare',
      'icon': Icons.money_off,
      'color': Colors.green,
    },
    {
      'title': 'Lost Items',
      'subtitle': 'Left something in the vehicle',
      'icon': Icons.inventory_2,
      'color': Colors.brown,
    },
    {
      'title': 'Account Problems',
      'subtitle': 'Issues with user account',
      'icon': Icons.account_circle,
      'color': Colors.indigo,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Center(
            child: Image.asset(Images.helpAndSupport, width: 172, height: 129)),
        SizedBox(height: MediaQuery.of(context).size.height * 0.05),

        // Common Issues Section
        _buildCommonIssuesSection(context),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        // Divider
        Container(
          width: double.infinity,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                Get.isDarkMode
                    ? Colors.white.withOpacity(0.1)
                    : Colors.black.withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        // Original Contact Methods
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Other Contact Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Get.isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          ContactWithWidget(
            title: 'contact_us_through_email',
            subTitle: 'you_can_send_us_email_through',
            message: "typically_the_support_team_send_you_any_feedback",
            data: Get.find<ConfigController>().config!.businessContactEmail!,
          ),
          const SizedBox(height: Dimensions.paddingSizeSignUp),
          ContactWithWidget(
            title: 'contact_us_through_phone',
            subTitle: 'contact_us_through_our_customer_care_number',
            message: "talk_with_our_customer",
            data: Get.find<ConfigController>().config!.businessContactPhone!,
          ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeExtraLarge),

        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ButtonWidget(
            width: Get.width / 2.65,
            radius: Dimensions.radiusExtraLarge,
            buttonText: 'email'.tr,
            icon: Icons.email,
            onPressed: () async {
              await launchUrl(
                Uri(
                    scheme: 'mailto',
                    path: Get.find<ConfigController>()
                        .config!
                        .businessContactEmail!),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
          SizedBox(width: MediaQuery.of(context).size.width / 20),
          ButtonWidget(
            width: Get.width / 2.65,
            radius: Dimensions.radiusExtraLarge,
            buttonText: 'call'.tr,
            icon: Icons.call,
            onPressed: () async {
              await launchUrl(
                Uri(
                    scheme: 'tel',
                    path: Get.find<ConfigController>()
                        .config!
                        .businessContactPhone!),
                mode: LaunchMode.externalApplication,
              );
            },
          ),
        ]),
        const SizedBox(height: 150),
      ]),
    );
  }

  Widget _buildCommonIssuesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColorDark,
                    Theme.of(context).primaryColorDark.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Common Issues',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Get.isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          'Tap on any issue to get instant help via WhatsApp',
          style: TextStyle(
            fontSize: 14,
            color: Get.isDarkMode
                ? Colors.white.withOpacity(0.7)
                : Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 20),

        // Issues Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          itemCount: _commonIssues.length,
          itemBuilder: (context, index) {
            final issue = _commonIssues[index];
            return _buildIssueCard(context, issue);
          },
        ),
      ],
    );
  }

  Widget _buildIssueCard(BuildContext context, Map<String, dynamic> issue) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => openWhatsApp(issue['title']),
        borderRadius: BorderRadius.circular(16),
        child: Container(
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
                  : Colors.black.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Get.isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (issue['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (issue['color'] as Color).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  issue['icon'],
                  color: issue['color'],
                  size: 20,
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                issue['title'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Get.isDarkMode ? Colors.white : Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Subtitle
              Expanded(
                child: Text(
                  issue['subtitle'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Get.isDarkMode
                        ? Colors.white.withOpacity(0.6)
                        : Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // WhatsApp indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF25D366).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat,
                          color: const Color(0xFF25D366),
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'WhatsApp',
                          style: TextStyle(
                            fontSize: 8,
                            color: const Color(0xFF25D366),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
