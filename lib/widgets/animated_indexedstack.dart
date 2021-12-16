import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';

class AnimatedIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final int duration;
  final Function errorCallback;

  const AnimatedIndexedStack({
    Key key,
    @required this.index,
    @required this.children,
    @required this.duration,
    @required this.errorCallback,
  }) : super(key: key);

  @override
  _AnimatedIndexedStackState createState() => _AnimatedIndexedStackState();
}

class _AnimatedIndexedStackState extends State<AnimatedIndexedStack> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _animation;
  int _index;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.duration),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _index = widget.index;
    _controller.forward();
    super.initState();
  }

  @override
  void didUpdateWidget(AnimatedIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != _index) {
      _controller.reverse().then((_) {
        setState(() => _index = widget.index);
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.015 - (_controller.value * 0.015),
            child: child,
          );
        },
        child: IndexedStack(
          index: _index,
          children: widget.children,
        ),
      );
    } catch (e) {
      FirebaseCrashlytics.instance.log("PDA Crash at AnimatedIndexedStack. Children number: ${widget.children.length}. "
          "Index number: $_index. Error: ${e.toString()}");
      FirebaseCrashlytics.instance.recordError(e.toString(), null);
      if (widget.errorCallback != null) {
        widget.errorCallback();
      }
    }
    return SizedBox.shrink();
  }
}
