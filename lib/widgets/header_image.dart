import 'package:flutter/material.dart';
class HeaderImage extends StatelessWidget {
  const HeaderImage({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(20),
        child: Image.asset('assets/images/prisedenote.png', width: 800, height: 200, fit: BoxFit.cover,),
      ),
    );
  }
}