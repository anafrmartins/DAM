import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import '../components/p2photos_app_bar.dart';
import '../model/photos_library_api_model.dart';
import '../services/authentication_service.dart';
import 'album_list_page.dart';

class ConectionGooglePage extends StatelessWidget {
  const ConectionGooglePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const P2photosAppBar(),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    AuthenticationService auth =
        Provider.of<AuthenticationService>(context, listen: false);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: ScopedModelDescendant<PhotosLibraryApiModel>(
        builder: (context, child, apiModel) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'SEJA BEM-VINDO ${auth.userAuth!.displayName?.toUpperCase()}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              SvgPicture.asset(
                'assets/lockup_photos_horizontal.svg',
              ),
              Container(
                padding: const EdgeInsets.all(30),
                child: const Text(
                  'Os do P2PHOTOS serão armazenadas como álbuns compartilhados em'
                  'Google Photos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.w500, color: Color(0x99000000)),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(3),
                ),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                  ),
                  onPressed: () async {
                    try {
                      await apiModel.signIn() != null
                          ? _navigateToTripList(context)
                          : _showSignInError(context);
                    } on Exception catch (error) {
                      print(error);
                      _showSignInError(context);
                    }
                  },
                  child: const Text('Conecta com Google Photos'),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                ),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(15),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () =>
                      context.read<AuthenticationService>().logout(),
                  child: const Text('SAIR'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSignInError(BuildContext context) {
    const snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Text('Erro na conexão.\n'
          'Verifique a conexão com a internet ou o arquivo do google.'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _navigateToTripList(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AlbumListPage(),
      ),
    );
  }
}
