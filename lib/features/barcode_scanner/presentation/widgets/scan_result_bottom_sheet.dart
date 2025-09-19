import 'package:flutter/material.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/date_time_utils.dart';
import '../blocs/barcode_scanner_state.dart';
import '../../../container_tracking/presentation/widgets/container_card.dart';

/// Bottom sheet widget for displaying scan results
class ScanResultBottomSheet extends StatelessWidget {
  const ScanResultBottomSheet({super.key, required this.state});

  final BarcodeScannerState state;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildScanResult(),
                    const SizedBox(height: 20),
                    _buildContainerResult(),
                    const SizedBox(height: 20),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final IconData icon;
    final String title;
    final Color color;

    if (state is ContainerFoundByBarcode) {
      icon = Icons.check_circle;
      title = 'Container Found';
      color = AppColors.success;
    } else if (state is ContainerNotFoundByBarcode) {
      icon = Icons.search_off;
      title = 'Container Not Found';
      color = AppColors.warning;
    } else {
      icon = Icons.qr_code;
      title = 'Scan Result';
      color = AppColors.primary;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.headlineMedium.copyWith(color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildScanResult() {
    final scanResult = _getScanResult();
    if (scanResult == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCodeIcon(scanResult.type),
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Scanned ${scanResult.type.displayName}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              scanResult.code,
              style: AppTextStyles.bodyLarge.copyWith(
                fontFamily: 'monospace',
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scanned ${DateTimeUtils.formatDisplayDateTime(scanResult.timestamp)}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainerResult() {
    if (state is ContainerFoundByBarcode) {
      final containerState = state as ContainerFoundByBarcode;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Container Details', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          ContainerCard(
            container: containerState.container,
            onTap: () {
              // Navigate to container details
            },
          ),
        ],
      );
    } else if (state is ContainerNotFoundByBarcode) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.warning.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Text(
                  'No container found',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'The scanned code doesn\'t match any container in your system. You can try scanning again or search manually.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary action button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (state is ContainerFoundByBarcode) {
                // Navigate to container details
              } else {
                // Navigate to container list or search
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              state is ContainerFoundByBarcode
                  ? 'View Container'
                  : 'Search Containers',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.surface,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Secondary action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Continue scanning
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.secondary,
                  side: const BorderSide(color: AppColors.secondary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Scan Again'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  dynamic _getScanResult() {
    if (state is ContainerFoundByBarcode) {
      return (state as ContainerFoundByBarcode).result;
    } else if (state is ContainerNotFoundByBarcode) {
      return (state as ContainerNotFoundByBarcode).result;
    } else if (state is BarcodeScanSuccess) {
      return (state as BarcodeScanSuccess).result;
    }
    return null;
  }

  IconData _getCodeIcon(dynamic type) {
    // This should match the BarcodeType enum
    final typeName = type.toString().split('.').last.toLowerCase();

    switch (typeName) {
      case 'qrcode':
        return Icons.qr_code;
      case 'barcode':
        return Icons.barcode_reader;
      default:
        return Icons.code;
    }
  }
}
