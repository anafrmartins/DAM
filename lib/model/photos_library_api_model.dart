import 'dart:collection';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:scoped_model/scoped_model.dart';

import '../photos_library_api/album.dart';
import '../photos_library_api/batch_create_media_items_request.dart';
import '../photos_library_api/batch_create_media_items_response.dart';
import '../photos_library_api/create_album_request.dart';
import '../photos_library_api/get_album_request.dart';
import '../photos_library_api/join_shared_album_request.dart';
import '../photos_library_api/join_shared_album_response.dart';
import '../photos_library_api/photos_library_api_client.dart';
import '../photos_library_api/search_media_items_request.dart';
import '../photos_library_api/search_media_items_response.dart';
import '../photos_library_api/share_album_request.dart';
import '../photos_library_api/share_album_response.dart';

class PhotosLibraryApiModel extends Model {
  PhotosLibraryApiModel() {
    _googleSignIn.onCurrentUserChanged.listen((account) {
      _currentUser = account;

      if (_currentUser != null) {
        // Iniciar o cliente com novas credencias do utilizador
        client = PhotosLibraryApiClient(_currentUser!.authHeaders);
      } else {
        client = null;
      }
      // Reiniciar o album
      updateAlbums();

      notifyListeners();
    });
  }

  final LinkedHashSet<Album> _albums = LinkedHashSet<Album>();
  bool hasAlbums = false;
  PhotosLibraryApiClient? client;

  GoogleSignInAccount? _currentUser;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'profile',
      'https://www.googleapis.com/auth/photoslibrary',
      'https://www.googleapis.com/auth/photoslibrary.sharing'
    ],
  );
  GoogleSignInAccount? get user => _currentUser;

  bool isLoggedIn() {
    return _currentUser != null;
  }

  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  Future<GoogleSignInAccount?> signInSilently() =>
      _googleSignIn.signInSilently();

  Future<void> signOut() => _googleSignIn.disconnect();

  Future<Album?> createAlbum(String title) async {
    final album =
        await client!.createAlbum(CreateAlbumRequest.fromTitle(title));

    await updateAlbums();
    return album;
  }

  Future<Album> getAlbum(String id) async =>
      client!.getAlbum(GetAlbumRequest.defaultOptions(id));

  Future<JoinSharedAlbumResponse> joinSharedAlbum(String shareToken) async {
    final response =
        await client!.joinSharedAlbum(JoinSharedAlbumRequest(shareToken));
    await updateAlbums();
    return response;
  }

  Future<ShareAlbumResponse> shareAlbum(String albumId) async {
    final response = await client!.shareAlbum(
        ShareAlbumRequest(albumId, SharedAlbumOptions.fullCollaboration()));

    await updateAlbums();
    return response;
  }

  void unShareAlbum(String token) async {
    final response = client!.unShareAlbum(token);
  }

  Future<SearchMediaItemsResponse> searchMediaItems(String? albumId) async =>
      client!.searchMediaItems(SearchMediaItemsRequest.albumId(albumId));

  Future<String> uploadMediaItem(File image) {
    return client!.uploadMediaItem(image);
  }

  Future<BatchCreateMediaItemsResponse?> createMediaItem(
      String uploadToken, String? albumId, String? description) async {
    // Construir a solicitação com o token, albumId e descrição.
    final request =
        BatchCreateMediaItemsRequest.inAlbum(uploadToken, albumId, description);

    // Faça a chamada da API para criar o item de mídia. A resposta contém um
    // item de mídia.
    final response = await client!.batchCreateMediaItems(request);

    print(response.newMediaItemResults?[0].toJson());
    return response;
  }

  UnmodifiableListView<Album> get albums =>
      UnmodifiableListView<Album>(_albums);

  Future<void> updateAlbums() async {
    // Reinicializa o sinalizador antes de carregar novos álbuns
    hasAlbums = false;

    //Limpa todos os álbuns
    _albums.clear();

    // Ignora se não estiver conectado
    if (!isLoggedIn()) {
      return;
    }

    // Carregar álbuns de álbuns próprios e compartilhados
    final list = await Future.wait([_loadSharedAlbums(), _loadAlbums()]);

    _albums.addAll(list.expand((a) => a ?? []));

    notifyListeners();
    hasAlbums = true;
  }

  /// Carrega Álbuns no modelo recuperando a lista de todos os álbuns compartilhados
  /// com o usuário.
  Future<List<Album>?> _loadSharedAlbums() {
    return client!.listSharedAlbums().then(
      (response) {
        return response.sharedAlbums;
      },
    );
  }

  /// Carrega álbuns no modelo recuperando a lista de todos os álbuns de propriedade
  /// pelo usuário.
  Future<List<Album>?> _loadAlbums() {
    return client!.listAlbums().then(
      (response) {
        return response.albums;
      },
    );
  }
}
