import 'package:flutter/material.dart';

import 'color_manager.dart';
import 'font_manager.dart';
import 'styles_manager.dart';
import 'values_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ColorManager.white,
    // main colors of the app
    primaryColor: ColorManager.primary,
    disabledColor: ColorManager.grey1,
    primaryColorDark: ColorManager.darkPrimary,
    primaryColorLight: ColorManager.lightPrimary,
    // ripple color
    splashColor: ColorManager.primary,
    // will be used in case of disabled button for example
    colorScheme: ColorScheme.fromSwatch().copyWith(
      secondary: ColorManager.grey,
    ),

    // card view theme
    cardTheme: CardThemeData(
      color: ColorManager.white,
      shadowColor: ColorManager.grey,
      elevation: AppSizeHeight.s4,
    ),
    // App bar theme
    appBarTheme: AppBarTheme(
      centerTitle: true,
      backgroundColor: ColorManager.primary,
      elevation: AppSizeHeight.s4,
      shadowColor: ColorManager.primary,
      titleTextStyle: getRegularStyle(
        color: ColorManager.white,
        fontSize: FontSize.s16,
      ),
    ),
    // Button theme
    buttonTheme: ButtonThemeData(
      shape: const StadiumBorder(),
      disabledColor: ColorManager.grey1,
      buttonColor: ColorManager.darkPrimary,
      splashColor: ColorManager.darkPrimary,
    ),

    // elevated button theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: AppSizeHeight.s1,
        backgroundColor: ColorManager.primary,
        textStyle: getRegularStyle(
          fontSize: FontSize.s16,
          color: ColorManager.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizeHeight.s12),
        ),
      ),
    ),

    // Text theme
    textTheme: TextTheme(
      displayLarge: getBoldStyle(
        fontSize: FontSize.s50,
        color: ColorManager.darkPrimary,
      ),
      displayMedium: getBoldStyle(
        fontSize: FontSize.s18,
        color: ColorManager.darkPrimary,
      ),
      titleMedium: getMediumStyle(
        fontSize: FontSize.s11,
        color: ColorManager.white,
      ),
      titleSmall: getMediumStyle(
        fontSize: FontSize.s8,
        color: ColorManager.white,
      ),
      bodySmall: getRegularStyle(
        fontSize: FontSize.s10,
        color: ColorManager.white,
      ),
      // bodyLarge: getRegularStyle(
      //   fontSize: FontSize.s18,
      //   color: ColorManager.grey,
      // ),
      // labelSmall: getBoldStyle(
      //   color: ColorManager.darkPrimary,
      //   fontSize: FontSize.s10,
      // ),
      // bodyMedium: getRegularStyle(
      //   color: ColorManager.grey2,
      //   fontSize: FontSize.s12,
      // ),
    ),

    // input decoration theme (text form field)
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(AppPaddingHeight.p8),
      // hint style
      hintStyle: getRegularStyle(
        color: ColorManager.grey1,
        fontSize: FontSize.s100,
      ),

      // label style
      labelStyle: getMediumStyle(
        color: ColorManager.darkGrey,
        fontSize: FontSize.s100,
      ),
      // error style
      errorStyle: getRegularStyle(
        color: ColorManager.error,
        fontSize: FontSize.s100,
      ),

      // enabled border
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSizeHeight.s0_2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSizeHeight.s8)),
      ),

      // focused border
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSizeHeight.s0_5,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSizeHeight.s8)),
      ),

      // error border
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.error,
          width: AppSizeHeight.s0_2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSizeHeight.s8)),
      ),
      // focused error border
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorManager.primary,
          width: AppSizeHeight.s0_2,
        ),
        borderRadius: BorderRadius.all(Radius.circular(AppSizeHeight.s8)),
      ),
    ),
  );
}
