import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:provider/provider.dart';
import 'package:sharing_codelab/pages/home_page.dart';
import 'package:sharing_codelab/pages/loading_page.dart';
import 'package:sharing_codelab/pages/login_page.dart';
import 'package:sharing_codelab/services/authentication_service.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    AuthenticationService auth = Provider.of<AuthenticationService>(context);

    if (auth.isLoading) {
      return LoadingPage();
    } else if (auth.userAuth == null) {
      return LoginPage();
    } else {
      return HomePage();
    }
  }
}
