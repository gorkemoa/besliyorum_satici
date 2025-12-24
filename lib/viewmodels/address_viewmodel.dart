import 'package:flutter/material.dart';
import '../models/address/address_model.dart';
import '../models/address/city_model.dart';
import '../models/address/district_model.dart';
import '../models/address/neighborhood_model.dart';
import '../models/address/address_type_model.dart';
import '../models/address/add_address_request.dart';
import '../models/address/update_address_request.dart';
import '../services/address_service.dart';

enum AddressLoadState { initial, loading, loaded, error }

class AddressViewModel extends ChangeNotifier {
  final AddressService _addressService = AddressService();

  // Address list state
  List<AddressModel> _addresses = [];
  AddressLoadState _loadState = AddressLoadState.initial;
  String? _errorMessage;

  // Location data state
  List<CityModel> _cities = [];
  List<DistrictModel> _districts = [];
  List<NeighborhoodModel> _neighborhoods = [];
  List<AddressTypeModel> _addressTypes = [];

  // Loading states for location data
  bool _isCitiesLoading = false;
  bool _isDistrictsLoading = false;
  bool _isNeighborhoodsLoading = false;
  bool _isAddressTypesLoading = false;
  bool _isSaving = false;

  // Selected values for form
  CityModel? _selectedCity;
  DistrictModel? _selectedDistrict;
  NeighborhoodModel? _selectedNeighborhood;
  AddressTypeModel? _selectedAddressType;

  // Getters for address list
  List<AddressModel> get addresses => _addresses;
  AddressLoadState get loadState => _loadState;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _loadState == AddressLoadState.loading;
  bool get hasError => _loadState == AddressLoadState.error;
  bool get hasData =>
      _loadState == AddressLoadState.loaded && _addresses.isNotEmpty;

  // Getters for location data
  List<CityModel> get cities => _cities;
  List<DistrictModel> get districts => _districts;
  List<NeighborhoodModel> get neighborhoods => _neighborhoods;
  List<AddressTypeModel> get addressTypes => _addressTypes;

  // Getters for loading states
  bool get isCitiesLoading => _isCitiesLoading;
  bool get isDistrictsLoading => _isDistrictsLoading;
  bool get isNeighborhoodsLoading => _isNeighborhoodsLoading;
  bool get isAddressTypesLoading => _isAddressTypesLoading;
  bool get isSaving => _isSaving;

  // Getters for selected values
  CityModel? get selectedCity => _selectedCity;
  DistrictModel? get selectedDistrict => _selectedDistrict;
  NeighborhoodModel? get selectedNeighborhood => _selectedNeighborhood;
  AddressTypeModel? get selectedAddressType => _selectedAddressType;

  /// Fetches addresses for the given user token
  Future<void> fetchAddresses(String userToken) async {
    _loadState = AddressLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _addressService.getAddresses(userToken);

      if (response.success && !response.error) {
        _addresses = response.data;
        _loadState = AddressLoadState.loaded;
      } else {
        _errorMessage = 'Adresler yüklenemedi';
        _loadState = AddressLoadState.error;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _loadState = AddressLoadState.error;
    }

    notifyListeners();
  }

  /// Gets addresses filtered by type
  List<AddressModel> getAddressesByType(String type) {
    return _addresses.where((address) => address.addressType == type).toList();
  }

  /// Gets the default address for a specific type
  AddressModel? getDefaultAddress(String type) {
    try {
      return _addresses.firstWhere(
        (address) => address.addressType == type && address.isDefault,
      );
    } catch (e) {
      return null;
    }
  }

  /// Clears all addresses and resets state
  void clearAddresses() {
    _addresses = [];
    _loadState = AddressLoadState.initial;
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetches address types from API
  Future<void> fetchAddressTypes() async {
    _isAddressTypesLoading = true;
    notifyListeners();

    try {
      _addressTypes = await _addressService.getAddressTypes();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isAddressTypesLoading = false;
    notifyListeners();
  }

  /// Fetches cities from API
  Future<void> fetchCities() async {
    _isCitiesLoading = true;
    notifyListeners();

    try {
      _cities = await _addressService.getCities();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isCitiesLoading = false;
    notifyListeners();
  }

  /// Fetches districts for a given city
  Future<void> fetchDistricts(int cityNO) async {
    _isDistrictsLoading = true;
    _districts = [];
    _neighborhoods = [];
    _selectedDistrict = null;
    _selectedNeighborhood = null;
    notifyListeners();

    try {
      _districts = await _addressService.getDistricts(cityNO);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isDistrictsLoading = false;
    notifyListeners();
  }

  /// Fetches neighborhoods for a given district
  Future<void> fetchNeighborhoods(int districtNO) async {
    _isNeighborhoodsLoading = true;
    _neighborhoods = [];
    _selectedNeighborhood = null;
    notifyListeners();

    try {
      _neighborhoods = await _addressService.getNeighborhoods(districtNO);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    }

    _isNeighborhoodsLoading = false;
    notifyListeners();
  }

  /// Sets selected city and fetches districts
  void setSelectedCity(CityModel? city) {
    _selectedCity = city;
    _selectedDistrict = null;
    _selectedNeighborhood = null;
    _districts = [];
    _neighborhoods = [];
    notifyListeners();

    if (city != null) {
      fetchDistricts(city.cityNO);
    }
  }

  /// Sets selected district and fetches neighborhoods
  void setSelectedDistrict(DistrictModel? district) {
    _selectedDistrict = district;
    _selectedNeighborhood = null;
    _neighborhoods = [];
    notifyListeners();

    if (district != null) {
      fetchNeighborhoods(district.districtNO);
    }
  }

  /// Sets selected neighborhood
  void setSelectedNeighborhood(NeighborhoodModel? neighborhood) {
    _selectedNeighborhood = neighborhood;
    notifyListeners();
  }

  /// Sets selected address type
  void setSelectedAddressType(AddressTypeModel? addressType) {
    _selectedAddressType = addressType;
    notifyListeners();
  }

  /// Clears form selections
  void clearFormSelections() {
    _selectedCity = null;
    _selectedDistrict = null;
    _selectedNeighborhood = null;
    _selectedAddressType = null;
    _districts = [];
    _neighborhoods = [];
    notifyListeners();
  }

  /// Finds and sets city by name, then loads districts
  Future<void> setCityByName(String cityName) async {
    if (_cities.isEmpty) {
      await fetchCities();
    }
    final city = _cities.firstWhere(
      (c) => c.cityName.toUpperCase() == cityName.toUpperCase(),
      orElse: () => _cities.first,
    );
    _selectedCity = city;
    notifyListeners();
    await fetchDistricts(city.cityNO);
  }

  /// Finds and sets district by name, then loads neighborhoods
  Future<void> setDistrictByName(String districtName) async {
    if (_districts.isEmpty) return;
    try {
      final district = _districts.firstWhere(
        (d) => d.districtName.toUpperCase() == districtName.toUpperCase(),
      );
      _selectedDistrict = district;
      notifyListeners();
      await fetchNeighborhoods(district.districtNO);
    } catch (e) {
      // District not found
    }
  }

  /// Finds and sets address type by name
  void setAddressTypeByName(String typeName) {
    if (_addressTypes.isEmpty) return;
    try {
      final type = _addressTypes.firstWhere(
        (t) => t.typeName.toUpperCase() == typeName.toUpperCase(),
      );
      _selectedAddressType = type;
      notifyListeners();
    } catch (e) {
      // Type not found
    }
  }

  /// Adds a new address
  Future<bool> addAddress({
    required String userToken,
    required int addressType,
    required int addressCity,
    required int addressDistrict,
    required int addressNeighborhood,
    required String address,
    int? addressID,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AddAddressRequest(
        userToken: userToken,
        addressID: addressID,
        addressType: addressType,
        addressCity: addressCity,
        addressDistrict: addressDistrict,
        addressNeighborhood: addressNeighborhood,
        address: address,
      );

      final success = await _addressService.addAddress(request);
      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates an existing address
  Future<bool> updateAddress({
    required String userToken,
    required int addressID,
    required int addressCity,
    required int addressDistrict,
    required int addressNeighborhood,
    required String address,
  }) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = UpdateAddressRequest(
        userToken: userToken,
        addressID: addressID,
        addressCity: addressCity,
        addressDistrict: addressDistrict,
        addressNeighborhood: addressNeighborhood,
        address: address,
      );

      final success = await _addressService.updateAddress(request);
      _isSaving = false;
      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }
}
