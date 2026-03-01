{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  config: {
    // Usar CanvasKit desde el servidor local de Flutter (evita fetch a gstatic.com)
    canvasKitBaseUrl: "/canvaskit/",
  },
});
