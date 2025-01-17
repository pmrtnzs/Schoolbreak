import 'package:flutter/material.dart';

class OnHoverButton extends StatefulWidget {
  final Widget child;

  const OnHoverButton({
    super.key,
    required this.child,
  });

  @override
  OnHoverButtonState createState() => OnHoverButtonState();
}

class OnHoverButtonState extends State<OnHoverButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context){
    return MouseRegion(
      onEnter: (event) => onEntered(true) ,
      onExit: (event) => onEntered(false),
      child: ColorFiltered(
        colorFilter: isHovered
          ? ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.srcATop)
          : const ColorFilter.mode(Colors.transparent, BlendMode.srcATop),
        child: widget.child
        )
      );
  }
  
  void onEntered(bool isHovered){
    setState(() {
      this.isHovered = isHovered;
    });
  }
}