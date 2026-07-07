import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../providers/resident_directory_provider.dart';

class ResidentDirectoryScreen extends StatefulWidget {
  const ResidentDirectoryScreen({super.key});

  @override
  State<ResidentDirectoryScreen> createState() => _ResidentDirectoryScreenState();
}

class _ResidentDirectoryScreenState extends State<ResidentDirectoryScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ResidentDirectoryProvider>().loadFirstPage();
    });

    // Infinite scroll — load next page when near the bottom.
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        context.read<ResidentDirectoryProvider>().loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resident Directory')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, apartment, or block',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      context.read<ResidentDirectoryProvider>().onSearchChanged('');
                      setState(() {});
                    },
                  )
                      : null,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) {
                  context.read<ResidentDirectoryProvider>().onSearchChanged(value);
                  setState(() {}); // refresh clear-icon visibility
                },
              ),
            ),
            Expanded(
              child: Consumer<ResidentDirectoryProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.residents.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (provider.errorMessage != null && provider.residents.isEmpty) {
                    return Center(child: Text(provider.errorMessage!));
                  }

                  if (provider.residents.isEmpty) {
                    return Center(
                      child: Text(
                        provider.isSearching ? 'No residents match your search.' : 'No residents found.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: provider.loadFirstPage,
                    child: ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: provider.residents.length + (provider.isLoadingMore ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index >= provider.residents.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final resident = provider.residents[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          child: ListTile(
                            onTap: () => context.push(
                              RouteNames.residentDetail,
                              extra: resident.id,
                            ),
                            leading: CircleAvatar(
                              backgroundImage: resident.profilePhotoUrl != null
                                  ? NetworkImage(resident.profilePhotoUrl!)
                                  : null,
                              child: resident.profilePhotoUrl == null
                                  ? Text(resident.fullName.isNotEmpty
                                  ? resident.fullName[0].toUpperCase()
                                  : '?')
                                  : null,
                            ),
                            title: Text(resident.fullName),
                            subtitle: Text('${resident.block} - ${resident.apartmentNumber}, Floor ${resident.floor}'),
                            trailing: const Icon(Icons.chevron_right),
                          ),
                        );
                      },
                    ),
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