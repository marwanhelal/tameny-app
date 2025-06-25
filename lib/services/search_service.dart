

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/search_models.dart';

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
  final Map<String, List<SearchResult>> _searchCache = {};
  List<SearchHistory> _searchHistory = [];
  final List<String> _popularSearches = [
    'Cardiology',
    'Emergency',
    'Dentist',
    'Pediatrician',
    'Dermatology',
    'Online',
    'Need a visit',
  ];

  
  Future<List<SearchSuggestion>> getSearchSuggestions(String query) async {
    List<SearchSuggestion> suggestions = [];

    if (query.isEmpty) {
      
      suggestions.addAll(
        _searchHistory
            .take(3)
            .map(
              (history) => SearchSuggestion(
                text: history.query,
                category: history.category,
                icon: Icons.history,
                isHistory: true,
              ),
            ),
      );

      suggestions.addAll(
        _popularSearches
            .take(5)
            .map(
              (search) => SearchSuggestion(
                text: search,
                category: 'Popular',
                icon: Icons.trending_up,
              ),
            ),
      );

      return suggestions;
    }

    
    final categories = ['Doctors', 'Hospitals', 'Labs', 'Pharmacies'];

    for (String category in categories) {
      final categoryResults = await _getQuickSuggestions(query, category);
      suggestions.addAll(categoryResults.take(2));
    }

    
    if (query.length > 1) {
      final specializations = await _getSpecializationSuggestions(query);
      suggestions.addAll(specializations.take(3));
    }

    return suggestions.take(8).toList();
  }

  
  Future<List<SearchSuggestion>> _getQuickSuggestions(
    String query,
    String category,
  ) async {
    List<SearchSuggestion> suggestions = [];

    try {
      Query collection;
      String field;
      IconData icon;

      switch (category.toLowerCase()) {
        case 'doctors':
          collection = _firestore.collection('doctors');
          field = 'name';
          icon = Icons.local_hospital;
          break;
        case 'hospitals':
          collection = _firestore.collection('hospitals');
          field = 'name';
          icon = Icons.local_hospital;
          break;
        case 'labs':
          collection = _firestore.collection('labs_centres');
          field = 'name';
          icon = Icons.science;
          break;
        case 'pharmacies':
          collection = _firestore.collection('pharmacies');
          field = 'name';
          icon = Icons.local_pharmacy;
          break;
        default:
          return suggestions;
      }

      final snapshot =
          await collection
              .where(field, isGreaterThanOrEqualTo: query)
              .where(field, isLessThan: '$query\uf8ff')
              .limit(3)
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        suggestions.add(
          SearchSuggestion(
            text: data[field] ?? '',
            category: category,
            icon: icon,
          ),
        );
      }
    } catch (e) {
      print('Error getting suggestions for $category: $e');
    }

    return suggestions;
  }

  
  Future<List<SearchSuggestion>> _getSpecializationSuggestions(
    String query,
  ) async {
    List<SearchSuggestion> suggestions = [];

    final commonSpecializations = [
      'Cardiology',
      'Dermatology',
      'Neurology',
      'General Surgery',
      'Pediatrics',
      'Orthopedics',
      'Gynecology',
      'Psychiatry',
      'Oncology',
      'Radiology',
      'Emergency Medicine',
      'Internal Medicine',
    ];

    for (String specialization in commonSpecializations) {
      if (specialization.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(
          SearchSuggestion(
            text: specialization,
            category: 'Specialization',
            icon: Icons.medical_services,
          ),
        );
      }
    }

    return suggestions;
  }

  
  Future<List<SearchResult>> search(String query, SearchFilter filter) async {
    if (query.trim().isEmpty) return [];

    
    final cacheKey = '${query}_${filter.category}';
    if (_searchCache.containsKey(cacheKey)) {
      return _applyFilters(_searchCache[cacheKey]!, filter);
    }

    List<SearchResult> allResults = [];

    
    _addToSearchHistory(query, filter.category);

    
    final isConnectionType = _isConnectionTypeQuery(query);
    final isEmergencyService = _isEmergencyServiceQuery(query);
    final isSpecialization = _isSpecializationQuery(query);

    print('🔍 Query: "$query"');
    print('📋 Category: ${filter.category}');
    print('🔗 Is Connection Type: $isConnectionType');
    print('🚨 Is Emergency Service: $isEmergencyService');
    print('👨‍⚕️ Is Specialization: $isSpecialization');

    
    switch (filter.category) {
      case 'All':
        allResults = await _searchAllCategories(
          query,
          isConnectionType,
          isEmergencyService,
          isSpecialization,
        );
        break;

      case 'Doctors':
        allResults = await _searchDoctorsOnly(
          query,
          isConnectionType,
          isSpecialization,
        );
        break;

      case 'Hospitals':
        allResults = await _searchHospitalsOnly(query, isEmergencyService);
        break;

      case 'Labs':
        allResults = await _searchLabs(query);
        break;

      case 'Pharmacies':
        allResults = await _searchPharmacies(query);
        break;

      case 'Products':
        allResults = await _searchProducts(query);
        break;
    }

    
    _searchCache[cacheKey] = allResults;

    print('✅ Found ${allResults.length} results');
    return _applyFilters(allResults, filter);
  }

  
  Future<List<SearchResult>> _searchAllCategories(
    String query,
    bool isConnectionType,
    bool isEmergencyService,
    bool isSpecialization,
  ) async {
    List<SearchResult> results = [];

    
    if (isConnectionType) {
      
      results = await _searchDoctorsByConnectionType(query);
    }
    
    else if (isEmergencyService && !isSpecialization) {
      
      results = await _searchHospitalsByEmergencyService(query);
    }
    
    else if (isSpecialization && !isEmergencyService) {
      
      results = await _searchDoctorsBySpecialization(query);
    }
    
    else if (isSpecialization && isEmergencyService) {
      
      final doctorResults = await _searchDoctorsBySpecialization(query);
      final hospitalResults = await _searchHospitalsByEmergencyService(query);
      results = [...doctorResults, ...hospitalResults];
    }
    
    else {
      
      final futures = [
        _searchDoctorsGeneral(query),
        _searchHospitalsGeneral(query),
        _searchLabs(query),
        _searchPharmacies(query),
        _searchProducts(query),
      ];

      final resultsList = await Future.wait(futures);
      for (var categoryResults in resultsList) {
        results.addAll(categoryResults);
      }
    }

    return results;
  }

  
  Future<List<SearchResult>> _searchDoctorsOnly(
    String query,
    bool isConnectionType,
    bool isSpecialization,
  ) async {
    
    if (isConnectionType) {
      return await _searchDoctorsByConnectionType(query);
    }
    
    else if (isSpecialization) {
      return await _searchDoctorsBySpecialization(query);
    }
    
    else {
      return await _searchDoctorsGeneral(query);
    }
  }

  
  Future<List<SearchResult>> _searchHospitalsOnly(
    String query,
    bool isEmergencyService,
  ) async {
    
    if (isEmergencyService) {
      return await _searchHospitalsByEmergencyService(query);
    }
    
    else {
      return await _searchHospitalsGeneral(query);
    }
  }

  
  Future<List<SearchResult>> _searchDoctorsByConnectionType(
    String query,
  ) async {
    List<SearchResult> results = [];

    try {
      var snapshot =
          await _firestore
              .collection('doctors')
              .where('approvalStatus', isEqualTo: 'approved')
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final connectionTypes = data['connectionTypes'] as List<dynamic>?;
        final connectionTypesList = connectionTypes?.cast<String>() ?? [];

        
        bool hasMatchingConnectionType = connectionTypesList.any(
          (type) => type.toLowerCase().trim() == query.toLowerCase().trim(),
        );

        if (hasMatchingConnectionType) {
          final result = SearchResult.fromFirestore(doc.id, data, 'Doctors');
          results.add(result);
          print('✅ Doctor with connectionType "$query": ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching doctors by connection type: $e');
    }

    return results;
  }

  
  Future<List<SearchResult>> _searchDoctorsBySpecialization(
    String query,
  ) async {
    List<SearchResult> results = [];

    try {
      var snapshot =
          await _firestore
              .collection('doctors')
              .where('approvalStatus', isEqualTo: 'approved')
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final specialization =
            data['specialization']?.toString().toLowerCase() ?? '';

        
        if (specialization == query.toLowerCase().trim()) {
          final result = SearchResult.fromFirestore(doc.id, data, 'Doctors');
          results.add(result);
          print('✅ Doctor with specialization "$query": ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching doctors by specialization: $e');
    }

    return results;
  }

  
  Future<List<SearchResult>> _searchDoctorsGeneral(String query) async {
    List<SearchResult> exactMatches = [];
    List<SearchResult> partialMatches = [];

    try {
      var snapshot =
          await _firestore
              .collection('doctors')
              .where('approvalStatus', isEqualTo: 'approved')
              .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final result = SearchResult.fromFirestore(doc.id, data, 'Doctors');
        final doctorName = (data['name'] ?? '').toString().toLowerCase();
        final queryLower = query.toLowerCase().trim();

        
        if (doctorName == queryLower ||
            'dr. $doctorName' == queryLower ||
            'dr $doctorName' == queryLower) {
          exactMatches.add(result);
          print('🎯 Doctor exact match: ${result.title}');
        }
        
        else if (doctorName.contains(queryLower) ||
            result.matchesQuery(query)) {
          partialMatches.add(result);
          print('✅ Doctor partial match: ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching doctors general: $e');
    }

    
    return [...exactMatches, ...partialMatches];
  }

  
  Future<List<SearchResult>> _searchHospitalsByEmergencyService(
    String query,
  ) async {
    List<SearchResult> results = [];

    try {
      var snapshot = await _firestore.collection('hospitals').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final emergencyServices = data['emergencyServices'] as List<dynamic>?;
        final emergencyServicesList = emergencyServices?.cast<String>() ?? [];

        
        bool hasMatchingService = emergencyServicesList.any(
          (service) =>
              service.toLowerCase().trim() == query.toLowerCase().trim(),
        );

        if (hasMatchingService) {
          final result = SearchResult.fromFirestore(doc.id, data, 'Hospitals');
          results.add(result);
          print('✅ Hospital with emergencyService "$query": ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching hospitals by emergency service: $e');
    }

    return results;
  }

  
  Future<List<SearchResult>> _searchHospitalsGeneral(String query) async {
    List<SearchResult> exactMatches = [];
    List<SearchResult> partialMatches = [];

    try {
      var snapshot = await _firestore.collection('hospitals').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final result = SearchResult.fromFirestore(doc.id, data, 'Hospitals');
        final hospitalName = (data['name'] ?? '').toString().toLowerCase();
        final queryLower = query.toLowerCase().trim();

        
        if (hospitalName == queryLower) {
          exactMatches.add(result);
          print('🎯 Hospital exact match: ${result.title}');
        }
        
        else if (hospitalName.contains(queryLower) ||
            result.matchesQuery(query)) {
          partialMatches.add(result);
          print('✅ Hospital partial match: ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching hospitals general: $e');
    }

    
    return [...exactMatches, ...partialMatches];
  }

  
  Future<List<SearchResult>> _searchLabs(String query) async {
    List<SearchResult> exactMatches = [];
    List<SearchResult> partialMatches = [];

    try {
      var snapshot = await _firestore.collection('labs_centres').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final result = SearchResult.fromFirestore(doc.id, data, 'Labs');
        final labName = (data['name'] ?? '').toString().toLowerCase();
        final labType = (data['type'] ?? '').toString().toLowerCase();
        final location = (data['location'] ?? '').toString().toLowerCase();
        final queryLower = query.toLowerCase().trim();

        
        if (labName == queryLower || labType == queryLower) {
          exactMatches.add(result);
          print('🎯 Lab exact match: ${result.title}');
        }
        
        else if (labName.contains(queryLower) ||
            labType.contains(queryLower) ||
            location.contains(queryLower) ||
            result.matchesQuery(query)) {
          partialMatches.add(result);
          print('✅ Lab partial match: ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching labs: $e');
    }

    
    return [...exactMatches, ...partialMatches];
  }

  
  Future<List<SearchResult>> _searchPharmacies(String query) async {
    List<SearchResult> exactMatches = [];
    List<SearchResult> partialMatches = [];

    try {
      var snapshot = await _firestore.collection('pharmacies').get();

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final result = SearchResult.fromFirestore(doc.id, data, 'Pharmacies');
        final pharmacyName = (data['name'] ?? '').toString().toLowerCase();
        final address = (data['address'] ?? '').toString().toLowerCase();
        final city = (data['city'] ?? '').toString().toLowerCase();
        final queryLower = query.toLowerCase().trim();

        
        if (pharmacyName == queryLower) {
          exactMatches.add(result);
          print('🎯 Pharmacy exact match: ${result.title}');
        }
        
        else if (pharmacyName.contains(queryLower) ||
            address.contains(queryLower) ||
            city.contains(queryLower) ||
            result.matchesQuery(query)) {
          partialMatches.add(result);
          print('✅ Pharmacy partial match: ${result.title}');
        }
      }
    } catch (e) {
      print('Error searching pharmacies: $e');
    }

    
    return [...exactMatches, ...partialMatches];
  }

  
  Future<List<SearchResult>> _searchProducts(String query) async {
    List<SearchResult> exactMatches = [];
    List<SearchResult> partialMatches = [];

    try {
      
      var pharmaciesSnapshot = await _firestore.collection('pharmacies').get();

      for (var pharmacyDoc in pharmaciesSnapshot.docs) {
        final pharmacyData = pharmacyDoc.data();
        final pharmacyName = pharmacyData['name'] ?? 'Unknown Pharmacy';

        
        var productsSnapshot =
            await _firestore
                .collection('pharmacies')
                .doc(pharmacyDoc.id)
                .collection('products')
                .get();

        for (var productDoc in productsSnapshot.docs) {
          final productData = productDoc.data();

          
          final enhancedProductData = {
            ...productData,
            'pharmacyId': pharmacyDoc.id,
            'pharmacyName': pharmacyName,
            'pharmacyAddress': pharmacyData['address'] ?? '',
            'pharmacyCity': pharmacyData['city'] ?? '',
          };

          final result = SearchResult.fromFirestore(
            productDoc.id,
            enhancedProductData,
            'Products',
          );

          final productName =
              (productData['name'] ?? '').toString().toLowerCase();
          final productDescription =
              (productData['description'] ?? '').toString().toLowerCase();
          final queryLower = query.toLowerCase().trim();

          
          if (productName == queryLower) {
            exactMatches.add(result);
            print('🎯 Product exact match: ${result.title} at $pharmacyName');
          }
          
          else if (productName.contains(queryLower) ||
              productDescription.contains(queryLower) ||
              result.matchesQuery(query)) {
            partialMatches.add(result);
            print('✅ Product partial match: ${result.title} at $pharmacyName');
          }
        }
      }
    } catch (e) {
      print('Error searching products: $e');
    }

    
    return [...exactMatches, ...partialMatches];
  }

  
  bool _isConnectionTypeQuery(String query) {
    final connectionTypes = [
      'need a visit',
      'online',
      'audio call',
      'video call',
      'recorded video',
    ];
    return connectionTypes.contains(query.toLowerCase().trim());
  }

  bool _isEmergencyServiceQuery(String query) {
    final emergencyServices = [
      'dermatology',
      'neurology',
      'general surgery',
      'cardiology',
      'emergency',
      'orthopedics',
      'pediatrics',
      'gynecology',
      'psychiatry',
      'oncology',
      'radiology',
      'urology',
      'internal medicine',
    ];
    return emergencyServices.contains(query.toLowerCase().trim());
  }

  bool _isSpecializationQuery(String query) {
    final specializations = [
      'cardiology',
      'dermatology',
      'neurology',
      'general surgery',
      'emergency medicine',
      'orthopedics',
      'pediatrics',
      'gynecology',
      'psychiatry',
      'oncology',
      'radiology',
      'urology',
      'internal medicine',
    ];
    return specializations.contains(query.toLowerCase().trim());
  }

  
  List<SearchResult> _applyFilters(
    List<SearchResult> results,
    SearchFilter filter,
  ) {
    return results.where((result) => filter.matches(result)).toList();
  }

  
  void _addToSearchHistory(String query, String category) {
    _searchHistory.removeWhere((history) => history.query == query);
    _searchHistory.insert(
      0,
      SearchHistory(
        query: query,
        timestamp: DateTime.now(),
        category: category,
      ),
    );

    
    if (_searchHistory.length > 20) {
      _searchHistory = _searchHistory.take(20).toList();
    }
  }

  
  List<SearchHistory> getSearchHistory() {
    return _searchHistory;
  }

  
  void clearSearchHistory() {
    _searchHistory.clear();
  }

  
  List<String> getPopularSearches() {
    return _popularSearches;
  }

  
  void clearCache() {
    _searchCache.clear();
  }

  
  Future<List<String>> getAllSpecializations() async {
    return [
      'Cardiology',
      'Dermatology',
      'Neurology',
      'General Surgery',
      'Emergency Medicine',
      'Orthopedics',
      'Pediatrics',
      'Gynecology',
      'Psychiatry',
      'Oncology',
      'Radiology',
      'Urology',
      'Internal Medicine',
    ];
  }

  
  Future<List<String>> getAllEmergencyServices() async {
    return [
      'Dermatology',
      'Neurology',
      'General Surgery',
      'Cardiology',
      'Emergency',
      'Orthopedics',
      'Pediatrics',
      'Gynecology',
      'Psychiatry',
      'Oncology',
      'Radiology',
      'Urology',
      'Internal Medicine',
    ];
  }
}


