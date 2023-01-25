import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../pages/register_page.dart';
import '../model/photos_library_api_model.dart';
import 'conection_google_page.dart';
import 'album_list_page.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (context, child, apiModel) {
        return apiModel.isLoggedIn()
            ? const AlbumListPage()
            : const ConectionGooglePage();
      },
    );
  }
}
