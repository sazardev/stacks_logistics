import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../container_tracking/presentation/pages/container_list_page.dart';
import '../blocs/barcode_scanner_bloc.dart';
import '../blocs/barcode_scanner_event.dart';
import '../blocs/barcode_scanner_state.dart';
import '../widgets/scanner_overlay.dart';
import '../widgets/scan_result_bottom_sheet.dart';

/// Barcode/QR Code scanner page
class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late MobileScannerController _scannerController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<BarcodeScannerBloc>()..add(const InitializeScanner()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.surface,
          title: Text(
            'Scan Container Code',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.surface,
            ),
          ),
          actions: [
            BlocBuilder<BarcodeScannerBloc, BarcodeScannerState>(
              builder: (context, state) {
                final bool canToggleFlash =
                    state is ScannerScanning ||
                    state is ScannerReady ||
                    state is BarcodeScanSuccess;

                return IconButton(
                  onPressed: canToggleFlash
                      ? () => context.read<BarcodeScannerBloc>().add(
                          const ToggleFlashlight(),
                        )
                      : null,
                  icon: Icon(
                    _getFlashlightIcon(state),
                    color: AppColors.surface,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () => _showScanHistory(context),
              icon: const Icon(Icons.history, color: AppColors.surface),
            ),
          ],
        ),
        body: BlocConsumer<BarcodeScannerBloc, BarcodeScannerState>(
          listener: (context, state) {
            if (state is BarcodeScanSuccess) {
              // Vibrate on successful scan (if available)
              // HapticFeedback.lightImpact();
            } else if (state is ContainerFoundByBarcode) {
              _showScanResult(context, state);
            } else if (state is ContainerNotFoundByBarcode) {
              _showScanResult(context, state);
            } else if (state is BarcodeScannerError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is BarcodeScannerLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state is CameraPermissionDenied) {
              return _buildPermissionDeniedView(context);
            }

            if (state is BarcodeScannerError) {
              return _buildErrorView(context, state.message);
            }

            if (state is ScannerReady && !state.hasPermission) {
              return _buildRequestPermissionView(context);
            }

            return _buildScannerView(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildScannerView(BuildContext context, BarcodeScannerState state) {
    return Stack(
      children: [
        // Camera preview
        MobileScanner(
          controller: _scannerController,
          onDetect: (barcodeCapture) {
            final barcode = barcodeCapture.barcodes.first;
            if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
              // Convert to our domain model and add event
              // This is handled in the device data source
            }
          },
        ),
        // Scanner overlay
        const ScannerOverlay(),
        // Scanning instructions
        _buildInstructions(state),
        // Control buttons
        _buildControlButtons(context, state),
      ],
    );
  }

  Widget _buildInstructions(BarcodeScannerState state) {
    String instruction = 'Position the code within the frame';

    if (state is ScannerScanning) {
      instruction = 'Scanning... Keep the camera steady';
    } else if (state is BarcodeScanSuccess) {
      instruction = 'Code detected! Processing...';
    }

    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.textPrimary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          instruction,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.surface),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildControlButtons(BuildContext context, BarcodeScannerState state) {
    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Start/Stop scanning button
          FloatingActionButton(
            heroTag: 'scan',
            backgroundColor: AppColors.primary,
            onPressed: () {
              if (state is ScannerScanning) {
                context.read<BarcodeScannerBloc>().add(const StopScanning());
              } else if (state is ScannerReady) {
                context.read<BarcodeScannerBloc>().add(const StartScanning());
              }
            },
            child: Icon(
              state is ScannerScanning ? Icons.stop : Icons.play_arrow,
              color: AppColors.surface,
              size: 32,
            ),
          ),
          // Manual input button
          FloatingActionButton(
            heroTag: 'manual',
            backgroundColor: AppColors.secondary,
            onPressed: () => _showManualInputDialog(context),
            child: const Icon(
              Icons.keyboard,
              color: AppColors.surface,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionDeniedView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 80,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Camera Permission Required',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To scan barcodes and QR codes, please grant camera permission in your device settings.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestPermissionView(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.qr_code_scanner, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'Enable Camera',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To scan container codes, we need access to your device camera.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<BarcodeScannerBloc>().add(
                  const RequestCameraPermission(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 24),
            Text(
              'Scanner Error',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.read<BarcodeScannerBloc>().add(
                  const InitializeScanner(),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surface,
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlashlightIcon(BarcodeScannerState state) {
    final bool isOn =
        state is ScannerScanning && state.isFlashlightOn ||
        state is ScannerReady && state.isFlashlightOn ||
        state is BarcodeScanSuccess && state.isFlashlightOn;

    return isOn ? Icons.flash_on : Icons.flash_off;
  }

  void _showScanResult(BuildContext context, BarcodeScannerState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ScanResultBottomSheet(state: state),
    );
  }

  void _showScanHistory(BuildContext context) {
    context.read<BarcodeScannerBloc>().add(const LoadScanHistory());
    // This would show a scan history dialog/page
    // For now, we'll just show a simple snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scan history feature coming soon!')),
    );
  }

  void _showManualInputDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manual Code Input'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Container Code',
            hintText: 'Enter container ID or barcode',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(context).pop();
                // Navigate to container list with search
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        ContainerListPage(initialSearch: code),
                  ),
                );
              }
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
