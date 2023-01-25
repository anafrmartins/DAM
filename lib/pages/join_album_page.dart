import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/photos_library_api_model.dart';

class JoinAlbumPage extends StatefulWidget {
  const JoinAlbumPage({super.key});

  @override
  State<JoinAlbumPage> createState() => _JoinAlbumPageState();
}

class _JoinAlbumPageState extends State<JoinAlbumPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController shareTokenFormController =
      TextEditingController();

  @override
  void dispose() {
    shareTokenFormController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(25),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      controller: shareTokenFormController,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        hintText: 'Cole o Token de Partilha',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 0,
                      ),
                      child: const Text(
                        'Isso fará parte de um álbum na sua conta do Google Fotos',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () => _joinTrip(context),
                        child: const Text('Participar de um Album'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _joinTrip(BuildContext context) async {
    // Show loading indicator
    setState(() => _isLoading = true);

    // Call the API to join an album with the entered share token
    await ScopedModel.of<PhotosLibraryApiModel>(context)
        .joinSharedAlbum(shareTokenFormController.text);
    if (!mounted) return;

    // Hide loading indicator
    setState(() => _isLoading = false);

    // Return to the previous screen
    Navigator.of(context).pushReplacementNamed('/album-list');
  }
}
