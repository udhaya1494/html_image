import 'package:flutter/material.dart';
import 'dart:ui_web' as ui;
import 'dart:html' as html;

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// Application itself.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter HTML Image',
      home: HomePage(),
    );
  }
}

/// [Widget] displaying the home page consisting of an image the the buttons.
class HomePage extends StatefulWidget {
  /// Constructs a [HomePage] widget.
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

/// State of a [HomePage].
class _HomePageState extends State<HomePage> {
  /// Text controller[_urlController] to manage the input URL for the image.
  final TextEditingController _urlController = TextEditingController();

  /// Stores the current image URL that will be displayed.
  String _imageUrl = '';

  /// Tracks whether the floating action menu is open.
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();

    // Registers a platform view for rendering the image in the web HTML context.
    ui.platformViewRegistry.registerViewFactory(
      'image-container',
      (int viewId) => _createHtmlElement(),
    );
  }

  /// Creates the HTML element that contains the image.
  ///
  /// Returns a [html.DivElement] that wraps the [html.ImageElement] for displaying the image.
  html.Element _createHtmlElement() {
    final div = html.DivElement();
    final img = html.ImageElement()
      ..id = 'displayed-image'
      ..src = _imageUrl
      ..style.cursor = 'pointer';

    // Enables fullscreen mode on double-clicking the image.
    img.onDoubleClick.listen((_) {
      html.document.documentElement?.requestFullscreen();
    });

    div.children.add(img);
    return div;
  }

  /// Updates the image by setting the [src] of the HTML image element to the entered URL.
  void _loadImage() {
    setState(() {
      _imageUrl = _urlController.text;
    });

    // Updates the image element in the DOM with the new URL.
    html.ImageElement? imgElement =
        html.document.getElementById('displayed-image') as html.ImageElement?;
    if (imgElement != null) {
      imgElement.src = _imageUrl;
    }
  }

  /// Toggles the visibility of the floating action button (FAB) menu.
  void _toggleMenu() {
    setState(() {
      _isMenuOpen = !_isMenuOpen;
    });
  }

  /// Enters fullscreen mode for the web page.
  void _enterFullscreen() {
    html.document.documentElement?.requestFullscreen();
    _toggleMenu();
  }

  /// Exits fullscreen mode for the web page.
  void _exitFullscreen() {
    html.document.exitFullscreen();
    _toggleMenu();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isMenuOpen) {
          _toggleMenu();
        }
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Stack(
          children: [
            if (_isMenuOpen) Container(color: Colors.black.withOpacity(.5)),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const HtmlElementView(viewType: 'image-container'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          enabled: !_isMenuOpen,
                          controller: _urlController,
                          decoration:
                              const InputDecoration(hintText: 'Image URL'),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _loadImage,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0, 12, 0, 12),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 64),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_isMenuOpen)
              Column(
                children: [
                  FloatingActionButton.extended(
                    heroTag: "enter_fullscreen",
                    onPressed: _enterFullscreen,
                    label: const Text("Enter Fullscreen"),
                    icon: const Icon(Icons.fullscreen),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    heroTag: "exit_fullscreen",
                    onPressed: _exitFullscreen,
                    label: const Text("Exit Fullscreen"),
                    icon: const Icon(Icons.fullscreen_exit),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            FloatingActionButton(
              onPressed: _toggleMenu,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
