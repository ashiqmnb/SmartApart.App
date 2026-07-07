import 'package:flutter/material.dart';
import '../../../residents/data/models/resident_models.dart';
import '../../../residents/data/repositories/resident_repository.dart';

/// Full-screen search UI for Security to find and select a resident
/// when registering a visitor. Wraps ResidentRepository.searchResidentsPublic().
class ResidentSearchDelegate extends SearchDelegate<ResidentPublicModel?> {
  final ResidentRepository _repository = ResidentRepository();

  ResidentSearchDelegate() : super(searchFieldLabel: 'Search by name, apartment, or block');

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.trim().length < 2) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Type at least 2 characters to search.'),
        ),
      );
    }

    return FutureBuilder<List<ResidentPublicModel>>(
      // Rebuilds on every keystroke via showResults/showSuggestions
      // triggering a fresh build — Dio's own request isn't debounced
      // here, so keep queries short/deliberate (matches Admin
      // Directory's 300ms debounce pattern conceptually, applied
      // at the call site instead since SearchDelegate doesn't expose
      // a listenable text stream directly).
      future: _repository.searchResidentsPublic(query.trim()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Search failed: ${snapshot.error}'));
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) {
          return const Center(child: Text('No residents match your search.'));
        }

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final resident = results[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: resident.profilePhotoUrl != null
                    ? NetworkImage(resident.profilePhotoUrl!)
                    : null,
                child: resident.profilePhotoUrl == null
                    ? Text(resident.fullName.isNotEmpty ? resident.fullName[0].toUpperCase() : '?')
                    : null,
              ),
              title: Text(resident.fullName),
              subtitle: Text('${resident.block} - ${resident.apartmentNumber}, Floor ${resident.floor}'),
              onTap: () => close(context, resident),
            );
          },
        );
      },
    );
  }
}