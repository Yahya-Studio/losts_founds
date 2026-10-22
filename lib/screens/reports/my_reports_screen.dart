import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/reports_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart' as custom;
import '../../widgets/report_card.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  final _reportsRepository = ReportsRepository();
  final _authRepository = AuthRepository();

  @override
  Widget build(BuildContext context) {
    final currentUserId = _authRepository.currentUser?.id;

    if (currentUserId == null) {
      return const Center(child: Text('يجب تسجيل الدخول أولاً'));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text('بلاغاتي', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder<List<Report>>(
          stream: _reportsRepository.getUserReportsStream(currentUserId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const custom.LoadingWidget(
                message: 'جاري تحميل بلاغاتك...',
              );
            }

            if (snapshot.hasError) {
              return custom.ErrorWidget(
                message: 'حدث خطأ في تحميل البلاغات',
                onRetry: () => setState(() {}),
              );
            }

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return const custom.EmptyStateWidget(
                message: 'لم تقم بإنشاء أي بلاغات بعد',
                icon: Icons.inventory_2_outlined,
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return ReportCard(
                  report: report,
                  isOwner: true,
                  onTap: () => _showReportOptions(report),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showReportOptions(Report report) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('إدارة البلاغ', style: AppTextStyles.heading2),
              const SizedBox(height: AppSpacing.lg),

              // Mark as contacted
              if (report.status == ReportStatus.open)
                ListTile(
                  leading: const Icon(
                    Icons.phone,
                    color: AppColors.statusContacted,
                  ),
                  title: const Text('تم التواصل'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateReportStatus(report, ReportStatus.contacted);
                  },
                ),

              // Mark as received
              if (report.status != ReportStatus.closed)
                ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                  ),
                  title: const Text('تم الاستلام'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateReportStatus(report, ReportStatus.closed);
                  },
                ),

              // Reopen
              if (report.status == ReportStatus.closed)
                ListTile(
                  leading: const Icon(Icons.refresh, color: AppColors.primary),
                  title: const Text('إعادة فتح البلاغ'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateReportStatus(report, ReportStatus.open);
                  },
                ),

              const Divider(),

              // Delete
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('حذف البلاغ'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmDelete(report);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateReportStatus(
    Report report,
    ReportStatus newStatus,
  ) async {
    try {
      await _reportsRepository.updateReportStatus(
        reportId: report.id,
        status: newStatus,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تحديث حالة البلاغ'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _confirmDelete(Report report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد من حذف هذا البلاغ؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _reportsRepository.deleteReport(report.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم حذف البلاغ'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('خطأ: ${e.toString()}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
