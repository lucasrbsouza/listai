// Conditional export: rendering a photo from the local filesystem needs
// dart:io, which doesn't exist on the web build.
export 'local_photo_image_io.dart'
    if (dart.library.js_interop) 'local_photo_image_web.dart';
