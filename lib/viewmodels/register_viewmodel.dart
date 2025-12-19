import 'package:flutter/foundation.dart';
import '../models/auth/register_model.dart';
import '../models/auth/location_model.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingCities = false;
  bool get isLoadingCities => _isLoadingCities;

  bool _isLoadingDistricts = false;
  bool get isLoadingDistricts => _isLoadingDistricts;

  bool _isLoadingNeighborhoods = false;
  bool get isLoadingNeighborhoods => _isLoadingNeighborhoods;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  RegisterResponseModel? _registerResponse;
  RegisterResponseModel? get registerResponse => _registerResponse;

  // Location Data
  List<CityModel> _cities = [];
  List<CityModel> get cities => _cities;

  List<DistrictModel> _districts = [];
  List<DistrictModel> get districts => _districts;

  List<NeighborhoodModel> _neighborhoods = [];
  List<NeighborhoodModel> get neighborhoods => _neighborhoods;

  // Selected Values
  CityModel? _selectedCity;
  CityModel? get selectedCity => _selectedCity;

  DistrictModel? _selectedDistrict;
  DistrictModel? get selectedDistrict => _selectedDistrict;

  NeighborhoodModel? _selectedNeighborhood;
  NeighborhoodModel? get selectedNeighborhood => _selectedNeighborhood;

  int _selectedStoreType = 1; // Default: Şahıs Şirketi
  int get selectedStoreType => _selectedStoreType;

  // Policies
  bool _isPolicy = false;
  bool get isPolicy => _isPolicy;

  bool _isIyzicoPolicy = false;
  bool get isIyzicoPolicy => _isIyzicoPolicy;

  bool _isKvkkPolicy = false;
  bool get isKvkkPolicy => _isKvkkPolicy;

  // Setters for policies
  void setPolicy(bool value) {
    _isPolicy = value;
    notifyListeners();
  }

  void setIyzicoPolicy(bool value) {
    _isIyzicoPolicy = value;
    notifyListeners();
  }

  void setKvkkPolicy(bool value) {
    _isKvkkPolicy = value;
    notifyListeners();
  }

  void setStoreType(int type) {
    _selectedStoreType = type;
    notifyListeners();
  }

  void setCity(CityModel? city) {
    _selectedCity = city;
    _selectedDistrict = null;
    _selectedNeighborhood = null;
    _districts = [];
    _neighborhoods = [];
    notifyListeners();

    if (city != null) {
      loadDistricts(city.id);
    }
  }

  void setDistrict(DistrictModel? district) {
    _selectedDistrict = district;
    _selectedNeighborhood = null;
    _neighborhoods = [];
    notifyListeners();

    if (district != null) {
      loadNeighborhoods(district.id);
    }
  }

  void setNeighborhood(NeighborhoodModel? neighborhood) {
    _selectedNeighborhood = neighborhood;
    notifyListeners();
  }

  Future<void> loadCities() async {
    _isLoadingCities = true;
    notifyListeners();

    try {
      _cities = await _locationService.getCities();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  Future<void> loadDistricts(int cityId) async {
    _isLoadingDistricts = true;
    notifyListeners();

    try {
      _districts = await _locationService.getDistricts(cityId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingDistricts = false;
      notifyListeners();
    }
  }

  Future<void> loadNeighborhoods(int districtId) async {
    _isLoadingNeighborhoods = true;
    notifyListeners();

    try {
      _neighborhoods = await _locationService.getNeighborhoods(districtId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingNeighborhoods = false;
      notifyListeners();
    }
  }

  String? validateForm({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String storeName,
    required String address,
    required String taxNo,
  }) {
    if (firstName.trim().isEmpty) {
      return 'Ad alanı zorunludur.';
    }
    if (lastName.trim().isEmpty) {
      return 'Soyad alanı zorunludur.';
    }
    if (email.trim().isEmpty || !email.contains('@')) {
      return 'Geçerli bir e-posta adresi giriniz.';
    }
    if (phone.trim().isEmpty) {
      return 'Telefon numarası zorunludur.';
    }
    if (storeName.trim().isEmpty) {
      return 'Mağaza adı zorunludur.';
    }
    if (_selectedCity == null) {
      return 'İl seçimi zorunludur.';
    }
    if (_selectedDistrict == null) {
      return 'İlçe seçimi zorunludur.';
    }
    if (_selectedNeighborhood == null) {
      return 'Mahalle seçimi zorunludur.';
    }
    if (address.trim().isEmpty) {
      return 'Adres alanı zorunludur.';
    }
    if (taxNo.trim().isEmpty) {
      return _selectedStoreType == 1
          ? 'TC Kimlik Numarası zorunludur.'
          : 'Vergi Numarası zorunludur.';
    }
    if (_selectedStoreType == 1 && taxNo.length != 11) {
      return 'TC Kimlik Numarası 11 haneli olmalıdır.';
    }
    if (_selectedStoreType == 2 && taxNo.length != 10) {
      return 'Vergi Numarası 10 haneli olmalıdır.';
    }
    if (!_isPolicy) {
      return 'Üyelik sözleşmesini kabul etmelisiniz.';
    }
    if (!_isIyzicoPolicy) {
      return 'iyzico sözleşmesini kabul etmelisiniz.';
    }
    if (!_isKvkkPolicy) {
      return 'KVKK sözleşmesini kabul etmelisiniz.';
    }
    return null;
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String storeName,
    required String address,
    required String taxNo,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _registerResponse = null;
    notifyListeners();

    try {
      final request = RegisterRequestModel(
        userFirstname: firstName,
        userLastname: lastName,
        userEmail: email,
        userPhone: phone,
        storeName: storeName,
        storeType: _selectedStoreType,
        storeCity: _selectedCity!.id,
        storeDistrict: _selectedDistrict!.id,
        storeNeighborhood: _selectedNeighborhood!.id,
        storeAddress: address,
        storeTaxno: taxNo,
        isPolicy: _isPolicy ? 1 : 0,
        isIyzicoPolicy: _isIyzicoPolicy ? 1 : 0,
        isKvkkPolicy: _isKvkkPolicy ? 1 : 0,
      );

      _registerResponse = await _authService.register(request);

      if (_registerResponse != null &&
          (!_registerResponse!.success || _registerResponse!.error)) {
        _errorMessage = _registerResponse!.message;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _registerResponse = null;
    _selectedCity = null;
    _selectedDistrict = null;
    _selectedNeighborhood = null;
    _districts = [];
    _neighborhoods = [];
    _selectedStoreType = 1;
    _isPolicy = false;
    _isIyzicoPolicy = false;
    _isKvkkPolicy = false;
    notifyListeners();
  }
}
