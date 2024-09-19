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
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: Offset(-0.5, 0.0), // Starts off-screen to the left
      end: Offset(0.0, 0.0), // Ends at the final position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut, // You can customize this curve if needed
    ));

    _controller.forward();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
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
      ),
    );
  }
}
