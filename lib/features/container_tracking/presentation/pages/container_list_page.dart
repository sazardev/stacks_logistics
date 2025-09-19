import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../domain/entities/container.dart' as domain;
import '../blocs/container_tracking_bloc.dart';
import '../blocs/container_tracking_event.dart';
import '../blocs/container_tracking_state.dart';
import '../widgets/container_card.dart';
import '../widgets/container_search_bar.dart';
import '../widgets/container_filter_chips.dart';
import '../../../map_tracking/presentation/pages/map_tracking_page.dart';
import '../../../map_tracking/presentation/blocs/map_tracking_bloc.dart';
import '../../../barcode_scanner/presentation/pages/barcode_scanner_page.dart';

/// Page displaying a list of containers with search and filter capabilities
class ContainerListPage extends StatelessWidget {
  const ContainerListPage({super.key, this.initialSearch});

  final String? initialSearch;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final bloc = getIt<ContainerTrackingBloc>();
        if (initialSearch != null && initialSearch!.isNotEmpty) {
          bloc.add(SearchContainers(initialSearch!));
        } else {
          bloc.add(const LoadAllContainers());
        }
        return bloc;
      },
      child: ContainerListView(initialSearch: initialSearch),
    );
  }
}

class ContainerListView extends StatelessWidget {
  const ContainerListView({super.key, this.initialSearch});

  final String? initialSearch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Containers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<MapTrackingBloc>(),
                    child: const MapTrackingPage(),
                  ),
                ),
              );
            },
            tooltip: 'Map View',
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BarcodeScannerPage(),
                ),
              );
            },
            tooltip: 'Scan Code',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ContainerTrackingBloc>().add(
                const RefreshContainers(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to create container page
              _showCreateContainerDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ContainerSearchBar(),
          ),

          // Filter chips
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: ContainerFilterChips(),
          ),

          // Container list
          Expanded(
            child: BlocBuilder<ContainerTrackingBloc, ContainerTrackingState>(
              builder: (context, state) {
                if (state is ContainerTrackingLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ContainerTrackingError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ContainerTrackingBloc>().add(
                              const RefreshContainers(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ContainerTrackingLoaded) {
                  final containers = state.containers;

                  if (containers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No containers found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding your first container',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _showCreateContainerDialog(context);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Container'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<ContainerTrackingBloc>().add(
                        const RefreshContainers(),
                      );
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: containers.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ContainerCard(
                            container: containers[index],
                            onTap: () {
                              // TODO: Navigate to container details page
                              _showContainerDetails(context, containers[index]);
                            },
                          ),
                        );
                      },
                    ),
                  );
                } else if (state is ContainerSearchResults) {
                  final results = state.results;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Search results for "${state.query}" (${results.length} found)',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<ContainerTrackingBloc>().add(
                                  const ClearSearch(),
                                );
                              },
                              child: const Text('Clear'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: results.isEmpty
                            ? const Center(
                                child: Text('No containers match your search'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: ContainerCard(
                                      container: results[index],
                                      onTap: () {
                                        _showContainerDetails(
                                          context,
                                          results[index],
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }

                return const Center(child: Text('Loading containers...'));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateContainerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Container'),
        content: const Text(
          'Container creation form will be implemented here.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement container creation
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showContainerDetails(BuildContext context, domain.Container container) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Container ${container.containerNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${container.status.name}'),
            Text('Priority: ${container.priority.name}'),
            Text('Contents: ${container.contents}'),
            Text('Weight: ${container.weight} kg'),
            Text('Location: ${container.currentLocation.name}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
