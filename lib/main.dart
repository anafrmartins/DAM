import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/pages/album_list_page.dart';
import 'package:sharing_codelab/pages/login_page.dart';
import 'package:sharing_codelab/pages/register_page.dart';
import './pages/auth_check.dart';
import './services/authentication_service.dart';

import 'model/photos_library_api_model.dart';
import 'pages/home_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  final apiModel = PhotosLibraryApiModel();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  apiModel.signInSilently();
  runApp(
    ScopedModel<PhotosLibraryApiModel>(
      model: apiModel,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData _theme = _buildTheme();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthenticationService())
      ],
      child: MaterialApp(
        title: 'P2PHOTOS',
        theme: _theme,
        routes: {
          "/": (context) => AuthCheck(),
          "/login": (context) => LoginPage(),
          "/register": (context) => RegisterPage(),
          "/album-list": (context) => AlbumListPage()
        },
      ),
    );
  }
}

ThemeData _buildTheme() {
  final base = ThemeData.light().copyWith(
    primaryColor: Colors.white,
    primaryTextTheme: Typography.blackMountainView,
    primaryIconTheme: const IconThemeData(
      color: Colors.grey,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
      foregroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    )),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
    )),
    scaffoldBackgroundColor: Colors.white,
  );
  return base.copyWith(
      colorScheme: base.colorScheme.copyWith(secondary: Colors.blue));
}
