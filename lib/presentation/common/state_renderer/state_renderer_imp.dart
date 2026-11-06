// ignore_for_file: type_literal_in_constant_pattern
import 'package:flutter/material.dart';
import 'package:tracing_app/presentation/common/state_renderer/state_renderer.dart';

import '../../../app/constants.dart';
import '../resources/strings_manager.dart';

abstract class FlowState {
  dynamic get data => null;
  Function getFunction();

  StateRendererType getStateRendererType();

  String getMessage();
}

// Initial state (POPUP,FULL SCREEN)

class InitialState extends FlowState {
  @override
  String getMessage() {
    return AppStrings.loading;
  }

  @override
  StateRendererType getStateRendererType() {
    throw UnimplementedError();
  }

  @override
  Function getFunction() {
    return () {};
  }
}

// loading state (POPUP,FULL SCREEN)

class LoadingState extends FlowState {
  StateRendererType stateRendererType;
  String? message;

  LoadingState({
    required this.stateRendererType,
    String message = AppStrings.loading,
  });

  @override
  String getMessage() => message ?? AppStrings.loading;

  @override
  StateRendererType getStateRendererType() => stateRendererType;

  @override
  Function getFunction() {
    return () {};
  }
}

// error state (POPUP,FULL SCREEN)
class ErrorState extends FlowState {
  StateRendererType stateRendererType;
  String message;

  ErrorState(this.stateRendererType, this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() => stateRendererType;

  @override
  Function getFunction() {
    return () {};
  }
}

// content state

class ContentState extends FlowState {
  StateRendererType stateRendererType;

  @override
  final dynamic data;

  ContentState(this.stateRendererType, this.data);

  @override
  String getMessage() => Constants.empty;

  @override
  StateRendererType getStateRendererType() => StateRendererType.contentState;

  @override
  Function getFunction() {
    return () {};
  }
}

// EMPTY STATE

class EmptyState extends FlowState {
  String message;

  EmptyState(this.message);

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() =>
      StateRendererType.fullScreenEmptyState;

  @override
  Function getFunction() {
    return () {};
  }
}

class SuccessState extends FlowState {
  String message;
  Function successFunction; // Rename the variable to avoid conflicts
  @override
  final dynamic data;
  SuccessState(
    this.message,
    this.data,
    this.successFunction,
  ); // Update the constructor

  @override
  String getMessage() => message;

  @override
  StateRendererType getStateRendererType() =>
      StateRendererType.popupSuccessState;

  @override
  Function getFunction() => successFunction; // Update the function getter
}

///////////////////////////////////////////////////////
///
extension FlowStateExtension on FlowState {
  Widget getScreenWidget(
    BuildContext context,
    Widget contentScreenWidget,
    Function retryActionFunction,
  ) {
    switch (runtimeType) {
      case LoadingState:
        {
          if (getStateRendererType() == StateRendererType.popupLoadingState) {
            // show popup loading
            showPopup(
              context,
              getStateRendererType(),
              getMessage(),
              retryActionFunction,
            );
            // show content ui of the screen
            return contentScreenWidget;
          } else {
            // full screen loading state
            return StateRenderer(
              message: getMessage(),
              stateRendererType: getStateRendererType(),
              retryActionFunction: retryActionFunction,
            );
          }
        }
      case ErrorState:
        {
          dismissDialog(context);
          if (getStateRendererType() == StateRendererType.popupErrorState) {
            // show popup error
            showPopup(
              context,
              getStateRendererType(),
              getMessage(),
              retryActionFunction,
            );
            // show content ui of the screen
            return contentScreenWidget;
          } else {
            // full screen error state
            return StateRenderer(
              message: getMessage(),
              stateRendererType: getStateRendererType(),
              retryActionFunction: retryActionFunction,
            );
          }
        }
      case EmptyState:
        {
          return StateRenderer(
            stateRendererType: getStateRendererType(),
            message: getMessage(),
            retryActionFunction: retryActionFunction,
          );
        }
      case ContentState:
        {
          if (getStateRendererType() == StateRendererType.contentState
          // || getStateRendererType() == StateRendererType.paginationStlate
          ) {
            return contentScreenWidget;
          } else {
            return Container();
          }
        }

      case SuccessState:
        {
          // i should check if we are showing loading popup to remove it before showing success popup
          dismissDialog(context);

          // show popup
          showPopup(
            context,
            StateRendererType.popupSuccessState,
            getMessage(),
            retryActionFunction,
            title: AppStrings.success,
          );
          // return content ui of the screen
          return contentScreenWidget;
        }
      default:
        {
          dismissDialog(context);
          return contentScreenWidget;
        }
    }
  }

  bool _isCurrentDialogShowing(BuildContext context) =>
      ModalRoute.of(context)?.isCurrent != true;

  void dismissDialog(BuildContext context) {
    if (_isCurrentDialogShowing(context)) {
      Navigator.of(context, rootNavigator: true).pop(true);
    }
  }

  void showPopup(
    BuildContext context,
    StateRendererType stateRendererType,
    String message,
    Function function, {
    String title = Constants.empty,
  }) {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showDialog(
        context: context,
        builder: (BuildContext context) => StateRenderer(
          stateRendererType: stateRendererType,
          message: message,
          title: title,
          retryActionFunction: function,
        ),
      ),
    );
  }
}

class FlowStateExtensionWidget extends StatelessWidget {
  final FlowState flowState;
  final Widget contentScreenWidget;
  final Function retryActionFunction;

  const FlowStateExtensionWidget({
    super.key,
    required this.flowState,
    required this.contentScreenWidget,
    required this.retryActionFunction,
  });

  @override
  Widget build(BuildContext context) {
    return flowState.getScreenWidget(
      context,
      contentScreenWidget,
      retryActionFunction,
    );
  }
}
