import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../components/primary_raised_button.dart';
import '../model/photos_library_api_model.dart';

class CreateAlbumPage extends StatefulWidget {
  const CreateAlbumPage({super.key});

  @override
  State<CreateAlbumPage> createState() => _CreateAlbumPageState();
}

class _CreateAlbumPageState extends State<CreateAlbumPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final TextEditingController tripNameFormController = TextEditingController();

  @override
  void dispose() {
    tripNameFormController.dispose();
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
                      controller: tripNameFormController,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        hintText: 'Nome do Album',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 0,
                      ),
                      child: const Text(
                        'Isso criará um álbum compartilhado em seu Google Fotos',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Center(
                      child: PrimaryRaisedButton(
                        onPressed: () => _createTrip(context),
                        label: const Text('Criar Album'),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> _createTrip(BuildContext context) async {
    // Display the loading indicator.
    setState(() => _isLoading = true);

    await ScopedModel.of<PhotosLibraryApiModel>(context)
        .createAlbum(tripNameFormController.text);
    if (!mounted) return;

    // Hide the loading indicator.
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed('/album-list');
  }
}
