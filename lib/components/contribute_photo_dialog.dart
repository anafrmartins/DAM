import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/photos_library_api_model.dart';
import '../pages/photo_page.dart';

class ContributePhotoDialog extends StatefulWidget {
  const ContributePhotoDialog({super.key});

  @override
  State<StatefulWidget> createState() => _ContributePhotoDialogState();
}

class _ContributePhotoDialogState extends State<ContributePhotoDialog> {
  File? _image;
  String? _uploadToken;
  bool _isUploading = false;
  final _imagePicker = ImagePicker();

  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: IntrinsicHeight(
            child: Column(
              children: <Widget>[
                _buildUploadButton(context),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Adiciona uma descrição',
                      labelStyle: TextStyle(
                        color: Colors.black,
                      )),
                ),
                Align(
                  alignment: const FractionalOffset(1, 0),
                  child: _buildAddButton(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  ElevatedButton _buildAddButton(BuildContext context) {
    if (_image == null) {
      // No image has been selected yet
      return const ElevatedButton(
        onPressed: null,
        child: Text('ADD'),
      );
    }

    if (_uploadToken == null) {
      // Upload ainda não conluiu
      return const ElevatedButton(
        onPressed: null,
        child: Text('Aguarde ao upload da imagem...'),
      );
    }

    // Caso contrário, o upload foi concluído e um token de upload foi definido
    return ElevatedButton(
      onPressed: () => Navigator.pop(
        context,
        ContributePhotoResult(
          _uploadToken!,
          descriptionController.text,
        ),
      ),
      child: const Text('ADD'),
    );
  }

  Widget _buildUploadButton(BuildContext context) {
    if (_image != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.file(_image!),
              _isUploading ? const LinearProgressIndicator() : Container(),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: TextButton.icon(
            onPressed: () => _getImage(context),
            label: const Text('CAMERA PHOTO'),
            icon: const Icon(Icons.camera_alt),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          child: TextButton.icon(
            onPressed: () => _getImageCamera(context),
            label: const Text('GALERIA PHOTO'),
            icon: const Icon(Icons.photo),
          ),
        ),
      ],
    );
  }

  Future _getImageCamera(BuildContext context) async {
    // Pegar imagem directamente da galeria
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (!mounted) {
      // The context is invalid if the widget has been unmounted.
      return;
    }

    if (pickedImage == null) {
      // No image selected.
      return;
    }

    final pickedFile = File(pickedImage.path);

    // Store the image that was selected.
    setState(() {
      _image = pickedFile;
      _isUploading = true;
    });

    // Make a request to upload the image to Google Photos once it was selected.
    final uploadToken = await ScopedModel.of<PhotosLibraryApiModel>(context)
        .uploadMediaItem(pickedFile);

    setState(() {
      // Once the upload process has completed, store the upload token.
      // This token is used together with the description to create the media
      // item later.
      _uploadToken = uploadToken;
      _isUploading = false;
    });
  }

  Future _getImage(BuildContext context) async {
    // Pegar imagem directamente da camera.
    final pickedImage = await (_imagePicker.pickImage(
      source: ImageSource.camera,
    ));

    if (!mounted) {
      return;
    }

    if (pickedImage == null) {
      return;
    }

    final pickedFile = File(pickedImage.path);

    // Armazena a imagem que foi selecionada.
    setState(() {
      _image = pickedFile;
      _isUploading = true;
    });

    // Faça uma solicitação para enviar a imagem para o Google Fotos assim que ela for selecionada.
    final uploadToken = await ScopedModel.of<PhotosLibraryApiModel>(context)
        .uploadMediaItem(pickedFile);

    setState(() {
      // Depois que o processo de upload for concluído, armazene o token de upload.
      // Este token é usado junto com a descrição para criar a mídia
      // item mais tarde
      _uploadToken = uploadToken;
      _isUploading = false;
    });
  }
}
