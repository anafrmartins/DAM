import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

import 'album.dart';
import 'batch_create_media_items_request.dart';
import 'batch_create_media_items_response.dart';
import 'create_album_request.dart';
import 'get_album_request.dart';
import 'join_shared_album_request.dart';
import 'join_shared_album_response.dart';
import 'list_albums_response.dart';
import 'list_shared_albums_response.dart';
import 'search_media_items_request.dart';
import 'search_media_items_response.dart';
import 'share_album_request.dart';
import 'share_album_response.dart';

class PhotosLibraryApiClient {
  PhotosLibraryApiClient(this._authHeaders);

  final Future<Map<String, String>> _authHeaders;

  Future<Album> createAlbum(CreateAlbumRequest request) async {
    final response = await http.post(
      Uri.parse('https://photoslibrary.googleapis.com/v1/albums'),
      body: jsonEncode(request),
      headers: await _authHeaders,
    );

    printError(response);

    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<JoinSharedAlbumResponse> joinSharedAlbum(
      JoinSharedAlbumRequest request) async {
    final response = await http.post(
        Uri.parse('https://photoslibrary.googleapis.com/v1/sharedAlbums:join'),
        headers: await _authHeaders,
        body: jsonEncode(request));

    printError(response);

    return JoinSharedAlbumResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ShareAlbumResponse> shareAlbum(ShareAlbumRequest request) async {
    final response = await http.post(
        Uri.parse(
            'https://photoslibrary.googleapis.com/v1/albums/${request.albumId}:share'),
        headers: await _authHeaders,
        body: jsonEncode(request));

    printError(response);

    return ShareAlbumResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  void unShareAlbum(String token) async {
    final response = await http.post(
        Uri.parse('https://photoslibrary.googleapis.com/v1/sharedAlbums:leave'),
        headers: await _authHeaders,
        body: {"shareToken": token});

    printError(response);

    print("Response");
    print(response);
  }

  Future<Album> getAlbum(GetAlbumRequest request) async {
    final response = await http.get(
        Uri.parse(
            'https://photoslibrary.googleapis.com/v1/albums/${request.albumId}'),
        headers: await _authHeaders);

    printError(response);

    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ListAlbumsResponse> listAlbums() async {
    final response = await http.get(
        Uri.parse('https://photoslibrary.googleapis.com/v1/albums?'
            'pageSize=50&excludeNonAppCreatedData=true'),
        headers: await _authHeaders);

    printError(response);

    print(response.body);

    return ListAlbumsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<ListSharedAlbumsResponse> listSharedAlbums() async {
    final response = await http.get(
        Uri.parse('https://photoslibrary.googleapis.com/v1/sharedAlbums?'
            'pageSize=50&excludeNonAppCreatedData=true'),
        headers: await _authHeaders);

    printError(response);

    print(response.body);

    return ListSharedAlbumsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<String> uploadMediaItem(File image) async {
    // Get the filename of the image
    final filename = path.basename(image.path);

    // Set up the headers required for this request.
    final headers = <String, String>{};
    headers.addAll(await _authHeaders);
    headers['Content-type'] = 'application/octet-stream';
    headers['X-Goog-Upload-Protocol'] = 'raw';
    headers['X-Goog-Upload-File-Name'] = filename;

    // Make the HTTP request to upload the image. The file is sent in the body.
    final response = await http.post(
      Uri.parse('https://photoslibrary.googleapis.com/v1/uploads'),
      body: image.readAsBytesSync(),
      headers: await _authHeaders,
    );

    printError(response);

    return response.body;
  }

  Future<SearchMediaItemsResponse> searchMediaItems(
      SearchMediaItemsRequest request) async {
    final response = await http.post(
      Uri.parse('https://photoslibrary.googleapis.com/v1/mediaItems:search'),
      body: jsonEncode(request),
      headers: await _authHeaders,
    );

    printError(response);

    return SearchMediaItemsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<BatchCreateMediaItemsResponse> batchCreateMediaItems(
      BatchCreateMediaItemsRequest request) async {
    print(request.toJson());
    final response = await http.post(
        Uri.parse(
            'https://photoslibrary.googleapis.com/v1/mediaItems:batchCreate'),
        body: jsonEncode(request),
        headers: await _authHeaders);

    print('Ola');

    printError(response);

    return BatchCreateMediaItemsResponse.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>);
  }

  static void printError(final Response response) {
    if (response.statusCode != 200) {
      print(response.reasonPhrase);
      print(response.body);
    }
  }
}
