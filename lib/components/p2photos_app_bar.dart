import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/pages/login_page.dart';
import 'package:sharing_codelab/util/images_path.dart';
import '../model/photos_library_api_model.dart';
import '../pages/create_album_page.dart';
import '../pages/join_album_page.dart';
import '../pages/conection_google_page.dart';
import '../services/authentication_service.dart';

class P2photosAppBar extends StatefulWidget implements PreferredSizeWidget {
  const P2photosAppBar({super.key});

  @override
  State<P2photosAppBar> createState() => _P2photosAppBarState();

  @override
  Size get preferredSize => AppBar().preferredSize;
}

class _P2photosAppBarState extends State<P2photosAppBar> {
  @override
  Widget build(BuildContext context) {
    String userName = "";

    AuthenticationService auth =
        Provider.of<AuthenticationService>(context, listen: false);

    _cutName() {
      if (auth.userAuth!.displayName!.length > 6) {
        userName = auth.userAuth!.displayName!.substring(0, 6) + "...";
      }
    }

    _cutName();

    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (context, child, apiModel) {
        return AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.only(right: 8),
                child: Image(
                  image: AssetImage(ImagesPath.LOGO_WHITE),
                ),
                width: 150,
              ),
              SizedBox(
                width: 10,
              ),
              Text('Ola'),
              SizedBox(
                width: 10,
              ),
              Text(
                '${userName}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ],
          ),
          actions: _buildActions(apiModel, context),
        );
      },
    );
  }

  List<Widget> _buildActions(
      PhotosLibraryApiModel apiModel, BuildContext context) {
    final widgets = <Widget>[];

    AuthenticationService auth =
        Provider.of<AuthenticationService>(context, listen: false);

    if (apiModel.isLoggedIn()) {
      if (apiModel.user!.photoUrl != null) {
        widgets.add(
          CircleAvatar(
            radius: 14,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                apiModel.user!.photoUrl!,
              ),
            ),
          ),
        );
      } else {
        // Placeholder para usar quando não temos URL de imagem
        final placeholderCharSources = <String?>[
          apiModel.user!.displayName,
          apiModel.user!.email,
          '-',
        ];
        final placeholderChar = placeholderCharSources
            .firstWhere((str) => str != null && str.trimLeft().isNotEmpty)!
            .trimLeft()[0]
            .toUpperCase();

        widgets.add(
          SizedBox(
            height: 6,
            child: CircleAvatar(
              child: Text(placeholderChar),
            ),
          ),
        );
      }

      widgets.add(
        PopupMenuButton(
          onSelected: (selection) async {
            print(selection);
            if (selection == 1) {
              await apiModel.signOut();
              context.read<AuthenticationService>().logout();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LoginPage(),
                ),
              );
            } else {
              await apiModel.signOut();
              if (!mounted) return;
              await Navigator.pushReplacement(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const ConectionGooglePage(),
                ),
              );
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Disconectar Google Fotos',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(
                    Icons.door_back_door_sharp,
                    color: Colors.red,
                  ),
                  title: Text(
                    'Sair',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
            ];
          },
        ),
      );
    }

    return widgets;
  }
}

enum _AppBarOverflowOptions {
  signout,
}
