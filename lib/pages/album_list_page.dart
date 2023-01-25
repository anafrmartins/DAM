import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:sharing_codelab/pages/loading_page.dart';
import 'package:sharing_codelab/util/images_path.dart';

import '../components/primary_raised_button.dart';
import '../components/p2photos_app_bar.dart';
import '../model/photos_library_api_model.dart';
import '../photos_library_api/album.dart';
import 'create_album_page.dart';
import 'join_album_page.dart';
import 'photo_page.dart';
import '../util/dialog_helper.dart';

class AlbumListPage extends StatefulWidget {
  const AlbumListPage({super.key});

  @override
  State<AlbumListPage> createState() => _AlbumListPageState();
}

class _AlbumListPageState extends State<AlbumListPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  @override
  Widget build(BuildContext context) {
    List<Widget> _widgetOptions = <Widget>[
      _buildTripList(context),
      CreateAlbumPage(),
      JoinAlbumPage(),
      Text(
        'GALERIA',
        style: optionStyle,
      ),
      Text(
        'PESQUISAR',
        style: optionStyle,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const P2photosAppBar(),
      bottomNavigationBar: Container(
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: GNav(
            gap: 8,
            backgroundColor: Colors.blue,
            color: Colors.white,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.black26,
            padding: EdgeInsets.all(14),
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'HOME',
              ),
              GButton(
                icon: Icons.add,
                text: 'NOVO',
              ),
              GButton(
                icon: Icons.share,
                text: 'PARTILHAR',
              ),
            ],
            selectedIndex: _selectedIndex,
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
                print(_selectedIndex);
              });
            },
          ),
        ),
      ),
      body: _widgetOptions[_selectedIndex],
    );
    //
  }

  Widget _buildTripList(BuildContext context) {
    return ScopedModelDescendant<PhotosLibraryApiModel>(
      builder: (context, child, photosLibraryApi) {
        if (!photosLibraryApi.hasAlbums) {
          return LoadingPage();
        }

        // if (!photosLibraryApi.albums.isEmpty) {
        //   return GridView.builder(
        //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //           crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10),
        //       itemBuilder: (context, index) {
        //         return RawMaterialButton(
        //           onPressed: () {},
        //           child: Container(
        //             decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(10),
        //               image: DecorationImage(
        //                 image: NetworkImage(
        //                     'https://images.pexels.com/photos/13743847/pexels-photo-13743847.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),
        //                 fit: BoxFit.cover,
        //               ),
        //             ),
        //           ),
        //         );
        //       });
        // }

        if (photosLibraryApi.albums.isEmpty) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Image(
                image: AssetImage(ImagesPath.LOGO_WHITE),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "No momento, você não é membro de nenhum álbum de viagem. "
                  'Crie um novo álbum de P2PHOTOS ou junte-se a um existente abaixo.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
              _buildButtons(context, photosLibraryApi),
            ],
          );
        }

        // return ListView(
        //   children: [
        //     _buildButtons(context),
        //     Container(
        //       padding: EdgeInsets.all(15),
        //       child: GridView.builder(
        //           shrinkWrap: true,
        //           gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        //             crossAxisCount: 4,
        //             crossAxisSpacing: 10,
        //             mainAxisSpacing: 10,
        //           ),
        //           itemCount: photosLibraryApi.albums.length - 1,
        //           itemBuilder: (context, index) {
        //             return RawMaterialButton(
        //               onPressed: () {
        //                  Navigator.push(
        //                   context,
        //                   MaterialPageRoute<void>(
        //                     builder: (context) => TripPage(
        //                       album: sharedAlbum,
        //                       searchResponse: photosLibraryApi.searchMediaItems(sharedAlbum.id),
        //                     ),
        //                   ),
        //               },
        //               child: Container(
        //                 decoration: BoxDecoration(
        //                   borderRadius: BorderRadius.circular(10),
        //                   image: DecorationImage(
        //                     image: CachedNetworkImageProvider(
        //                         '${photosLibraryApi.albums[index].coverPhotoBaseUrl}=w346-h160-c'),
        //                     fit: BoxFit.cover,
        //                   ),
        //                 ),
        //               ),
        //             );
        //           }),
        //     ),
        //   ],
        // );

        return ListView.builder(
          itemCount: photosLibraryApi.albums.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildButtons(context, photosLibraryApi);
            }

            return _buildTripCard(
                context, photosLibraryApi.albums[index - 1], photosLibraryApi);
          },
        );
      },
    );
  }

  Widget _buildTripCard(BuildContext context, Album sharedAlbum,
      PhotosLibraryApiModel photosLibraryApi) {
    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 33,
      ),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (context) => PhotoPage(
              album: sharedAlbum,
              searchResponse: photosLibraryApi.searchMediaItems(sharedAlbum.id),
            ),
          ),
        ),
        child: Column(
          children: <Widget>[
            Container(
              child: _buildTripThumbnail(sharedAlbum, context),
            ),
            Container(
              height: 52,
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  (sharedAlbum.mediaItemsCount == null)
                      ? Text(
                          '0',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        )
                      : Text(
                          '${sharedAlbum.mediaItemsCount}',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                          ),
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  _buildSharedIcon(sharedAlbum),
                  Align(
                    alignment: const FractionalOffset(0, 0.5),
                    child: Text(
                      sharedAlbum.title ?? '[sem titulo]',
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripThumbnail(Album sharedAlbum, BuildContext context) {
    if (sharedAlbum.coverPhotoBaseUrl == null ||
        sharedAlbum.mediaItemsCount == null) {
      return Container(
        height: 180,
        color: Colors.grey[200],
        padding: const EdgeInsets.all(5),
        child: Image(image: AssetImage(ImagesPath.LOGO_WHITE)),
      );
    }
    print('Imagem');
    print(sharedAlbum.coverPhotoBaseUrl);
    return CachedNetworkImage(
      width: MediaQuery.of(context).size.width,
      imageUrl: '${sharedAlbum.coverPhotoBaseUrl}=w500-h220-c',
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
          child: CircularProgressIndicator(value: downloadProgress.progress)),
      errorWidget: (context, url, dynamic error) {
        print(error);
        return const Icon(Icons.error);
      },
    );
  }

  Widget _buildButtons(
      BuildContext context, PhotosLibraryApiModel photosLibraryApi) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'TODOS OS ALBUMS (${photosLibraryApi.albums.length})',
            style: TextStyle(fontSize: 25, color: Colors.black38),
          )
        ],
      ),
    );
    //   return Container(
    //     padding: const EdgeInsets.all(30),
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       crossAxisAlignment: CrossAxisAlignment.center,
    //       children: <Widget>[
    //         PrimaryRaisedButton(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute<void>(
    //                 builder: (context) => const CreateTripPage(),
    //               ),
    //             );
    //           },
    //           label: const Text('CRIAR NOVO ALBUM'),
    //         ),
    //         Container(
    //           padding: const EdgeInsets.only(top: 10),
    //           child: const Text(
    //             ' - Ou - ',
    //             style: TextStyle(
    //               color: Colors.grey,
    //               fontWeight: FontWeight.bold,
    //             ),
    //           ),
    //         ),
    //         TextButton(
    //           onPressed: () {
    //             Navigator.push(
    //               context,
    //               MaterialPageRoute<void>(
    //                 builder: (context) => const JoinTripPage(),
    //               ),
    //             );
    //           },
    //           child: const Text('PARTICIPE DE UM ALBUM P2PHOTOS'),
    //         ),
    //       ],
    //     ),
    //   );
  }

  Widget _buildSharedIcon(Album album) {
    if (album.shareInfo != null) {
      return const Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(
            Icons.folder_shared,
            color: Colors.blue,
          ));
    } else {
      return Container();
    }
  }
}
