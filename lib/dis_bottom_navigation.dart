library dis_bottom_navigation;

import 'package:flutter/material.dart';

class DisBottomNavigation extends StatefulWidget {
  final List<DisBottomNavigationBarItem> items;
  final Color activeColor;
  final Color color;

  const DisBottomNavigation(
      {Key key, @required this.items, this.activeColor, this.color})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DisBottomNavigation();
}

class _DisBottomNavigation extends State<DisBottomNavigation> {
  GlobalKey keyBottomBar = GlobalKey();
  double positionBase, differenceBase, leftPositionIndicator;
  int indexPage = 0;
  Color baseColor, activeColor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(afterLayout);
  }

  afterLayout(_) {
    baseColor = widget.color ?? Colors.black45;
    activeColor = widget.activeColor ?? Theme.of(context).primaryColor;
    final sizeBottomBar =
        (keyBottomBar.currentContext.findRenderObject() as RenderBox).size;
    positionBase = ((sizeBottomBar.width / widget.items.length));
    differenceBase = (positionBase - (positionBase / 2) + 2);
    setState(() {
      leftPositionIndicator = positionBase - differenceBase;
    });
  }

  @override
  Widget build(BuildContext context) => Container(
        child: Material(
          elevation: 10,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Stack(
              key: keyBottomBar,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 15, left: 60, right: 60),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: createNavigationIconList(widget.items.asMap()),
                  ),
                ),
                AnimatedPositioned(
                    child: Padding(
                      padding: EdgeInsets.only(left: 50, right: 50),
                      child: CircleAvatar(
                          radius: 2.5, backgroundColor: activeColor),
                    ),
                    duration: Duration(milliseconds: 400),
                    curve: Curves.fastLinearToSlowEaseIn,
                    left: leftPositionIndicator,
                    bottom: 0),
              ],
            ),
          ),
        ),
      );

  List<NavigationIconButton> createNavigationIconList(
      Map<int, DisBottomNavigationBarItem> mapItem) {
    List<NavigationIconButton> children = List<NavigationIconButton>();

    mapItem.forEach((index, item) => children.add(NavigationIconButton(
            item.icon,
            (index == indexPage) ? activeColor : baseColor,
            item.onTap, () {
          changeOptionBottomBar(index);
        })));
    return children;
  }

  void changeOptionBottomBar(int indexPageSelected) {
    if (indexPageSelected != indexPage) {
      setState(() {
        leftPositionIndicator =
            (positionBase * (indexPageSelected + 1)) - differenceBase;
      });
      indexPage = indexPageSelected;
    }
  }
}

class DisBottomNavigationBarItem {
  final IconData icon;
  final NavigationIconButtonTapCallback onTap;

  DisBottomNavigationBarItem({@required this.icon, this.onTap})
      : assert(icon != null);
}

typedef NavigationIconButtonTapCallback = void Function();

class NavigationIconButton extends StatefulWidget {
  final IconData icon;
  final Color colorIcon;
  final NavigationIconButtonTapCallback onTapInternalButton;
  final NavigationIconButtonTapCallback onTapExternalButton;

  const NavigationIconButton(this.icon, this.colorIcon,
      this.onTapInternalButton, this.onTapExternalButton,
      {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => NavigationIconButtonState();
}

class NavigationIconButtonState extends State<NavigationIconButton>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation scaleAnimation;
  double opacityIcon = 1;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    scaleAnimation = Tween<double>(begin: 1, end: 0.95).animate(controller);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) {
          controller.forward();
          setState(() {
            opacityIcon = 0.7;
          });
        },
        onTapUp: (_) {
          controller.reverse();
          setState(() {
            opacityIcon = 1;
          });
        },
        onTapCancel: () {
          controller.reverse();
          setState(() {
            opacityIcon = 1;
          });
        },
        onTap: () {
          widget.onTapInternalButton();
          widget.onTapExternalButton();
        },
        child: ScaleTransition(
          scale: scaleAnimation,
          child: AnimatedOpacity(
            opacity: opacityIcon,
            duration: Duration(milliseconds: 200),
            child: Icon(widget.icon, color: widget.colorIcon),
          ),
        ),
      );
}
