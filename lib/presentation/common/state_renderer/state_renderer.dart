import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../resources/assets_manager.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/strings_manager.dart';
import '../resources/styles_manager.dart';
import '../resources/values_manager.dart';

// states list

enum StateRendererType {
  // POPUP STATES (DIALOG)
  popupLoadingState,
  popupErrorState,
  popupSuccessState,

  // FULL SCREEN STATED (FULL SCREEN)
  fullScreenLoadingState,
  fullScreenErrorState,
  fullScreenEmptyState,
  // general
  contentState,
  // paginationStlate
}

class StateRenderer extends StatelessWidget {
  final StateRendererType stateRendererType;
  final String message;
  final String title;
  final Function retryActionFunction;

  const StateRenderer({
    super.key,
    required this.stateRendererType,
    this.message = AppStrings.loading,
    this.title = "",
    required this.retryActionFunction,
  });

  @override
  Widget build(BuildContext context) {
    return _getStateWidget(context, retryActionFunction);
  }

  Widget _getStateWidget(BuildContext context, Function function) {
    switch (stateRendererType) {
      case StateRendererType.popupLoadingState:
        return _getPopUpDialog(context, [
          _getAnimatedImage(JsonAssets.loading),
        ]);
      case StateRendererType.popupErrorState:
        return _getPopUpDialog(context, [
          _getAnimatedImage(JsonAssets.error),
          _getMessage(message),
          _getRetryButton(AppStrings.ok, context, function),
        ]);
      case StateRendererType.fullScreenLoadingState:
        return _getItemsColumn([
          _getAnimatedImage(JsonAssets.loading),
          _getMessage(message),
        ]);
      case StateRendererType.fullScreenErrorState:
        return _getItemsColumn([
          _getAnimatedImage(JsonAssets.error),
          _getMessage(message),
          _getRetryButton(AppStrings.retryAgain, context, function),
        ]);
      case StateRendererType.fullScreenEmptyState:
        return _getItemsColumn([
          _getAnimatedImage(JsonAssets.empty),
          _getMessage(message),
        ]);
      case StateRendererType.contentState:
        return Container();
      // case StateRendererType.paginationStlate:
      //   return Container();
      case StateRendererType.popupSuccessState:
        return _getPopUpDialog(context, [
          _getAnimatedImage(JsonAssets.success),
          _getMessage(title),
          _getMessage(message),
          _getRetryButton(AppStrings.ok, context, function),
        ]);
    }
  }

  Widget _getPopUpDialog(BuildContext context, List<Widget> children) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizeHeight.s4),
      ),
      elevation: AppSizeHeight.s1_5,
      backgroundColor: ColorManager.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ColorManager.primary,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(AppSizeHeight.s4),
          boxShadow: const [BoxShadow(color: ColorManager.materialBlack26)],
        ),
        child: _getDialogContent(context, children),
      ),
    );
  }

  Widget _getDialogContent(BuildContext context, List<Widget> children) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _getItemsColumn(List<Widget> children) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _getAnimatedImage(String animationName) {
    return SizedBox(
      height: AppSizeHeight.s10,
      width: AppSizeHeight.s10,
      child: Lottie.asset(animationName),
    );
  }

  Widget _getMessage(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPaddingWidth.p_7),
        child: Text(
          message,
          style: getRegularStyle(
            color: ColorManager.darkPrimary,
            fontSize: FontSize.s17,
          ),
        ),
      ),
    );
  }

  Center _getRetryButton(
    String buttonTitle,
    BuildContext context,
    Function function,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppPaddingHeight.p3),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(ColorManager.darkPrimary),
            ),
            onPressed: () {
              if (stateRendererType == StateRendererType.fullScreenErrorState) {
                // Call the retry function
                function();
              } else {
                // Popup error state
                // Call the function
                Navigator.of(context).pop();
                function();
              }
            },
            child: Text(
              buttonTitle,
              style: getBoldStyle(
                fontSize: FontSize.s17,
                color: ColorManager.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
