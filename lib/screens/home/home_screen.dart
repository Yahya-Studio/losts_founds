import 'package:flutter/material.dart';
import '../../models/report_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/reports_repository.dart';
import '../../utils/constants.dart';
import '../../widgets/common/loading_widget.dart' as custom;
import '../../widgets/report_card.dart';
import '../reports/create_report_screen.dart';
import '../reports/my_reports_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _reportsRepository = ReportsRepository();
  final _authRepository = AuthRepository();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: _currentIndex == 0 ? _buildAppBar() : null,
        body: _buildBody(),
        floatingActionButton: _currentIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const CreateReportScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
              )
            : null,
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      title: const Text(
        'البلاغات النشطة',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: () {
            // TODO: Implement filter
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('تصفية البلاغات')));
          },
        ),
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // Show menu
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildReportsTab();
      case 1:
        return const MyReportsScreen();
      case 2:
        return const ProfileScreen();
      default:
        return _buildReportsTab();
    }
  }

  Widget _buildReportsTab() {
    return Column(
      children: [
        // Info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: AppRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'لا تشارك معلومات حساسة مثل أرقام الحسابات البنكية عبر الهاتف',
                  style: TextStyle(fontSize: 12, color: AppColors.primary),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),

        // Reports list
        Expanded(
          child: StreamBuilder<List<Report>>(
            stream: _reportsRepository.getAllReportsStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const custom.LoadingWidget(
                  message: 'جاري تحميل البلاغات...',
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
                return custom.EmptyStateWidget(
                  message: 'لا توجد بلاغات حالياً',
                  icon: Icons.inventory_2_outlined,
                  action: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateReportScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('إنشاء بلاغ جديد'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final currentUserId = _authRepository.currentUser?.id;
                    final isOwner = report.ownerId == currentUserId;

                    return ReportCard(
                      report: report,
                      isOwner: isOwner,
                      onFoundPressed: () => _handleFoundPressed(report),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _handleFoundPressed(Report report) async {
    final currentUserId = _authRepository.currentUser?.id;
    if (currentUserId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد العثور على الغرض'),
          content: const Text(
            'هل وجدت هذا الغرض فعلاً؟ سيتم إشعار صاحب البلاغ.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('نعم، وجدته'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _reportsRepository.markAsFound(
          reportId: report.id,
          finderId: currentUserId,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إشعار صاحب البلاغ بنجاح'),
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

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
        BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'بلاغاتي'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
      ],
    );
  }
}
