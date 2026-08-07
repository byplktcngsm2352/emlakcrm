import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/crm_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../models/property.dart';
import 'property_detail_view.dart';
import 'property_form_view.dart';

class PropertyListView extends StatelessWidget {
  const PropertyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CrmProvider>(
      builder: (context, provider, child) {
        final properties = provider.properties;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Portföyüm & İlanlar', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppTheme.emeraldAccent),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PropertyFormView()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              // Search Bar & Filters
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      onChanged: (val) => provider.setSearchQuery(val),
                      decoration: InputDecoration(
                        hintText: 'Başlık, ilçe veya il ara...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondaryDark),
                        suffixIcon: provider.propertySearchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => provider.setSearchQuery(''),
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Property Type Horizontal Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Tümü',
                            isSelected: provider.selectedPropertyTypeFilter == null,
                            onTap: () => provider.setTypeFilter(null),
                          ),
                          _buildFilterChip(
                            label: 'Daire',
                            isSelected: provider.selectedPropertyTypeFilter == PropertyType.daire,
                            onTap: () => provider.setTypeFilter(PropertyType.daire),
                          ),
                          _buildFilterChip(
                            label: 'Villa',
                            isSelected: provider.selectedPropertyTypeFilter == PropertyType.villa,
                            onTap: () => provider.setTypeFilter(PropertyType.villa),
                          ),
                          _buildFilterChip(
                            label: 'Arsa / Arazi',
                            isSelected: provider.selectedPropertyTypeFilter == PropertyType.arsa,
                            onTap: () => provider.setTypeFilter(PropertyType.arsa),
                          ),
                          _buildFilterChip(
                            label: 'Ticari',
                            isSelected: provider.selectedPropertyTypeFilter == PropertyType.ticari,
                            onTap: () => provider.setTypeFilter(PropertyType.ticari),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Property Cards List
              Expanded(
                child: properties.isEmpty
                    ? const Center(
                        child: Text('Aramanıza uygun portföy bulunamadı.', style: TextStyle(color: AppTheme.textSecondaryDark)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final prop = properties[index];
                          return _buildPropertyCard(context, provider, prop);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({required String label, required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.emeraldPrimary,
        backgroundColor: AppTheme.darkCard,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildPropertyCard(BuildContext context, CrmProvider provider, Property prop) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PropertyDetailView(property: prop)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Thumbnail with badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      prop.imageUrls.isNotEmpty ? prop.imageUrls.first : 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?w=800',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 110,
                        height: 110,
                        color: AppTheme.darkSurface,
                        child: const Icon(Icons.home, color: AppTheme.textMutedDark),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        prop.listingTypeName,
                        style: TextStyle(
                          color: prop.listingType == ListingType.satilik ? AppTheme.emeraldAccent : AppTheme.goldAccent,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Property details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prop.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppTheme.textSecondaryDark),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            prop.locationString,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Specs Badges (m2, rooms, floor)
                    Wrap(
                      spacing: 6,
                      children: [
                        _buildSpecPill(prop.typeName),
                        _buildSpecPill(prop.roomCount),
                        _buildSpecPill('${prop.netM2.toInt()} m²'),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          Formatters.formatCurrency(prop.price, prop.currency),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.goldAccent, fontSize: 15),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: AppTheme.textSecondaryDark, size: 20),
                          color: AppTheme.darkCard,
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => PropertyFormView(property: prop)),
                              );
                            } else if (value == 'delete') {
                              _confirmDelete(context, provider, prop);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Düzenle'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: AppTheme.errorRed, size: 18),
                                  SizedBox(width: 8),
                                  Text('Sil', style: TextStyle(color: AppTheme.errorRed)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecPill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Text(
        text,
        style: const TextStyle(color: AppTheme.textSecondaryDark, fontSize: 10),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CrmProvider provider, Property property) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkCard,
        title: const Text('Portföyü Sil'),
        content: Text('"${property.title}" portföyünü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () {
              provider.deleteProperty(property.id);
              Navigator.pop(context);
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
