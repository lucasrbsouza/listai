import 'dart:ffi';
import 'dart:io';

import 'package:sqlite3/open.dart';

// On Linux CI/dev machines, libsqlite3.so may not exist as an unversioned
// symlink. This helper configures sqlite3 to use the versioned library.
void configureSqliteForTests() {
  if (!Platform.isLinux) return;

  const candidates = [
    '/lib64/libsqlite3.so.0',
    '/usr/lib64/libsqlite3.so.0',
    '/usr/lib/x86_64-linux-gnu/libsqlite3.so.0',
    '/usr/lib/libsqlite3.so.0',
  ];

  for (final path in candidates) {
    if (File(path).existsSync()) {
      open.overrideForAll(() => DynamicLibrary.open(path));
      return;
    }
  }
}
