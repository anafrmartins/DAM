import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/pages/image_page.dart';
import 'package:sharing_codelab/pages/loading_page.dart';
import '../components/contribute_photo_dialog.dart';
import '../components/primary_raised_button.dart';
import '../model/photos_library_api_model.dart';
import '../photos_library_api/album.dart';
import '../photos_library_api/media_item.dart';
import '../photos_library_api/search_media_items_response.dart';
import '../util/images_path.dart';

class PhotoPage extends StatefulWidget {
  const PhotoPage({super.key, this.searchResponse, required this.album});

  final Future<SearchMediaItemsResponse>? searchResponse;

  final Album album;

  @override
  State<StatefulWidget> createState() =>
      // ignore: no_logic_in_create_state
      _PhotoPageState(searchResponse: searchResponse, album: album);
}

class _PhotoPageState extends State<PhotoPage> {
  _PhotoPageState({this.searchResponse, required this.album});

  Album album;
  Future<SearchMediaItemsResponse>? searchResponse;
  bool _inSharingApiCall = false;

  List<String> opcoes = ['Utilizador Qualquer', 'Utilizador P2PHOTOS'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(
          album.title ?? '[sem titulo]',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        elevation: 0,
        actions: [
          SizedBox(
            width: 40,
            child: IconButton(
              onPressed: () {
                _contributePhoto(context);
              },
              icon: Icon(
                Icons.add,
                size: 30,
              ),
            ),
          ),
          PopupMenuButton(
            onSelected: (int value) {
              if (value == 0) {
                _showShareableUrl(context);
              } else {
                _showShareToken(context);
              }
            },
            child: SizedBox(
              width: 60,
              child: Icon(
                Icons.share,
                size: 30,
              ),
            ),
            itemBuilder: (_) {
              return List.generate(opcoes.length, (index) {
                return PopupMenuItem(
                  value: index,
                  child: Text('${opcoes[index]}'),
                );
              });
            },
          ),
        ],
      ),
      body: Builder(builder: (context) {
        return Column(
          children: <Widget>[
            Container(
              width: 348,
              margin: const EdgeInsets.only(bottom: 32),
            ),
            FutureBuilder<SearchMediaItemsResponse>(
              future: searchResponse,
              builder: _buildMediaItemList,
            )
          ],
        );
      }),
    );
  }

  Future<void> _shareAlbum(BuildContext context) async {
    String? id = album.id;

    if (id == null) {
      // Album is missing an ID.
      const snackBar = SnackBar(
        duration: Duration(seconds: 3),
        content: Text('Could not share album. Try reopening this page.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    // Show the loading indicator
    setState(() => _inSharingApiCall = true);

    const snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Text('Sharing Album...'),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // Share the album and update the local model
    await ScopedModel.of<PhotosLibraryApiModel>(context).shareAlbum(id);
    if (!mounted) return;
    final updatedAlbum =
        await ScopedModel.of<PhotosLibraryApiModel>(context).getAlbum(id);

    print('Album has been shared.');
    setState(() {
      album = updatedAlbum;
      // Hide the loading indicator
      _inSharingApiCall = false;
    });
  }

  Future<void> _showShareableUrl(BuildContext context) async {
    if (album.shareInfo == null || album.shareInfo!.shareableUrl == null) {
      print('Not shared, sharing album first.');

      // Album is not shared yet, share it first, then display dialog
      await _shareAlbum(context);
      if (!mounted) return;
      _showUrlDialog(context);
    } else {
      // Album is already shared, display dialog with URL
      _showUrlDialog(context);
    }
  }

  Future<void> _showShareToken(BuildContext context) async {
    if (album.shareInfo == null) {
      print('Not shared, sharing album first.');

      // Album is not shared yet, share it first, then display dialog
      await _shareAlbum(context);
      if (!mounted) return;
      _showTokenDialog(context);
    } else {
      // Album is already shared, display dialog with token
      _showTokenDialog(context);
    }
  }

  void _showTokenDialog(BuildContext context) {
    print('This is the shareToken:\n${album.shareInfo!.shareToken}');

    _showShareDialog(
        context, 'Use this token to share', album.shareInfo!.shareToken!);
  }

  void _showUrlDialog(BuildContext context) {
    print('This is the shareableUrl:\n${album.shareInfo!.shareableUrl}');

    _showShareDialog(
        context,
        'Share this URL with anyone. '
        'Anyone with this URL can access all items.',
        album.shareInfo!.shareableUrl!);
  }

  void _showShareDialog(BuildContext context, String title, String text) {
    showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Row(
              children: [
                Flexible(
                  child: Text(
                    text,
                  ),
                ),
                TextButton(
                  onPressed: () => Clipboard.setData(ClipboardData(text: text)),
                  child: const Text('Copy'),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          );
        });
  }

  Future<void> _contributePhoto(BuildContext context) async {
    // Show the contribute  dialog and upload a photo.
    final contributeResult = await (showDialog<ContributePhotoResult>(
      context: context,
      builder: (context) {
        return const ContributePhotoDialog();
      },
    ));

    if (!mounted) {
      // The context is invalid if the widget has been unmounted.
      return;
    }

    if (contributeResult == null) {
      // No contribution created or no media items to create.
      return;
    }

    // Create the media item from the uploaded photo.
    await ScopedModel.of<PhotosLibraryApiModel>(context).createMediaItem(
        contributeResult.uploadToken, album.id!, contributeResult.description);
    if (!mounted) return;

    // Do a new search for items inside this album and store its Future for display.
    final response = ScopedModel.of<PhotosLibraryApiModel>(context)
        .searchMediaItems(album.id);
    setState(() {
      searchResponse = response;
    });
  }

  Widget _buildShareButtons(BuildContext context) {
    if (_inSharingApiCall) {
      return const CircularProgressIndicator();
    }

    return Column(children: <Widget>[
      SizedBox(
        width: 254,
        child: TextButton(
          onPressed: () => _showShareableUrl(context),
          child: const Text('PARTILHE COM ALGUEM'),
        ),
      ),
      SizedBox(
        width: 254,
        child: TextButton(
          onPressed: () => _showShareToken(context),
          child: const Text('PARTILHE EM P2PHOTOS'),
        ),
      ),
    ]);
  }

  Widget _buildMediaItemList(
      BuildContext context, AsyncSnapshot<SearchMediaItemsResponse> snapshot) {
    if (snapshot.hasData) {
      final List<MediaItem>? items = snapshot.data!.mediaItems;
      if (items == null) {
        return Center(
          child: SizedBox(
            child: Text(
              'Não tem nenhuma foto neste album.',
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
        );
      }

      // return Expanded(
      //   child: ListView.builder(
      //     itemCount: items.length,
      //     itemBuilder: (context, index) {
      //       return _buildMediaItem(items[index]);
      //     },
      //   ),
      // );

      return Expanded(
          child: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return RawMaterialButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return (items[index].description == null)
                              ? ImagePage(
                                  '${items[index].baseUrl}', 'Sem Descição')
                              : ImagePage('${items[index].baseUrl}',
                                  '${items[index].description}');
                        }),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(
                              '${items[index].baseUrl}=w364'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ));
    }

    if (snapshot.hasError) {
      print(snapshot.error);
      return Container();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 200,
          ),
          Image(
            image: AssetImage('${ImagesPath.LOGO_WHITE}'),
            width: 250,
          ),
          CircularProgressIndicator(
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(MediaItem mediaItem) {
    return Column(
      children: <Widget>[
        Center(
          child: CachedNetworkImage(
            imageUrl: '${mediaItem.baseUrl}=w364',
            progressIndicatorBuilder: (context, url, downloadProgress) =>
                CircularProgressIndicator(value: downloadProgress.progress),
            errorWidget: (context, url, dynamic error) {
              print(error);
              return const Icon(Icons.error);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 2),
          width: 364,
          child: Text(
            mediaItem.description ?? '',
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}

class ContributePhotoResult {
  ContributePhotoResult(this.uploadToken, this.description);

  String uploadToken;
  String description;
}
