import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/container.dart' as domain;
import '../blocs/container_tracking_bloc.dart';
import '../blocs/container_tracking_event.dart';

/// Filter chips widget for filtering containers by status and priority
class ContainerFilterChips extends StatelessWidget {
  const ContainerFilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Status filters
          ...domain.ContainerStatus.values.map(
            (status) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(status.name.toUpperCase()),
                onSelected: (selected) {
                  if (selected) {
                    context.read<ContainerTrackingBloc>().add(
                      FilterContainersByStatus(status),
                    );
                  } else {
                    context.read<ContainerTrackingBloc>().add(
                      const ClearFilters(),
                    );
                  }
                },
              ),
            ),
          ),

          // Divider
          Container(
            height: 32,
            width: 1,
            color: Theme.of(context).dividerColor,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),

          // Priority filters
          ...domain.Priority.values.map(
            (priority) => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPriorityIcon(priority),
                      size: 16,
                      color: _getPriorityColor(priority),
                    ),
                    const SizedBox(width: 4),
                    Text(priority.name.toUpperCase()),
                  ],
                ),
                onSelected: (selected) {
                  if (selected) {
                    context.read<ContainerTrackingBloc>().add(
                      FilterContainersByPriority(priority),
                    );
                  } else {
                    context.read<ContainerTrackingBloc>().add(
                      const ClearFilters(),
                    );
                  }
                },
              ),
            ),
          ),

          // Clear all filters
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ActionChip(
              label: const Text('Clear All'),
              onPressed: () {
                context.read<ContainerTrackingBloc>().add(const ClearFilters());
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getPriorityIcon(domain.Priority priority) {
    switch (priority) {
      case domain.Priority.low:
        return Icons.low_priority;
      case domain.Priority.medium:
        return Icons.flag_outlined;
      case domain.Priority.high:
        return Icons.priority_high;
      case domain.Priority.critical:
        return Icons.warning;
    }
  }

  Color _getPriorityColor(domain.Priority priority) {
    switch (priority) {
      case domain.Priority.low:
        return Colors.grey;
      case domain.Priority.medium:
        return Colors.orange;
      case domain.Priority.high:
        return Colors.red;
      case domain.Priority.critical:
        return Colors.red[800]!;
    }
  }
}
