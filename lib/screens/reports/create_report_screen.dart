import 'package:flutter/material.dart';
import '../../repositories/reports_repository.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _reportsRepository = ReportsRepository();

  bool _isLoading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _reportsRepository.createReport(
        itemName: _itemNameController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم نشر البلاغ بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في نشر البلاغ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'إضافة بلاغ جديد',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Privacy notice
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: AppRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.no_photography_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      const Expanded(
                        child: Text(
                          'سياسة الخصوصية والأمان\n'
                          'حفاظاً على أمنك المعلوماتي، يمنع رفع الصور. يرجى كتابة وصف دقيق للعلامات المميزة، الخدوش، المحتويات الداخلية...',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Item name
                CustomTextField(
                  label: 'اسم الغرض',
                  hint: 'مثال: محفظة جلدية سوداء، آيفون 15...',
                  controller: _itemNameController,
                  validator: Validators.validateItemName,
                  prefixIcon: Icons.inventory_2_outlined,
                ),
                const SizedBox(height: AppSpacing.md),

                // Description
                CustomTextField(
                  label: 'الوصف التفصيلي',
                  hint:
                      'اكتب وصفاً دقيقاً للعلامات المميزة، الخدوش، المحتويات الداخلية...',
                  controller: _descriptionController,
                  validator: Validators.validateDescription,
                  maxLines: 5,
                  prefixIcon: Icons.description_outlined,
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  '* تفاصيل دقيقة تساعد على مطابقة غرضك بشكل أسرع',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: AppSpacing.md),

                // Location
                CustomTextField(
                  label: 'مكان الفقدان',
                  hint: 'مثال: شارع حدة،  حراز كافيه',
                  controller: _locationController,
                  validator: Validators.validateLocation,
                  prefixIcon: Icons.location_on_outlined,
                ),
                const SizedBox(height: AppSpacing.md),

                // Notes (optional)
                CustomTextField(
                  label: 'ملاحظات إضافية',
                  hint: 'وقت الفقدان، مكافأة مالية...',
                  controller: _notesController,
                  maxLines: 3,
                  prefixIcon: Icons.note_outlined,
                ),
                const SizedBox(height: AppSpacing.xl),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'نشر البلاغ',
                    icon: Icons.send,
                    onPressed: _handleSubmit,
                    isLoading: _isLoading,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Disclaimer
                const Text(
                  'بالضغط على "نشر البلاغ"، أنت توافق بنشر بياناتك لتسهيل عملية التواصل',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
