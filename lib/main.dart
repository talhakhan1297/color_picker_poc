// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:palette_generator/palette_generator.dart';

void main() => runApp(const MyApp());

const Color _kBackgroundColor = Color(0xffa0a0a0);
const Color _kSelectionRectangleBackground = Color(0x15000000);
const Color _kSelectionRectangleBorder = Color(0x80000000);

/// The main Application class.
class MyApp extends StatelessWidget {
  /// Creates the main Application class.
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Colors',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const ImageColors(
        title: 'Image Colors',
        image: AssetImage('assets/landscape.png'),
        imageSize: Size(256.0, 170.0),
      ),
    );
  }
}

/// The home page for this example app.
@immutable
class ImageColors extends StatefulWidget {
  /// Creates the home page.
  const ImageColors({
    Key? key,
    this.title,
    required this.image,
    this.imageSize,
  }) : super(key: key);

  /// The title that is shown at the top of the page.
  final String? title;

  /// This is the image provider that is used to load the colors from.
  final ImageProvider image;

  /// The dimensions of the image.
  final Size? imageSize;

  @override
  _ImageColorsState createState() {
    return _ImageColorsState();
  }
}

class _ImageColorsState extends State<ImageColors> {
  Rect? region;
  PaletteGenerator? paletteGenerator;

  final GlobalKey imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.imageSize != null) {
      region = Offset.zero & widget.imageSize!;
    }
    _updatePaletteGenerator(region);
  }

  Future<void> _updatePaletteGenerator(Rect? newRegion) async {
    paletteGenerator = await PaletteGenerator.fromImageProvider(
      widget.image,
      size: widget.imageSize,
      region: newRegion,
      maximumColorCount: 1,
    );
    setState(() {});
  }

  Future<void> _onTapDown(TapDownDetails details) async {
    final Size? imageSize = imageKey.currentContext?.size;
    Rect? newRegion;

    final firstCorner = details.localPosition;
    final secondCorner = Offset(firstCorner.dx + 5, firstCorner.dy + 5);
    region = Rect.fromPoints(firstCorner, secondCorner);

    if (imageSize != null) {
      newRegion = (Offset.zero & imageSize).intersect(region!);
      if (newRegion.size.width < 4 && newRegion.size.width < 4) {
        newRegion = Offset.zero & imageSize;
      }
    }

    await _updatePaletteGenerator(newRegion);
    setState(() {
      region = newRegion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            // GestureDetector is used to handle the selection rectangle.
            child: GestureDetector(
              onTapDown: _onTapDown,
              child: Stack(children: <Widget>[
                Image(
                  key: imageKey,
                  image: widget.image,
                  width: widget.imageSize?.width,
                  height: widget.imageSize?.height,
                ),
                // This is the selection rectangle.
                Positioned.fromRect(
                    rect: region ?? Rect.zero,
                    child: Container(
                      decoration: BoxDecoration(
                          color: _kSelectionRectangleBackground,
                          border: Border.all(
                            width: 1.0,
                            color: _kSelectionRectangleBorder,
                            style: BorderStyle.solid,
                          )),
                    )),
              ]),
            ),
          ),
          if (paletteGenerator != null && paletteGenerator!.colors.isNotEmpty)
            Center(
              child: Container(
                color: paletteGenerator!.colors.first,
                width: 34.0,
                height: 20.0,
              ),
            ),
        ],
      ),
    );
  }
}
