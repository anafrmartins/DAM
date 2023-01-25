import 'package:fluttertoast/fluttertoast.dart';

class ToBeImplemented {
  const ToBeImplemented();

  static void showMessage() {
    Fluttertoast.showToast(
        msg: 'Not implemeneted (yet!) '
            '\ud83d\udc69\u200d\ud83d\udcbb', // A fancy emoji!
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1);
  }
}
