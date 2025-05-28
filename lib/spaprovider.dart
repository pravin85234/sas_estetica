import 'package:flutter/material.dart';
import 'spa.dart';

class SpaProvider extends ChangeNotifier {
  Spa? _selectedSpa;
  List<String> _selectedServices = [];
  List<Map<String, dynamic>> _allServices = [];

  Spa? get selectedSpa => _selectedSpa;
  List<String> get selectedServices => _selectedServices;

  void setSelectedSpa(Spa spa) {
    _selectedSpa = spa;
    _selectedServices = [];
    notifyListeners();
  }

  void setAllServices(List<Map<String, dynamic>> services) {
    _allServices = services;
    notifyListeners();
  }

  List<Map<String, dynamic>> get allServices => _allServices;

  void toggleService(String serviceName) {
    if (_selectedServices.contains(serviceName)) {
      _selectedServices.remove(serviceName);
    } else {
      _selectedServices.add(serviceName);
    }
    notifyListeners();
  }

  int get selectedCount => _selectedServices.length;

  List<Map<String, dynamic>> getSelectedServiceDetails() {
    return _allServices
        .where((s) => _selectedServices.contains(s['name']))
        .toList();
  }

  int getTotalPrice() {
    return getSelectedServiceDetails().fold(0, (sum, s) => sum + ((s['price'] ?? 0) as int));
  }

  void clearSelectedServices() {
    _selectedServices.clear();
    notifyListeners();
  }
}
