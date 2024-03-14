import 'package:flutter/material.dart';

class PredictionProvider extends ChangeNotifier {
  String _name = "";
  double _accuracy = 0.0;
  bool _image = false;

  String get name => _name;
  double get accuracy => _accuracy;
  bool get image => _image;

  void setPrediction(String name, double accuracy) {
    _name = name;
    _accuracy = accuracy;
    notifyListeners();
  }

  void setImage() {
    _image = !_image;
    notifyListeners();
  }
}
