// Copyright (c) 2017-2021, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:args/args.dart';
import 'package:intl/intl.dart';
import 'package:junitreport/junitreport.dart';
import 'package:testreport/testreport.dart';

Future<void> main(List<String> args) async {
  final arguments = parseArguments(args);

  final lines = LineSplitter().bind(utf8.decoder.bind(arguments.source));
  try {
    final report = await createReport(arguments, lines);
    final xml = JUnitReport(base: arguments.base, package: arguments.package)
        .toXml(report);
    arguments.target.write(xml);
  } catch (e) {
    stderr.writeln(e.toString());
    exit(1);
  }
}

Future<Report> createReport(Arguments arguments, Stream<String> lines) async {
  final processor = Processor(timestamp: arguments.timestamp);
  await for (final line in lines) {
    if (!line.startsWith('{')) {
      continue;
    }
    processor.process(json.decode(line) as Map<String, dynamic>);
  }
  return processor.report;
}

Arguments parseArguments(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'input',
      abbr: 'i',
      help: """
the path to the 'json' file containing the output of 'pub run test'.
if missing, <stdin> will be used""",
    )
    ..addOption(
      'output',
      abbr: 'o',
      help: '''
the path of the to be generated junit xml file.
if missing, <stdout> will be used''',
    )
    ..addOption('base',
        abbr: 'b',
        help: "the part to strip from the 'path' elements in the source",
        defaultsTo: '')
    ..addOption(
      'package',
      abbr: 'p',
      help: "the part to prepend to the 'path' elements in the source",
      defaultsTo: '',
    )
    ..addOption(
      'timestamp',
      abbr: 't',
      help: """
the timestamp to be used in the report
- 'now' will use the current date/time
- 'none' will suppress timestamps altogether
- a date formatted 'yyyy-MM-ddThh:mm:ss' will be used as UTC date/time
- if no value is provided
    - if '--input' is specified the file modification date/time is used
    - otherwise the current date/time is used""",
    )
    ..addFlag(
      'help',
      abbr: 'h',
      help: 'display this help text',
      negatable: false,
      defaultsTo: false,
    );

  try {
    final result = parser.parse(args);
    if (result['help'] as bool) {
      print(parser.usage);
      exit(0);
    }

    final source = _processInput(result['input'] as String?);
    final target = _processOutput(result['output'] as String?);

    final timestamp = _processTimestamp(result['timestamp'] as String?, source);
    final package = _processPackage(result);
    return Arguments(
      source.source,
      target,
      timestamp,
      result['base'] as String,
      package,
    );
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    print('\nValid program arguments: ');
    print(parser.usage);
    exit(1);
  }
}

String _processPackage(ArgResults result) {
  final package = result['package'] as String;
  if (package.isEmpty || package.endsWith('.')) return package;
  return '$package.';
}

DateTime? _processTimestamp(String? timestamp, _Source source) {
  if (timestamp == null) {
    return source.timestamp;
  }
  if (timestamp == 'none') return null;
  if (timestamp == 'now') return DateTime.now();
  final format = DateFormat('yyyy-MM-ddTHH:mm:ss', 'en_US');
  try {
    return format.parseUtc(timestamp);
  } on FormatException {
    throw FormatException(
        "'timestamp' should be in the form 'yyyy-MM-ddTHH:mm:ss' UTC");
  }
}

_Source _processInput(String? input) {
  if (input == null) {
    return _Source(stdin, DateTime.now());
  }
  final file = File(input);
  if (!file.existsSync()) {
    stderr.writeln("File '$input' (${file.absolute.path}) does not exist");
    exit(1);
  }
  try {
    return _Source(
      file.openRead(),
      file.lastModifiedSync(),
    );
  } catch (e) {
    stderr.writeln("Cannot read file '$input' (${file.absolute.path})");
    exit(1);
  }
}

IOSink _processOutput(String? output) {
  if (output == null) return stdout;
  final file = File(output);
  try {
    return file.openWrite();
  } catch (e) {
    stderr.writeln("Cannot write to file '$output' (${file.absolute.path})");
    exit(1);
  }
}

class Arguments {
  final Stream<List<int>> source;
  final IOSink target;
  final DateTime? timestamp;
  final String base;
  final String package;

  Arguments(
    this.source,
    this.target,
    this.timestamp,
    this.base,
    this.package,
  );
}

class _Source {
  final Stream<List<int>> source;
  final DateTime timestamp;

  _Source(this.source, this.timestamp);
}
