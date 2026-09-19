import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Stateless add/edit note dialog used in the lesson detail screen.
///
/// The [controller] is owned and disposed by the caller so text survives
/// rebuilds; [onSaved] is invoked with the trimmed content when حفظ is
/// pressed. Using a bare StatelessWidget here keeps the widget stateless —
/// dialogs are short-lived and their own state (if any) lives upstream.
class AddNoteDialog extends StatelessWidget {
  const AddNoteDialog({
    super.key,
    required this.controller,
    this.isEditing = false,
    required this.onSaved,
  });

  final TextEditingController controller;
  final bool isEditing;
  final ValueChanged<String> onSaved;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section: Title & Close Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'تعديل الملاحظة' : 'إضافة ملاحظة',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1D1E),
                    fontFamily: 'Cairo',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF9E9E9E)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Input Field Section
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: const Color(0xFFE9ECEF), width: 1),
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                maxLines: 5,
                maxLength: 500,
                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1D1E)),
                decoration: InputDecoration(
                  hintText: 'اكتب ملاحظتك هنا...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFADB5BD),
                    fontSize: 14,
                    fontFamily: 'Cairo',
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16.0),
                  counterStyle: const TextStyle(
                    color: Color(0xFFADB5BD),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE9ECEF)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style: GoogleFonts.cairo(
                        color: const Color(0xFF6C757D),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final content = controller.text.trim();
                      if (content.isEmpty) return;
                      onSaved(content);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5722),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    child: Text(
                      'حفظ',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
