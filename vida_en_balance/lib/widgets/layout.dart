import 'package:flutter/material.dart';


/// Columna a pantalla completa que, si el contenido no cabe (pantallas
/// pequeñas o texto muy grande), se vuelve desplazable en vez de desbordar.
/// Los `Spacer` del hijo siguen funcionando cuando sobra espacio.
class ScrollableFill extends StatelessWidget {
  const ScrollableFill(
      {super.key, required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: padding,
        child: ConstrainedBox(
          constraints:
              BoxConstraints(minHeight: box.maxHeight - padding.vertical),
          child: IntrinsicHeight(child: child),
        ),
      ),
    );
  }
}
