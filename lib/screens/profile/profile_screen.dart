import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_widget.dart' as custom;
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userRepository = UserRepository();
  final _authRepository = AuthRepository();

  AppUser? _currentUser;
  Map<String, int>? _statistics;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final user = await _userRepository.getCurrentUserProfile();
      final stats = user != null
          ? await _userRepository.getUserStatistics(user.id)
          : null;

      setState(() {
        _currentUser = user;
        _statistics = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const custom.LoadingWidget(message: 'جاري تحميل البيانات...');
    }

    if (_currentUser == null) {
      return const Center(child: Text('خطأ في تحميل البيانات'));
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          title: const Text(
            'الملف الشخصي',
            style: TextStyle(color: Colors.white),
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                // Settings
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Profile header
              Container(
                width: double.infinity,
                color: AppColors.primary,
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Name
                    Text(
                      _currentUser!.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Phone
                    Text(
                      _currentUser!.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                  ],
                ),
              ),

              // Statistics
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: AppRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      'تم الحل',
                      (_statistics?['total_reports'] ?? 0) -
                          (_statistics?['active_reports'] ?? 0),
                    ),
                    Container(width: 1, height: 40, color: AppColors.divider),
                    _buildStatItem(
                      'بلاغ نشط',
                      _statistics?['active_reports'] ?? 0,
                    ),
                  ],
                ),
              ),

              // My Reports section
              _buildSection(
                title: 'بلاغاتي',
                child: Column(
                  children: [
                    _buildReportStatusTile(
                      'مفقود',
                      'مفتوح',
                      AppColors.statusOpen,
                      Icons.inventory_2_outlined,
                    ),
                    _buildReportStatusTile(
                      'مفقود',
                      'مغلق',
                      AppColors.statusClosed,
                      Icons.check_circle_outline,
                    ),
                    _buildReportStatusTile(
                      'معثور عليه',
                      'مغلق',
                      AppColors.success,
                      Icons.done_all,
                    ),
                  ],
                ),
              ),

              // Account Settings
              _buildSection(
                title: 'إعدادات الحساب',
                child: Column(
                  children: [
                    _buildSettingTile(
                      'تعديل الاسم',
                      Icons.edit,
                      () => _showEditNameDialog(),
                    ),
                    _buildSettingTile(
                      'رقم الهاتف',
                      Icons.phone,
                      () => _showEditPhoneDialog(),
                    ),
                    _buildSettingTile(
                      'كلمة المرور',
                      Icons.lock_outline,
                      () => _showChangePasswordDialog(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Logout button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'تسجيل الخروج',
                    icon: Icons.logout,
                    backgroundColor: Colors.red.shade50,
                    textColor: AppColors.error,
                    onPressed: _handleLogout,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(title, style: AppTextStyles.heading3),
          ),
          const Divider(height: 1),
          child,
        ],
      ),
    );
  }

  Widget _buildReportStatusTile(
    String title,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(title, textAlign: TextAlign.right),
      subtitle: Text(subtitle, textAlign: TextAlign.right),
      trailing: const Icon(Icons.arrow_back_ios, size: 16),
      onTap: () {
        // Navigate to filtered reports
      },
    );
  }

  Widget _buildSettingTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, textAlign: TextAlign.right),
      trailing: const Icon(Icons.arrow_back_ios, size: 16),
      onTap: onTap,
    );
  }

  Future<void> _showEditNameDialog() async {
    final controller = TextEditingController(text: _currentUser!.name);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل الاسم'),
          content: Form(
            key: formKey,
            child: CustomTextField(
              label: 'الاسم الجديد',
              controller: controller,
              validator: Validators.validateName,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _userRepository.updateProfile(
                      userId: _currentUser!.id,
                      name: controller.text.trim(),
                    );
                    await _loadUserData();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث الاسم'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditPhoneDialog() async {
    final controller = TextEditingController(text: _currentUser!.phone);
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل رقم الهاتف'),
          content: Form(
            key: formKey,
            child: CustomTextField(
              label: 'رقم الهاتف الجديد',
              controller: controller,
              validator: Validators.validatePhone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _userRepository.updateProfile(
                      userId: _currentUser!.id,
                      phone: controller.text.trim(),
                    );
                    await _loadUserData();
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديث رقم الهاتف'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تغيير كلمة المرور'),
          content: Form(
            key: formKey,
            child: CustomTextField(
              label: 'كلمة المرور الجديدة',
              controller: controller,
              validator: Validators.validatePassword,
              obscureText: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await _authRepository.updatePassword(controller.text);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تغيير كلمة المرور'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('خطأ: ${e.toString()}'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      await _authRepository.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }
}
