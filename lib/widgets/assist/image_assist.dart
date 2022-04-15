// ignore_for_file: prefer_const_constructors

// import 'dart:io' as Io;
import 'dart:convert';

import 'package:flutter/material.dart';

class AvatarGeneratorNew extends StatefulWidget {
  final String base64Code;
  const AvatarGeneratorNew({Key? key, required this.base64Code})
      : super(key: key);

  @override
  State<AvatarGeneratorNew> createState() => _AvatarGeneratorNewState();
}

class _AvatarGeneratorNewState extends State<AvatarGeneratorNew> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all()
      ),
      child: ClipOval(
        child: Image(
          image: Image.memory(Base64Decoder().convert(widget.base64Code)).image,
        ),
      ),
    );
  }
}
