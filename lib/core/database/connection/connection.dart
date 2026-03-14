// conditional import — compiler picks the right file per platform
export 'connection_native.dart' if (dart.library.html) 'connection_web.dart';
