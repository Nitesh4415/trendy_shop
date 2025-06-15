import 'dart:io';

/// Reads a test fixture file from the `test/fixtures` directory.
///
/// Given a file name, this function constructs the full path to the file
/// and returns its content as a string.
String fixture(String name) => File('test/fixtures/$name').readAsStringSync();
