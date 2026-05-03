import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyIcons {
  MyIcons._();

  static Widget diamond1({double? size, Color? color}) {
    return Builder(
      builder: (context) {
        final theme = IconTheme.of(context);
        final resolvedSize = size ?? theme.size ?? 24;
        final resolvedColor = color ?? theme.color ?? Colors.black;

        return SvgPicture.asset(
          'assets/icons/diamond1.svg',
          width: resolvedSize,
          height: resolvedSize,
          colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
        );
      },
    );
  }

  static Widget diamond2({double? size, Color? color}) {
    return Builder(
      builder: (context) {
        final theme = IconTheme.of(context);
        final resolvedSize = size ?? theme.size ?? 24;
        final resolvedColor = color ?? theme.color ?? Colors.black;

        return SvgPicture.asset(
          'assets/icons/diamond2.svg',
          width: resolvedSize,
          height: resolvedSize,
          colorFilter: ColorFilter.mode(resolvedColor, BlendMode.srcIn),
        );
      },
    );
  }
}
