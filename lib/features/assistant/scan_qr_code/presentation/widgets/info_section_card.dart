import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:teacher/core/theme/app_colors.dart';

class InfoRowData {
  final String label;
  final String value;
  const InfoRowData({required this.label, required this.value});
}

/// كارت أبيض بعنوان + سطرين (label فوق و value تحته) - زي كارت
/// "المعلومات الشخصية" و"ولي الأمر" في تصميم شاشة نتيجة المسح
class InfoSectionCard extends StatelessWidget {
  final String title;
  final List<InfoRowData> rows;

  const InfoSectionCard({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            title,
            style: GoogleFonts.cairo(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14.h),
          for (int i = 0; i < rows.length; i++) ...[
            _InfoRow(label: rows[i].label, value: rows[i].value),
            if (i != rows.length - 1) SizedBox(height: 14.h),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, color: Colors.black45),
        ),
        SizedBox(height: 4.h),
        Text(
          value.isNotEmpty ? value : '—',
          style: GoogleFonts.cairo(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
