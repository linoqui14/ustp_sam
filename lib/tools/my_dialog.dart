
import 'package:flutter/material.dart';


class MyDialog {

  MyDialog();

  Future<void> show({
    required BuildContext context,
    required StatefulBuilder statefulBuilder
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return statefulBuilder;



      },
    );
  }



}