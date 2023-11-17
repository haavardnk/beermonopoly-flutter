import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../providers/auth.dart';

class DrawerAvatarImage extends StatelessWidget {
  const DrawerAvatarImage({
    Key? key,
    required this.authData,
  }) : super(key: key);

  final Auth authData;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: authData.userAvatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
        backgroundColor: Colors.transparent,
        radius: 65,
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
