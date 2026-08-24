import 'package:flutter/material.dart';

class Breakpoints {
  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;
}

class AppLayout {
  final Size size;

  const AppLayout(this.size);

  factory AppLayout.of(BuildContext context) =>
      AppLayout(MediaQuery.sizeOf(context));

  double get width => size.width;
  double get height => size.height;

  bool get isCompact => width < Breakpoints.compact;
  bool get isMedium =>
      width >= Breakpoints.compact && width < Breakpoints.expanded;
  bool get isExpanded => width >= Breakpoints.expanded;
  bool get useSidebar => width >= Breakpoints.medium;

  double get pagePadding => isExpanded ? 32 : (isMedium ? 24 : 16);

  double get contentMaxWidth {
    if (isExpanded) return 1280;
    if (isMedium) return 960;
    return width;
  }

  int gridColumns({
    int compact = 2,
    int medium = 3,
    int expanded = 4,
  }) {
    if (isExpanded) return expanded;
    if (isMedium) return medium;
    return compact;
  }

  int mediaColumns() {
    if (width >= 1400) return 8;
    if (isExpanded) return 6;
    if (useSidebar) return 5;
    if (width >= Breakpoints.compact) return 4;
    return 3;
  }

  /// Center child and clamp to [contentMaxWidth].
  Widget constrain(Widget child, {double? maxWidth}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? contentMaxWidth),
        child: child,
      ),
    );
  }
}

Future<T?> showAppSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  if (AppLayout.of(context).useSidebar) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: builder(ctx),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: builder,
  );
}
