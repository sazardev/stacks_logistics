import 'package:flutter/material.dart';
import '../../domain/entities/container.dart' as domain;

/// Card widget to display container information
class ContainerCard extends StatelessWidget {
  const ContainerCard({super.key, required this.container, this.onTap});

  final domain.Container container;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      container.containerNumber,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                container.contents,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      container.currentLocation.name,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  _buildPriorityChip(context),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.scale_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${container.weight} kg',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  if (container.estimatedArrival != null)
                    Text(
                      'ETA: ${_formatDate(container.estimatedArrival!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color chipColor;
    IconData iconData;

    switch (container.status) {
      case domain.ContainerStatus.loading:
        chipColor = Colors.orange;
        iconData = Icons.inventory_2;
        break;
      case domain.ContainerStatus.inTransit:
        chipColor = Colors.blue;
        iconData = Icons.local_shipping;
        break;
      case domain.ContainerStatus.delivered:
        chipColor = Colors.green;
        iconData = Icons.check_circle;
        break;
      case domain.ContainerStatus.delayed:
        chipColor = Colors.amber;
        iconData = Icons.warning;
        break;
      case domain.ContainerStatus.damaged:
        chipColor = Colors.red;
        iconData = Icons.error;
        break;
      case domain.ContainerStatus.lost:
        chipColor = Colors.red[800]!;
        iconData = Icons.help_outline;
        break;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            container.status.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildPriorityChip(BuildContext context) {
    Color chipColor;

    switch (container.priority) {
      case domain.Priority.low:
        chipColor = Colors.grey;
        break;
      case domain.Priority.medium:
        chipColor = Colors.orange;
        break;
      case domain.Priority.high:
        chipColor = Colors.red;
        break;
      case domain.Priority.critical:
        chipColor = Colors.red[800]!;
        break;
    }

    return Chip(
      label: Text(
        container.priority.name.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
