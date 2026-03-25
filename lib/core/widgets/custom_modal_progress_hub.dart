// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';



class CustomModalProgressHUD extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  const CustomModalProgressHUD({
    Key? key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.5,
    this.color = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: inAsyncCall,
      opacity: opacity,
      progressIndicator: const CircularProgressIndicator(),
      color: color,
      child: child,
    );
  }
}

class   ModalProgressHUD extends StatelessWidget {
  final Widget child;
  final bool inAsyncCall;
  final double opacity;
  final Color color;
  const ModalProgressHUD({
    Key? key,
    required this.child,
    required this.inAsyncCall,
    this.opacity = 0.5,
    this.color = Colors.grey, required CircularProgressIndicator progressIndicator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!inAsyncCall) {
      return child;
    }
    return Stack(
      children: [
        child,
        Opacity(
          opacity: opacity,
          child: ModalBarrier(dismissible: false, color: color),
        ),
        const Center(
          child: CircularProgressIndicator(),
        ),
      ],
    );
  }
}