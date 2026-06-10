// Conditional export: native platforms persist photos via dart:io; the web
// build gets a stub so the app compiles (photo capture is hidden on web).
export 'photo_repository_io.dart'
    if (dart.library.js_interop) 'photo_repository_web.dart';
