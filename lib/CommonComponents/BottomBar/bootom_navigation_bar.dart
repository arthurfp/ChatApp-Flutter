import 'package:flutter/material.dart';
import 'package:chatapp/CommonComponents/BottomBar/bottom_curved_bar.dart';
import 'package:chatapp/CommonComponents/color.dart';

class BottomNavigation extends StatefulWidget {
  final Function(int) onIconPresed;
  BottomNavigation({Key key, this.onIconPresed}) : super(key: key);

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  AnimationController _xControl;
  AnimationController _yControl;
  @override
  void initState() {
    _xControl = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve);
    _yControl = AnimationController(vsync: this, animationBehavior: AnimationBehavior.preserve);

    Listenable.merge([_xControl, _yControl]).addListener(() {
      setState(() {});
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _xControl.value = _indexToPosition(_selectedIndex) / MediaQuery.of(context).size.width;
    _yControl.value = 1.0;

    super.didChangeDependencies();
  }

  double _indexToPosition(int index) {
    const buttonCount = 4.0;
    final appWidth = MediaQuery.of(context).size.width;
    final buttonsWidth = _getButtonContainerWidth();
    final startX = (appWidth - buttonsWidth) / 2;
    return startX + index.toDouble() * buttonsWidth / buttonCount + buttonsWidth / (buttonCount * 2.0);
  }

  @override
  void dispose() {
    _xControl.dispose();
    _yControl.dispose();
    super.dispose();
  }

  Widget _icon(IconData icon, bool isEnable, int index) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(50)),
        onTap: () {
          _handlePressed(index);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          alignment: isEnable ? Alignment.topCenter : Alignment.center,
          child: AnimatedContainer(
              height: isEnable ? 40 : 20,
              duration: Duration(milliseconds: 300),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: isEnable ? Colors.white : Colors.white,
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: isEnable ? bgcolors : Colors.white,
                      blurRadius: 50,
                      spreadRadius: 1,
                      offset: Offset(5, 5),
                    ),
                  ],
                  shape: BoxShape.circle),
              child: Opacity(
                opacity: isEnable ? _yControl.value : 1,
                child: Icon(icon, color: isEnable ? bgcolors : bgcolors),
              )),
        ),
      ),
    );
  }

  Widget _buildBackground() {
    final inCurve = ElasticOutCurve(0.38);
    return CustomPaint(
      painter: BackgroundCurvePainter(
          _xControl.value * MediaQuery.of(context).size.width,
          Tween<double>(
            begin: Curves.easeInExpo.transform(_yControl.value),
            end: inCurve.transform(_yControl.value),
          ).transform(_yControl.velocity.sign * 0.5 + 0.5),
          Colors.white),
    );
  }

  double _getButtonContainerWidth() {
    double width = MediaQuery.of(context).size.width;
    if (width > 400.0) {
      width = 400.0;
    }
    return width;
  }

  void _handlePressed(int index) {
    if (_selectedIndex == index || _xControl.isAnimating) return;
    widget.onIconPresed(index);
    setState(() {
      _selectedIndex = index;
    });

    _yControl.value = 1.0;
    _xControl.animateTo(_indexToPosition(index) / MediaQuery.of(context).size.width,
        duration: Duration(milliseconds: 620));
    Future.delayed(
      Duration(milliseconds: 500),
      () {
        _yControl.animateTo(1.0, duration: Duration(milliseconds: 1200));
      },
    );
    _yControl.animateTo(0.0, duration: Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    final appSize = MediaQuery.of(context).size;
    final height = 60.0;
    return Container(
      width: appSize.width,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            bottom: 0,
            width: appSize.width,
            height: height - 10,
            child: _buildBackground(),
          ),
          Positioned(
            left: (appSize.width - _getButtonContainerWidth()) / 2,
            top: 0,
            width: _getButtonContainerWidth(),
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _icon(Icons.home, _selectedIndex == 0, 0),
                _icon(Icons.chat, _selectedIndex == 1, 1),
                _icon(Icons.account_circle, _selectedIndex == 2, 2),
                _icon(Icons.settings, _selectedIndex == 3, 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
