import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/container_tracking_bloc.dart';
import '../blocs/container_tracking_event.dart';

/// Search bar widget for filtering containers
class ContainerSearchBar extends StatefulWidget {
  const ContainerSearchBar({super.key});

  @override
  State<ContainerSearchBar> createState() => _ContainerSearchBarState();
}

class _ContainerSearchBarState extends State<ContainerSearchBar> {
  final TextEditingController _controller = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Search containers...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _isSearching
            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
      ),
      onChanged: _onSearchChanged,
      onSubmitted: _onSearchSubmitted,
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      context.read<ContainerTrackingBloc>().add(const ClearSearch());
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      context.read<ContainerTrackingBloc>().add(SearchContainers(query.trim()));
    }
  }

  void _clearSearch() {
    _controller.clear();
    setState(() {
      _isSearching = false;
    });
    context.read<ContainerTrackingBloc>().add(const ClearSearch());
  }
}
