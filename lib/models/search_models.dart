
import 'package:flutter/material.dart';

class SearchResult {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String imageUrl;
  final Map<String, dynamic> data;
  final double? price;
  final String? specialization;
  final String? address;
  final List<String>? tags;

  SearchResult({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.imageUrl,
    required this.data,
    this.price,
    this.specialization,
    this.address,
    this.tags,
  });

  factory SearchResult.fromFirestore(
    String id,
    Map<String, dynamic> data,
    String category,
  ) {
    switch (category.toLowerCase()) {
      case 'doctors':
        final connectionTypes = data['connectionTypes'] as List<dynamic>?;
        final connectionTypesList = connectionTypes?.cast<String>() ?? [];

        return SearchResult(
          id: id,
          title: 'Dr. ${data['name'] ?? 'Unknown'}',
          subtitle: data['specialization'] ?? 'General Practice',
          category: 'Doctors',
          imageUrl: 'assets/doctor_avatar.png',
          data: data,
          price: (data['price'] as num?)?.toDouble(),
          specialization: data['specialization'],
          tags: [
            data['name']?.toString().toLowerCase() ?? '',
            data['specialization']?.toString().toLowerCase() ?? '',
            'doctor',
            'medical',
            ...connectionTypesList.map((e) => e.toLowerCase()),
          ],
        );

      case 'hospitals':
        final emergencyServices = data['emergencyServices'] as List<dynamic>?;
        final emergencyServicesList = emergencyServices?.cast<String>() ?? [];

        return SearchResult(
          id: id,
          title: data['name'] ?? 'Unknown Hospital',
          subtitle: data['address'] ?? 'Hospital',
          category: 'Hospitals',
          imageUrl: data['logo'] ?? 'assets/hospitals/default_hospital.png',
          data: data,
          price: (data['price'] as num?)?.toDouble(),
          address: data['address'],
          tags: [
            data['name']?.toString().toLowerCase() ?? '',
            data['address']?.toString().toLowerCase() ?? '',
            'hospital',
            'emergency',
            'medical',
            ...emergencyServicesList.map((e) => e.toLowerCase()),
          ],
        );

      case 'labs':
        return SearchResult(
          id: id,
          title: data['name'] ?? 'Unknown Lab',
          subtitle: data['type'] ?? 'Laboratory',
          category: 'Labs',
          imageUrl: 'assets/Labs and scan centre.png',
          data: data,
          price: (data['price'] as num?)?.toDouble(),
          address: data['location'],
          tags: [
            data['name']?.toString().toLowerCase() ?? '',
            data['type']?.toString().toLowerCase() ?? '',
            data['location']?.toString().toLowerCase() ?? '',
            'lab',
            'laboratory',
            'test',
            'scan',
            'medical analysis',
          ],
        );

      case 'pharmacies':
        return SearchResult(
          id: id,
          title: data['name'] ?? 'Unknown Pharmacy',
          subtitle: data['address'] ?? 'Pharmacy',
          category: 'Pharmacies',
          imageUrl: data['logo'] ?? 'assets/Pharmacy.png',
          data: data,
          address: data['address'],
          tags: [
            data['name']?.toString().toLowerCase() ?? '',
            data['address']?.toString().toLowerCase() ?? '',
            data['city']?.toString().toLowerCase() ?? '',
            'pharmacy',
            'medicine',
            'drug',
            'medication',
          ],
        );

      case 'products':
        return SearchResult(
          id: id,
          title: data['name'] ?? 'Unknown Product',
          subtitle: 'Available at ${data['pharmacyName'] ?? 'Pharmacy'}',
          category: 'Products',
          imageUrl: data['image'] ?? 'assets/products/default_product.png',
          data: data,
          price: (data['price'] as num?)?.toDouble(),
          address: data['pharmacyAddress'],
          tags: [
            data['name']?.toString().toLowerCase() ?? '',
            data['description']?.toString().toLowerCase() ?? '',
            data['pharmacyName']?.toString().toLowerCase() ?? '',
            'product',
            'medicine',
            'health',
            'medication',
            'drug',
          ],
        );

      default:
        return SearchResult(
          id: id,
          title: data['name'] ?? 'Unknown',
          subtitle: data['description'] ?? '',
          category: category,
          imageUrl: 'assets/icon/tameny_icon.png',
          data: data,
          tags: ['general'],
        );
    }
  }

  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return false;

    final queryLower = query.toLowerCase().trim();
    final searchTerms =
        queryLower.split(' ').where((term) => term.isNotEmpty).toList();

    
    final primaryFields = [
      title.toLowerCase(),
      subtitle.toLowerCase(),
      specialization?.toLowerCase() ?? '',
    ];

    
    final secondaryFields = [
      address?.toLowerCase() ?? '',
      category.toLowerCase(),
    ];

    
    if (tags != null) {
      secondaryFields.addAll(tags!.map((tag) => tag.toLowerCase()));
    }

    
    bool allTermsFoundInPrimary = searchTerms.every(
      (term) => primaryFields.any((field) => field.contains(term)),
    );

    bool allTermsFoundInSecondary = searchTerms.every(
      (term) => secondaryFields.any((field) => field.contains(term)),
    );

    final matchFound = allTermsFoundInPrimary || allTermsFoundInSecondary;

    
    if (matchFound) {
      print('🔍 Match found for "$query" in $title');
      print('   Primary fields: ${primaryFields.join(", ")}');
      print('   Search terms: ${searchTerms.join(", ")}');
    }

    return matchFound;
  }
}

class SearchFilter {
  final String category;
  final String? specialization;
  final double? minPrice;
  final double? maxPrice;
  final String? location;
  final List<String>? connectionTypes;
  final List<String>? emergencyServices;

  SearchFilter({
    this.category = 'All',
    this.specialization,
    this.minPrice,
    this.maxPrice,
    this.location,
    this.connectionTypes,
    this.emergencyServices,
  });

  SearchFilter copyWith({
    String? category,
    String? specialization,
    double? minPrice,
    double? maxPrice,
    String? location,
    List<String>? connectionTypes,
    List<String>? emergencyServices,
  }) {
    return SearchFilter(
      category: category ?? this.category,
      specialization: specialization ?? this.specialization,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      location: location ?? this.location,
      connectionTypes: connectionTypes ?? this.connectionTypes,
      emergencyServices: emergencyServices ?? this.emergencyServices,
    );
  }

  bool matches(SearchResult result) {
    
    if (category != 'All' && result.category != category) {
      return false;
    }

    
    if (specialization != null &&
        specialization!.isNotEmpty &&
        result.specialization != specialization) {
      return false;
    }

    
    if (result.price != null) {
      if (minPrice != null && result.price! < minPrice!) return false;
      if (maxPrice != null && result.price! > maxPrice!) return false;
    }

    
    if (location != null &&
        location!.isNotEmpty &&
        result.address != null &&
        !result.address!.toLowerCase().contains(location!.toLowerCase())) {
      return false;
    }

    return true;
  }
}

class SearchHistory {
  final String query;
  final DateTime timestamp;
  final String category;

  SearchHistory({
    required this.query,
    required this.timestamp,
    required this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'category': category,
    };
  }

  factory SearchHistory.fromJson(Map<String, dynamic> json) {
    return SearchHistory(
      query: json['query'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
      category: json['category'],
    );
  }
}

class SearchSuggestion {
  final String text;
  final String category;
  final IconData icon;
  final bool isHistory;

  SearchSuggestion({
    required this.text,
    required this.category,
    required this.icon,
    this.isHistory = false,
  });
}


