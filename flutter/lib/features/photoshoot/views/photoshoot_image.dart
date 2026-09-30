import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/widgets/app_network_image.dart';
import '../../../core/widgets/app_ui.dart';
import '../models/photoshoot_models.dart';

/// A generated image from its inline payload or URL. The payload is decoded
/// once per image, not on every rebuild.
class PhotoshootImage extends StatefulWidget {
  const PhotoshootImage({super.key, required this.image, this.fit});

  final GeneratedImage image;
  final BoxFit? fit;

  @override
  State<PhotoshootImage> createState() => _PhotoshootImageState();
}

class _PhotoshootImageState extends State<PhotoshootImage> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _decode();
  }

  @override
  void didUpdateWidget(PhotoshootImage old) {
    super.didUpdateWidget(old);
    if (old.image.imageBase64 != widget.image.imageBase64) _decode();
  }

  void _decode() {
    final inline = widget.image.imageBase64;
    _bytes = null;
    if (inline == null || inline.isEmpty) return;
    try {
      _bytes = base64Decode(inline.split(',').last);
    } on FormatException {
      _bytes = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.image.imageUrl;
    final fit = widget.fit ?? BoxFit.cover;
    if (url != null && url.isNotEmpty) {
      return AppNetworkImage(
        url,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        errorWidget: (_, _, _) => _bytes == null
            ? const _Broken()
            : Image.memory(_bytes!, fit: fit, gaplessPlayback: true),
      );
    }
    if (_bytes != null) {
      return Image.memory(
        _bytes!,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => const _Broken(),
      );
    }
    return const _Broken();
  }
}

class _Broken extends StatelessWidget {
  const _Broken();

  @override
  Widget build(BuildContext context) {
    final tokens = PaperTokens.of(context);
    return ColoredBox(
      color: tokens.stock.sunk,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: tokens.textMuted,
          size: 28,
        ),
      ),
    );
  }
}
