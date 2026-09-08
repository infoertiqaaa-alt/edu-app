import 'package:ai_barcode_scanner/ai_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mr/core/theme/app_colors.dart';
import '../cubit/scan_qr_cubit.dart';
import '../cubit/scan_qr_state.dart';
import 'scan_qr_result_view.dart';

class ScanQrCameraView extends StatefulWidget {
  const ScanQrCameraView({super.key});

  @override
  State<ScanQrCameraView> createState() => _ScanQrCameraViewState();
}

class _ScanQrCameraViewState extends State<ScanQrCameraView> {
  // بنمنع بيها إن نفس الكود يترسل أكتر من مرة، لأن onDetect ممكن ينده
  // كذا مرة على نفس الفريم لحد ما نعمل Navigator.pop / pushReplacement
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final qrCodeString = capture.barcodes.first.rawValue;
    if (qrCodeString == null || qrCodeString.isEmpty) return;

    setState(() => _isProcessing = true);
    // هنا بيتبعت الـ GET request تلقائيًا بالـ qr_code_string اللي اتقرا من الكاميرا
    context.read<ScanQrCubit>().scanAndFetch(qrCodeString);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScanQrCubit, ScanQrState>(
      listener: (context, state) {
        if (state is ScanQrSuccess) {
          final scanQrCubit = context.read<ScanQrCubit>();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: scanQrCubit,
                child: const ScanQrResultView(),
              ),
            ),
          );
        }

        if (state is ScanQrError) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade400,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            AiBarcodeScanner(
              controller: MobileScannerController(
                formats: [BarcodeFormat.qrCode],
              ),
              overlayConfig: const ScannerOverlayConfig(
                scannerAnimation: ScannerAnimation.fullWidth,
                scannerBorder: ScannerBorder.corner,
                borderColor: AppColors.primary,
                successColor: Colors.green,
                errorColor: Colors.red,
                borderRadius: 24,
                cornerLength: 40,
              ),
              galleryButtonType: GalleryButtonType.icon,
              onDetect: _onDetect,
            ),

            // ---- Overlay تحميل وقت انتظار الـ API response ----
            if (_isProcessing)
              Container(
                color: Colors.black54,
child: Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    ),
              ),
          ],
        ),
      ),
    );
  }
}
