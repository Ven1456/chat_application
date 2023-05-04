import 'package:chat/resources/widget.dart';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatefulWidget {
  final String image;

  const FullScreenImagePage({Key? key, required this.image}) : super(key: key);

  @override
  State<FullScreenImagePage> createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  @override
  @override
  void dispose() {
    _transformationController.value;
    super.dispose();
  }
  // void _handleDoubleTapDown(TapDownDetails details) {
  //   _doubleTapDetails = details;
  //   setState(() {});
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          sizeBoxH45(),
          Row(children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 10),
              child: backButton(
                  context: context,
                  onTap: () {
                    Navigator.pop(context);
                  }),
            ),
          ]),
          Expanded(
              child: Center(
            child: GestureDetector(
              onDoubleTap: _handleDoubleTap,
              onDoubleTapDown: _handleDoubleTapDown,
              child: InteractiveViewer(
                transformationController: _transformationController,
                maxScale: 5,
                minScale: 1,
                onInteractionStart: (val) {
                  setState(() {});
                },
                onInteractionEnd: (val) {
                  setState(() {});
                },
                child: SizedBox(
                  //   height: _transformationController.value != Matrix4.identity() ? 700: null,
                  child: Image.network(widget.image,
                      loadingBuilder: (context, child, loadingProcess) {
                        if (loadingProcess == null) {
                          return child;
                        } else {
                          return Image.asset(
                            ("assets/images/galley"),
                            filterQuality: FilterQuality.high,
                          );
                        }
                      },
                      errorBuilder: (_, a, b) => Image.asset(
                            ("assets/images/404.jpg"),
                            filterQuality: FilterQuality.high,
                          )),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
    setState(() {});
  }

  void _handleDoubleTap() {
    if (_transformationController.value != Matrix4.identity()) {
      _transformationController.value = Matrix4.identity();
      setState(() {});
    } else {
      final position = _doubleTapDetails?.localPosition;
      // // For a 3x zoom
      _transformationController.value = Matrix4.identity()
        ..translate(-position!.dx, -position.dy)
        ..scale(2.0);
      //   ..translate(-position!.dx * 2, -position.dy * 2)
      //   ..scale(3.0);
      setState(() {});
      // Fox a 2x zoom
      // ..translate(-position.dx, -position.dy)
      // ..scale(2.0);
    }
  }
}
