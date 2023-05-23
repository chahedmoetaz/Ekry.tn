
import 'package:flutter/material.dart';
import 'package:tn/Screens/add.dart';
import 'package:tn/Screens/chat.dart';
import 'package:tn/Screens/dashboard.dart';
import 'package:tn/Screens/favorite.dart';
import 'package:tn/Screens/userScreen.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
 int currentTab =0;
 final List<Widget> screens=[
   HomePage(),
   FavoriteList(),
   Add(),
   Chat(),
   UserScreen(),
 ];

Widget currentScreen= HomePage();

final PageStorageBucket bucket = PageStorageBucket();


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      bottomNavigationBar: CurvedNavigationBar(
        index: 0,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.search, size: 30),
          Icon(Icons.favorite_border, size:30),
          Icon(Icons.add, size: 30),
          Icon(Icons.mail_outline, size: 30),
          Icon(Icons.perm_identity, size: 30),
        ],
        color: Theme.of(context).backgroundColor,

        buttonBackgroundColor: Theme.of(context).backgroundColor,
        backgroundColor: Theme.of(context).accentColor,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 500),
        onTap: (int index) {
          setState(() {
            if (index == 0) {
              currentScreen= HomePage();
              currentTab=0;              
            } else if (index == 1) {
              currentScreen= FavoriteList();
              currentTab=1;   
              
            } else if (index == 2) {
              currentScreen= Add();
              currentTab=2;   
              
            } else if(index == 3){
              currentScreen= Chat();
              currentTab=3;   
            }
            else{
              currentScreen= UserScreen();
              currentTab=4;   

            }


          });
        },
      ),

      body: Center(
        child: PageStorage(
          child: currentScreen,
          bucket: bucket,
        ),
      ),    

    );
  }
}

class CurvedNavigationBar extends StatefulWidget {
  final List<Widget> items;
  final int index;
  final Color color;
  final Color buttonBackgroundColor;
  final Color backgroundColor;
  final ValueChanged<int> onTap;
  final Curve animationCurve;
  final Duration animationDuration;
  final double height;

  CurvedNavigationBar({
    Key key,
    @required this.items,
    this.index = 0,
    this.color = Colors.white,
    this.buttonBackgroundColor,
    this.backgroundColor = Colors.blueAccent,
    this.onTap,
    this.animationCurve = Curves.easeOut,
    this.animationDuration = const Duration(milliseconds: 600),
    this.height = 75.0,
  })  : assert(items != null),
        assert(items.length >= 1),
        assert(0 <= index && index < items.length),
        assert(0 <= height && height <= 75.0),
        super(key: key);

  @override
  _CurvedNavigationBarState createState() => _CurvedNavigationBarState();
}

class _CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  double _startingPos;
  int _endingIndex = 0;
  double _pos;
  double _buttonHide = 0;
  Widget _icon;
  AnimationController _animationController;
  int _length;

  @override
  void initState() {
    super.initState();
    _icon = widget.items[widget.index];
    _length = widget.items.length;
    _pos = widget.index / _length;
    _startingPos = widget.index / _length;
    _animationController = AnimationController(vsync: this, value: _pos);
    _animationController.addListener(() {
      setState(() {
        _pos = _animationController.value;
        final endingPos = _endingIndex / widget.items.length;
        final middle = (endingPos + _startingPos) / 2;
        if ((endingPos - _pos).abs() < (_startingPos - _pos).abs()) {
          _icon = widget.items[_endingIndex];
        }
        _buttonHide =
            (1 - ((middle - _pos) / (_startingPos - middle)).abs()).abs();
      });
    });
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      final newPosition = widget.index / _length;
      _startingPos = _pos;
      _endingIndex = widget.index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      color: widget.backgroundColor,
      height: widget.height,
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            bottom: -40 - (75.0 - widget.height),
            left: Directionality.of(context) == TextDirection.rtl
                ? null
                : _pos * size.width,
            right: Directionality.of(context) == TextDirection.rtl
                ? _pos * size.width
                : null,
            width: size.width / _length,
            child: Center(
              child: Transform.translate(
                offset: Offset(
                  0,
                  -(1 - _buttonHide) * 80,
                ),
                child: Material(
                  color: widget.buttonBackgroundColor ?? widget.color,
                  type: MaterialType.circle,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _icon,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (75.0 - widget.height),
            child: CustomPaint(
              painter: NavCustomPainter(
                  _pos, _length, widget.color, Directionality.of(context)),
              child: Container(
                height: 75.0,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0 - (75.0 - widget.height),
            child: SizedBox(
                height: 100.0,
                child: Row(
                    children: widget.items.map((item) {
                      return NavButton(
                        onTap: _buttonTap,
                        position: _pos,
                        length: _length,
                        index: widget.items.indexOf(item),
                        child: item,
                      );
                    }).toList())),
          ),
        ],
      ),
    );
  }

  void _buttonTap(int index) {
    if (widget.onTap != null) {
      widget.onTap(index);
    }
    final newPosition = index / _length;
    setState(() {
      _startingPos = _pos;
      _endingIndex = index;
      _animationController.animateTo(newPosition,
          duration: widget.animationDuration, curve: widget.animationCurve);
    });
  }
}

class NavCustomPainter extends CustomPainter {
  double loc;
  double s;
  Color color;
  TextDirection textDirection;

  NavCustomPainter(
      double startingLoc, int itemsLength, this.color, this.textDirection) {
    final span = 1.0 / itemsLength;
    s = 0.2;
    double l = startingLoc + (span - s) / 2;
    loc = textDirection == TextDirection.rtl ? 0.8 - l : l;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo((loc - 0.1) * size.width, 0)
      ..cubicTo(
        (loc + s * 0.20) * size.width,
        size.height * 0.05,
        loc * size.width,
        size.height * 0.60,
        (loc + s * 0.50) * size.width,
        size.height * 0.60,
      )
      ..cubicTo(
        (loc + s) * size.width,
        size.height * 0.60,
        (loc + s - s * 0.20) * size.width,
        size.height * 0.05,
        (loc + s + 0.1) * size.width,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}


class NavButton extends StatelessWidget {
  final double position;
  final int length;
  final int index;
  final ValueChanged<int> onTap;
  final Widget child;

  NavButton({this.onTap, this.position, this.length, this.index, this.child});

  @override
  Widget build(BuildContext context) {
    final desiredPosition = 1.0 / length * index;
    final difference = (position - desiredPosition).abs();
    final verticalAlignment = 1 - length * difference;
    final opacity = length * difference;
    return Expanded(
      child: InkWell(
        onTap: () {
          onTap(index);
        },
        child: Container(
            height: 75.0,
            child: Transform.translate(
              offset: Offset(
                  0, difference < 1.0 / length ? verticalAlignment * 40 : 0),
              child: Opacity(
                  opacity: difference < 1.0 / length * 0.99 ? opacity : 1.0,
                  child: child),
            )),
      ),
    );
  }
}

