import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mr/core/di/service_locator.dart';
import 'package:mr/core/theme/app_colors.dart';
import 'package:mr/core/widgets/student_avatar.dart';
import '../../data/models/attendance_report_model.dart';
import '../../data/models/financial_report_model.dart';
import '../../data/models/reports_model.dart';
import '../../data/models/student_report_model.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportsCubit>()..getReports(),
      child: const _ReportsBody(),
    );
  }
}

class _ReportsBody extends StatelessWidget {
  const _ReportsBody();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F7F9),
        body: Column(
          children: [
            const _ReportsHeader(),
            Expanded(
              child: BlocBuilder<ReportsCubit, ReportsState>(
                builder: (context, state) {
                  if (state is ReportsLoading || state is ReportsInitial) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is ReportsError) {
                    return _ReportsError(
                      message: state.message,
                      onRetry: () => context.read<ReportsCubit>().getReports(),
                    );
                  }

                  final reports = (state as ReportsLoaded).reports;
                  return RefreshIndicator(
                    onRefresh: () => context.read<ReportsCubit>().getReports(),
                    child: _ReportsContent(reports: reports),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          child: Row(
            children: [
             
              const Spacer(),
              Text(
                'التقارير',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              SizedBox( height: 70.w),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportsError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ReportsError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.w,
              color: AppColors.grey,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'حاول تاني',
                style: GoogleFonts.cairo(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final ReportsModel reports;

  const _ReportsContent({required this.reports});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (reports.student != null) ...[
            _StudentSummaryCard(student: reports.student!),
            SizedBox(height: 16.h),
          ],
          _AttendanceSectionCard(attendance: reports.attendance),
          SizedBox(height: 16.h),
          _FinancialSectionCard(financials: reports.financials),
        ],
      ),
    );
  }
}

class _StudentSummaryCard extends StatelessWidget {
  final StudentReportModel student;

  const _StudentSummaryCard({required this.student});

  @override
  Widget build(BuildContext context) {
    final name = student.name.trim();
    final code = student.studentCode.trim();
    final grade = student.grade.trim();
    final group = student.groupName.trim();

    if (name.isEmpty && code.isEmpty && grade.isEmpty && group.isEmpty) {
      return const SizedBox.shrink();
    }

    final groupText = [
      grade,
      group,
    ].where((value) => value.isNotEmpty).join(' - ');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          StudentAvatar(imageUrl: student.profileImage, radius: 30.r),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                if (code.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    'كود الطالب: $code',
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (groupText.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    groupText,
                    style: GoogleFonts.cairo(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSectionCard extends StatelessWidget {
  final AttendanceReportModel? attendance;

  const _AttendanceSectionCard({this.attendance});

  @override
  Widget build(BuildContext context) {
    final total = attendance?.total ?? 0;
    final records = attendance?.records ?? const <AttendanceRecordModel>[];
    final hasRecords = records.isNotEmpty;

    return _ReportCard(
      title: 'تفاصيل حضور المحاضرات',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatRow(label: 'عدد مرات الحضور', value: total.toString()),
          SizedBox(height: 16.h),
          if (hasRecords)
            _AttendanceRecordsList(records: records)
          else
            const _EmptyState(message: 'لا توجد سجلات حضور'),
        ],
      ),
    );
  }
}

class _AttendanceRecordsList extends StatelessWidget {
  final List<AttendanceRecordModel> records;

  const _AttendanceRecordsList({required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < records.length; i++) ...[
          _AttendanceRecordRow(record: records[i]),
          if (i != records.length - 1)
            Divider(height: 16.h, color: Colors.black.withValues(alpha: 0.06)),
        ],
      ],
    );
  }
}

class _AttendanceRecordRow extends StatelessWidget {
  final AttendanceRecordModel record;

  const _AttendanceRecordRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatArabicDate(record.date);
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.primary,
            size: 18.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            formattedDate ?? 'تاريخ الحضور',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _FinancialSectionCard extends StatelessWidget {
  final FinancialReportModel? financials;

  const _FinancialSectionCard({this.financials});

  @override
  Widget build(BuildContext context) {
    final total = financials?.total ?? 0;
    final records = financials?.records ?? const <FinancialRecordModel>[];
    final hasRecords = records.isNotEmpty;

    return _ReportCard(
      title: 'الشؤون المالية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StatRow(label: 'إجمالي المعاملات المالية', value: total.toString()),
          SizedBox(height: 16.h),
          if (hasRecords)
            _FinancialRecordsList(records: records)
          else
            const _EmptyState(message: 'لا توجد معاملات مالية'),
        ],
      ),
    );
  }
}

class _FinancialRecordsList extends StatelessWidget {
  final List<FinancialRecordModel> records;

  const _FinancialRecordsList({required this.records});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < records.length; i++) ...[
          _FinancialRecordRow(record: records[i]),
          if (i != records.length - 1)
            Divider(height: 16.h, color: Colors.black.withValues(alpha: 0.06)),
        ],
      ],
    );
  }
}

class _FinancialRecordRow extends StatelessWidget {
  final FinancialRecordModel record;

  const _FinancialRecordRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final values = record.data.values
        .where((value) => value != null && value.toString().trim().isNotEmpty)
        .map((value) => value.toString())
        .join(' - ');

    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: const Color(0xFF3E8E4F).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_rounded,
            color: const Color(0xFF3E8E4F),
            size: 18.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            values.isEmpty ? 'معاملة مالية' : values,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ReportCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 6.w,
                height: 18.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 36.w, color: AppColors.grey),
          SizedBox(height: 8.h),
          Text(
            message,
            style: GoogleFonts.cairo(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18.r),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

const List<String> _arabicMonths = [
  'يناير',
  'فبراير',
  'مارس',
  'أبريل',
  'مايو',
  'يونيو',
  'يوليو',
  'أغسطس',
  'سبتمبر',
  'أكتوبر',
  'نوفمبر',
  'ديسمبر',
];

String? _formatArabicDate(String? date) {
  final trimmed = date?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  final parsed = DateTime.tryParse(trimmed);
  if (parsed == null) return trimmed;
  return '${parsed.day} ${_arabicMonths[parsed.month - 1]} ${parsed.year}';
}
