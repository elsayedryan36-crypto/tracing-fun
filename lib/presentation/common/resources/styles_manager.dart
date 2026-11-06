import 'package:flutter/material.dart';

import 'font_manager.dart';

TextStyle _getTextStyle(double fontSize, FontWeight fontWeight, Color color) {
  return TextStyle(
    fontFamily: FontConstants.arabicFont,
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
  );
}

// regular style
TextStyle getRegularStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.regular, color);
}

// light text style
TextStyle getLightStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.light, color);
}

// bold text style
TextStyle getBoldStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.bold, color);
}

// semi bold text style
TextStyle getSemiBoldStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.semiBold, color);
}

// medium text style
TextStyle getMediumStyle({required double fontSize, required Color color}) {
  return _getTextStyle(fontSize, FontWeightManager.medium, color);
}
