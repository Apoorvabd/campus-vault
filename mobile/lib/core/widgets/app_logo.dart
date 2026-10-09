import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Semester Forge brand. Use [AppLogo.mark] for small spots (top bars,
/// banners) and [AppLogo.full] for hero spots (splash, login, empty states).
class AppLogo extends StatelessWidget {
  const AppLogo.mark({super.key, this.height = 36})
    : _asset = 'assets/images/semesterforge_mark.svg';

  const AppLogo.full({super.key, this.height = 120})
    : _asset = 'assets/images/semesterforge_logo_full.svg';

  final double height;
  final String _asset;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(_asset, height: height);
  }
}
