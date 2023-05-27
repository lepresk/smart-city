import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool _showCard = false;

  late AnimationController controller;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    final Animation<double> curve = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    scaleAnimation = Tween<double>(
      begin: 0,
      end: 1.0,
    ).animate(curve);

    controller.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        setState(() {
          _showCard = !_showCard;
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _toggleCard() {
    if (!_showCard) {
      setState(() {
        _showCard = !_showCard;
      });
      controller.forward();
    } else {
      controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          if (_showCard)
            GestureDetector(
              onTap: _toggleCard,
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedBuilder(
              animation: scaleAnimation,
              builder: (BuildContext context, Widget? child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    child: const SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Center(
                        child: Text("Card View"),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _showCard ? null : FloatingActionButton.extended(
        onPressed: _toggleCard,
        label: const Text("Publier"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
