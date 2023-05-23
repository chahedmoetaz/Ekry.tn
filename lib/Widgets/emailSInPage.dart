import 'dart:async';
import 'dart:io';

import 'package:easy_localization/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


abstract class PlatformWidget extends StatelessWidget {

  Widget buildCupertinoWidget(BuildContext context);
  Widget buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }
}


class PlatformExceptionAlertDialog extends PlatformAlertDialog {
  PlatformExceptionAlertDialog({String title, PlatformException exception})
      : super(
    title: title,
    content: message(exception),
    defaultActionText: tr("ok"),
  );

  static String message(PlatformException exception) {
    if (exception.message == 'FIRFirestoreErrorDomain') {
      if (exception.code == 'Code 7') {
        // This happens when we get a "Missing or insufficient permissions" error
        return 'This operation could not be completed due to a server error';
      }
      return exception.details;
    }
    return errors[exception.code] ?? exception.message;
  }

  // NOTE: The full list of FirebaseAuth errors is stored here:
  // https://github.com/firebase/firebase-ios-sdk/blob/2e77efd786e4895d50c3788371ec15980c729053/Firebase/Auth/Source/FIRAuthErrorUtils.m
  // These are just the most relevant for email & password sign in:
  static Map<String, String> errors = {
    'ERROR_WEAK_PASSWORD': tr("errpasswork"),
    'ERROR_INVALID_CREDENTIAL': tr("errmail"),
    'ERROR_EMAIL_ALREADY_IN_USE': tr("errmmail"),
    'ERROR_CREDENTIAL_ALREADY_IN_USE': tr("errmmail"),
    'ERROR_INVALID_EMAIL': tr("errmail"),
    'ERROR_WRONG_PASSWORD': tr("passwordinc"),
    'ERROR_USER_NOT_FOUND': tr('makeacc'),
    'ERROR_TOO_MANY_REQUESTS':tr("block"),
    'ERROR_OPERATION_NOT_ALLOWED': tr("connsup"),
  };
}



class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
    @required this.title,
    @required this.content,
    this.cancelActionText,
    @required this.defaultActionText,
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String cancelActionText;
  final String defaultActionText;

  Future<bool> show(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
      context: context,
      builder: (BuildContext context) => this,
    )
        : await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => this,
    );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        PlatformAlertDialogAction(
          child: Text(
            cancelActionText,
            key: Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
        child: Text(
          defaultActionText,
          key: Key(Keys.alertDefault),
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({this.child, this.onPressed});
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
}
class Keys {
  static const String anonymous = 'anonymous';
  static const String logout = 'logout';
  static const String alertDefault = 'alertDefault';
  static const String alertCancel = 'alertCancel';
}
