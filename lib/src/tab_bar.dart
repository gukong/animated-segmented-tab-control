import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'tab.dart';

/// Widget based on [TabController]. Can simply replace [TabBar].
///
/// Requires [TabController], witch can be read from [context] with
/// [DefaultTabController] using. Or you can provide controller in the constructor.
class SegmentedTabControl extends StatefulWidget implements PreferredSizeWidget {
  const SegmentedTabControl({
    Key? key,
    this.height = 46,
    required this.tabs,
    this.controller,
    required this.textStyle,
    required this.selectedTextStyle,
    this.padding,
  }) : super(key: key);

  /// Height of the widget.
  ///
  /// [preferredSize] returns this value.
  final double height;

  /// Selection options.
  final List<SegmentTab> tabs;

  /// Can be provided by [DefaultTabController].
  final TabController? controller;

  /// Style of all labels. Color will not applied.
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;
  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;

  @override
  _SegmentedTabControlState createState() => _SegmentedTabControlState();

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class _SegmentedTabControlState extends State<SegmentedTabControl> with SingleTickerProviderStateMixin {
  Alignment _currentIndicatorAlignment = Alignment.centerLeft;
  late AnimationController _internalAnimationController;
  late Animation<Alignment> _internalAnimation;
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _internalAnimationController = AnimationController(vsync: this);
    _internalAnimationController.addListener(_handleInternalAnimationTick);
  }

  @override
  void dispose() {
    _internalAnimationController.removeListener(_handleInternalAnimationTick);
    _internalAnimationController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
  }

  @override
  void didUpdateWidget(SegmentedTabControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _updateTabController();
    }
  }

  bool get _controllerIsValid => _controller?.animation != null;

  void _updateTabController() {
    final TabController? newController = widget.controller ?? DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError(
          'No TabController for ${widget.runtimeType}.\n'
          'When creating a ${widget.runtimeType}, you must either provide an explicit '
          'TabController using the "controller" property, or you must ensure that there '
          'is a DefaultTabController above the ${widget.runtimeType}.\n'
          'In this case, there was neither an explicit controller nor a default controller.',
        );
      }
      return true;
    }());

    if (newController == _controller) {
      return;
    }

    if (_controllerIsValid) {
      _controller!.animation!.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = newController;
    if (_controller != null) {
      _controller!.animation!.addListener(_handleTabControllerAnimationTick);
    }
  }

  void _handleInternalAnimationTick() {
    setState(() {
      _currentIndicatorAlignment = _internalAnimation.value;
    });
  }

  void _handleTabControllerAnimationTick() {
    final currentValue = _controller!.animation!.value;
    _animateIndicatorTo(_animationValueToAlignment(currentValue));
  }

  TickerFuture _animateIndicatorTo(Alignment target) {
    _internalAnimation = _internalAnimationController.drive(AlignmentTween(
      begin: _currentIndicatorAlignment,
      end: target,
    ));

    return _internalAnimationController.fling();
  }

  Alignment _animationValueToAlignment(double? value) {
    if (value == null) {
      return const Alignment(-1, 0);
    }
    final inPercents = value / (_controller!.length - 1);
    final x = inPercents * 2 - 1;
    return Alignment(x, 0);
  }

  int get _internalIndex => _alignmentToIndex(_currentIndicatorAlignment);

  int _alignmentToIndex(Alignment alignment) {
    final currentPosition = (_controller!.length - 1) * _xToPercentsCoefficient(alignment);
    return currentPosition.round();
  }

  /// Converts [Alignment.x] value in range -1..1 to 0..1 percents coefficient
  double _xToPercentsCoefficient(Alignment alignment) {
    return (alignment.x + 1) / 2;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return SizedBox(
        height: widget.height,
        child: _Labels(
          callbackBuilder: _onTabTap(),
          tabs: widget.tabs,
          currentIndex: _internalIndex,
          textStyle: widget.textStyle,
          selectedTextStyle: widget.selectedTextStyle,
          padding: widget.padding,
        ),
      );
    });
  }

  VoidCallback Function(int)? _onTabTap() {
    if (_controller!.indexIsChanging) {
      return null;
    }
    return (int index) => () {
          _internalAnimationController.stop();
          _controller!.animateTo(index);
        };
  }
}

class _Labels extends StatelessWidget {
  const _Labels({
    Key? key,
    this.callbackBuilder,
    required this.tabs,
    required this.currentIndex,
    required this.textStyle,
    required this.selectedTextStyle,
    this.padding,
  }) : super(key: key);

  final VoidCallback Function(int index)? callbackBuilder;
  final List<SegmentTab> tabs;
  final int currentIndex;

  /// Style of all labels. Color will not applied.
  final TextStyle textStyle;
  final TextStyle selectedTextStyle;
  /// The amount of space to surround the child inside the bounds of the button.
  ///
  /// Defaults to 16.0 pixels.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        tabs.length,
        (index) {
          final tab = tabs[index];
          final isSelected = index == currentIndex;
          return CupertinoButton(
            padding: padding,
            onPressed: callbackBuilder?.call(index),
            child: AnimatedDefaultTextStyle(
              duration: kTabScrollDuration,
              curve: Curves.ease,
              style: isSelected ? selectedTextStyle : textStyle,
              child: Text(
                tab.label,
                overflow: TextOverflow.clip,
                maxLines: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
