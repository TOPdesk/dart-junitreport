// Copyright (c) 2017, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:intl/intl.dart';
import 'package:junitreport/junitreport.dart';
import 'package:testreport/testreport.dart';

main(List<String> args) async {
  var arguments = parseArguments(args);

  Stream<String> lines =
      arguments.source.transform(UTF8.decoder).transform(new LineSplitter());

  try {
    var report = await createReport(arguments, lines);
    var xml = new JUnitReport(base: arguments.base, package: arguments.package)
        .toXml(report);
    arguments.target.write(xml);
  } catch (e) {
    stderr.writeln(e.toString());
    exit(1);
    return null; // satisfy code analyzers
  }
}

Future<Report> createReport(Arguments arguments, Stream<String> lines) async {
  var processor = new Processor(timestamp: arguments.timestamp);
  await for (String line in lines) processor.process(JSON.decode(line));
  return processor.report;
}

Arguments parseArguments(List<String> args) {
  var parser = new ArgParser()
    ..addOption('input',
        abbr: 'i',
        help: """
the path to the 'json' file containing the output of 'pub run test'.
if missing, stdin will be used""")
    ..addOption('output',
        abbr: 'o',
        help: """
the path of the to be generated junit xml file.
if missing, stdout will be used""")
    ..addOption('base',
        abbr: 'b',
        help: "the part to strip from the 'path' elements in the source",
        defaultsTo: '')
    ..addOption('package',
        abbr: 'p',
        help: "the part to prepend to the 'path' elements in the source",
        defaultsTo: '')
    ..addOption('timestamp',
        abbr: 't',
        help: """
the timestamp to be used in the report
- 'now' will use the current date/time
- 'none' will suppress timestamps altogether
- a date formatted 'yyyy-MM-ddThh:mm:ss' will be used as UTC date/time
- if no value is provided
    - if '-source' is specified the file modification date/time is used
    - otherwise the current date/time is used""")
    ..addFlag('help',
        abbr: 'h',
        help: 'display this help text',
        negatable: false,
        defaultsTo: false);

  try {
    var result = parser.parse(args);
    if (result['help']) {
      print(parser.usage);
      exit(0);
      return null; // satisfy code analyzers
    }

    var source = _processInput(result['input']);
    var target = _processOutput(result['output']);

    var timestamp = _processTimestamp(result['timestamp'], source);
    var package = _processPackage(result);
    return new Arguments()
      ..base = result['base']
      ..package = package
      ..timestamp = timestamp
      ..source = source.source
      ..target = target;
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    print('\nValid program arguments: ');
    print(parser.usage);
    exit(1);
    return null; // satisfy code analyzers
  }
}

String _processPackage(ArgResults result) {
  var package = result['package'];
  if (package.isNotEmpty && !package.endsWith('.')) package += '.';
  return package;
}

DateTime _processTimestamp(String timestamp, _Source source) {
  if (timestamp == null) {
    return source.timestamp;
  }
  if (timestamp == 'none') return null;
  if (timestamp == 'now') return new DateTime.now();
  var format = new DateFormat('yyyy-MM-ddTHH:mm:ss', 'en_US');
  try {
    return format.parseUtc(timestamp);
  } on FormatException {
    throw new FormatException(
        "'timestamp' should be in the form 'yyyy-MM-ddTHH:mm:ss' UTC");
  }
}

_Source _processInput(String input) {
  if (input == null) {
    return new _Source()
      ..source = stdin
      ..timestamp = new DateTime.now();
  }
  var file = new File(input);
  if (!file.existsSync()) {
    stderr.writeln("File '$input' (${file.absolute.path}) does not exist");
    exit(1);
    return null; // satisfy code analyzers
  }
  try {
    return new _Source()
      ..source = file.openRead()
      ..timestamp = file.lastModifiedSync();
  } catch (e) {
    stderr.writeln("Cannot read file '$input' (${file.absolute.path})");
    exit(1);
    return null; // satisfy code analyzers
  }
}

IOSink _processOutput(String output) {
  if (output == null) return stdout;
  var file = new File(output);
  try {
    return file.openWrite();
  } catch (e) {
    stderr.writeln("Cannot write to file '$output' (${file.absolute.path})");
    exit(1);
    return null; // satisfy code analyzers
  }
}

class Arguments {
  Stream<List<int>> source;
  IOSink target;
  DateTime timestamp;
  String base;
  String package;
}

class _Source {
  Stream<List<int>> source;
  DateTime timestamp;
}
