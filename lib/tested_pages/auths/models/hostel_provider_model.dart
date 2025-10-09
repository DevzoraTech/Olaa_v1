import 'package:flutter/material.dart';

class HostelProviderModel extends ChangeNotifier {
  // Business Information
  String _businessName = '';
  String _contactPerson = '';
  String _businessType = 'hostel';

  // Contact Information
  String _phoneNumber = '';
  String _email = '';
  String _address = '';

  // Property Details
  List<String> _amenities = [];
  String _description = '';

  // State
  bool _isLoading = false;
  int _currentStep = 0;

  // Getters
  String get businessName => _businessName;
  String get contactPerson => _contactPerson;
  String get businessType => _businessType;
  String get phoneNumber => _phoneNumber;
  String get email => _email;
  String get address => _address;
  List<String> get amenities => _amenities;
  String get description => _description;
  bool get isLoading => _isLoading;
  int get currentStep => _currentStep;

  // Setters
  void setBusinessName(String value) {
    _businessName = value;
    notifyListeners();
  }

  void setContactPerson(String value) {
    _contactPerson = value;
    notifyListeners();
  }

  void setBusinessType(String value) {
    _businessType = value;
    notifyListeners();
  }

  void setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setAddress(String value) {
    _address = value;
    notifyListeners();
  }

  void setAmenities(List<String> value) {
    _amenities = value;
    notifyListeners();
  }

  void addAmenity(String amenity) {
    if (!_amenities.contains(amenity)) {
      _amenities.add(amenity);
      notifyListeners();
    }
  }

  void removeAmenity(String amenity) {
    _amenities.remove(amenity);
    notifyListeners();
  }

  void setDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void nextStep() {
    if (_currentStep < 2) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Validation
  bool get isBusinessInfoValid {
    return _businessName.isNotEmpty &&
        _contactPerson.isNotEmpty &&
        _businessType.isNotEmpty;
  }

  bool get isContactInfoValid {
    return _phoneNumber.isNotEmpty &&
        _email.isNotEmpty &&
        _address.isNotEmpty &&
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email);
  }

  bool get isDescriptionValid {
    return _description.isNotEmpty && _description.length >= 20;
  }

  bool get canProceedToNextStep {
    switch (_currentStep) {
      case 0:
        return isBusinessInfoValid;
      case 1:
        return isContactInfoValid;
      case 2:
        return isDescriptionValid;
      default:
        return false;
    }
  }

  // Business Type Labels
  String getBusinessTypeLabel(String type) {
    switch (type) {
      case 'hostel':
        return 'Hostel';
      case 'apartment':
        return 'Apartment';
      case 'guesthouse':
        return 'Guest House';
      case 'student_residence':
        return 'Student Residence';
      case 'boarding_house':
        return 'Boarding House';
      default:
        return type;
    }
  }

  // Clear all data
  void clearAll() {
    _businessName = '';
    _contactPerson = '';
    _businessType = 'hostel';
    _phoneNumber = '';
    _email = '';
    _address = '';
    _amenities.clear();
    _description = '';
    _isLoading = false;
    _currentStep = 0;
    notifyListeners();
  }

  // Get all data as Map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'businessName': _businessName,
      'contactPerson': _contactPerson,
      'businessType': _businessType,
      'phoneNumber': _phoneNumber,
      'email': _email,
      'address': _address,
      'amenities': _amenities,
      'description': _description,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
