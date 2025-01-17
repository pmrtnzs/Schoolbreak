import 'package:flutter/material.dart';


class OnHoverOptions extends StatefulWidget {
  final Widget child; // The main widget (e.g., image, button)
  final Widget overlayChild; // The overlay widget (e.g., text)

  const OnHoverOptions({
    super.key,
    required this.child,
    required this.overlayChild,
  });

  @override
  OnHoverOptionsState createState() => OnHoverOptionsState();
}

class OnHoverOptionsState extends State<OnHoverOptions> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) => onEntered(true),
      onExit: (event) => onEntered(false),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ColorFiltered(
            colorFilter: isHovered
                ? ColorFilter.mode(Colors.black.withOpacity(0.4), BlendMode.srcATop)
                : const ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
            child: widget.child,
          ),
          // The overlay child (e.g., text) that remains unaffected
          if (isHovered)
          widget.overlayChild,
        ],
      ),
    );
  }

  void onEntered(bool isHovered){
    setState(() {
      this.isHovered = isHovered;
    });
  }
}