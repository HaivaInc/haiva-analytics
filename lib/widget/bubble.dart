import 'package:flutter/material.dart';
import '../theme/colortheme.dart';

class BubbleWidget extends StatefulWidget {
  final Widget widget; // The child widget to be wrapped
  final IconButton? iconButton; // Optional icon button

  // Constructor to accept the child widget and an optional icon button
  BubbleWidget({required this.widget, this.iconButton});

  @override
  State<BubbleWidget> createState() => _BubbleWidgetState();
}

class _BubbleWidgetState extends State<BubbleWidget> with SingleTickerProviderStateMixin{


  @override
  void initState() {
    super.initState();



  }
  @override
  void dispose() {

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
 return Container(
        decoration: BoxDecoration(
          color: ColorTheme.primary.withOpacity(0.1),
          border: Border.all(
            color: ColorTheme.primary.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12) ,// Adjust padding as needed(12.0),

          child: Wrap(

            children: [
              widget.widget,
              if (widget.iconButton != null)
               widget.iconButton!,
            ],
          ),
        ),
      );
  }
}
