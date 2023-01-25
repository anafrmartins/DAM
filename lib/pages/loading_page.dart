import 'package:flutter/material.dart';
import '../util/images_path.dart';

class LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage('${ImagesPath.LOGO_BLACK}'),
                width: 250,
              ),
              CircularProgressIndicator(),
              Text('Carregando...'),
            ],
          ),
        ),
      ),
    );
  }
}
