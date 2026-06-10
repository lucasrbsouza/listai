// Conditional export: exporting writes temp files via dart:io, which doesn't
// exist on the web build (the export menu entry is hidden there).
export 'export_launcher_io.dart'
    if (dart.library.js_interop) 'export_launcher_web.dart';
