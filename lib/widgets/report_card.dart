import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/report_model.dart';
import '../utils/constants.dart';
import '../widgets/common/custom_button.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final bool isOwner;
  final VoidCallback? onFoundPressed;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.report,
    this.isOwner = false,
    this.onFoundPressed,
    this.onTap,
  });

  Color _getStatusColor() {
    switch (report.status) {
      case ReportStatus.open:
        return AppColors.statusOpen;
      case ReportStatus.contacted:
        return AppColors.statusContacted;
      case ReportStatus.closed:
        return AppColors.statusClosed;
    }
  }

  IconData _getItemIcon() {
    final itemName = report.itemName.toLowerCase();
    if (itemName.contains('محفظة') || itemName.contains('wallet')) {
      return Icons.account_balance_wallet;
    } else if (itemName.contains('هاتف') ||
        itemName.contains('جوال') ||
        itemName.contains('phone')) {
      return Icons.phone_android;
    } else if (itemName.contains('مفاتيح') || itemName.contains('key')) {
      return Icons.vpn_key;
    } else if (itemName.contains('حقيبة') || itemName.contains('bag')) {
      return Icons.work_outline;
    } else if (itemName.contains('جواز') || itemName.contains('passport')) {
      return Icons.credit_card;
    } else {
      return Icons.inventory_2_outlined;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.circular(AppRadius.md),
        side: BorderSide(color: _getStatusColor(), width: 3),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Header with icon and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: AppRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      report.status.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Item icon and name
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Text(
                            report.itemName,
                            style: AppTextStyles.heading3,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: _getStatusColor().withOpacity(0.1),
                            borderRadius: AppRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            _getItemIcon(),
                            color: _getStatusColor(),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Description
              Text(
                report.description,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.right,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),

              // Location
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      report.location,
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.right,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // Date and time
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'منذ ${timeFormat.format(report.createdAt)} - ${dateFormat.format(report.createdAt)}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),

              const Divider(height: AppSpacing.lg),

              // Action buttons
              if (!isOwner && report.status != ReportStatus.closed)
                Row(
                  children: [
                    // Found button
                    if (report.status == ReportStatus.open)
                      Expanded(
                        child: CustomButton(
                          text: 'وجدت الغرض',
                          icon: Icons.check_circle_outline,
                          backgroundColor: AppColors.success,
                          onPressed: onFoundPressed,
                        ),
                      ),
                    if (report.status == ReportStatus.open)
                      const SizedBox(width: AppSpacing.sm),
                    // Call button
                    Expanded(
                      flex: report.status == ReportStatus.open ? 1 : 2,
                      child: CustomButton(
                        text: 'اتصال',
                        icon: Icons.phone,
                        backgroundColor: AppColors.primary,
                        onPressed: () => _makePhoneCall(report.ownerPhone),
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
