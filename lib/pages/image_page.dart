import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';

class ImagePage extends StatelessWidget {
  String urlImage;
  String? descricao;

  ImagePage(this.urlImage, this.descricao);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('${descricao}'),
        actions: [
          SizedBox(
            width: 40,
            child: IconButton(
              icon: Icon(Icons.share),
              onPressed: () {},
            ),
          ),
          SizedBox(
            width: 60,
            child: IconButton(
              icon: Icon(Icons.download),
              onPressed: () async {
                var fetchedFile =
                    await DefaultCacheManager().getSingleFile(urlImage);
                GallerySaver.saveImage(fetchedFile.toString());
                print('True');
                //await GallerySaver.saveImage(urlImage);
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: CachedNetworkImage(
          width: MediaQuery.of(context).size.width,
          imageUrl: '${urlImage}',
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
              child:
                  CircularProgressIndicator(value: downloadProgress.progress)),
          errorWidget: (context, url, dynamic error) {
            print(error);
            return const Icon(Icons.error);
          },
        ),
      ),
    );
  }
}
