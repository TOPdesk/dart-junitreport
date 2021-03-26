// Copyright (c) 2017-2019, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:intl/intl.dart';
import 'package:junitreport/junitreport.dart';
import 'package:junitreport/src/impl/xml.dart';
import 'package:testreport/testreport.dart';
import 'package:xml/xml.dart';

class XmlReport implements JUnitReport {
  static final NumberFormat _milliseconds = NumberFormat('#####0.00#', 'en_US');
  static final DateFormat _dateFormat =
      DateFormat('yyyy-MM-ddTHH:mm:ss', 'en_US');
  static final Pattern _pathSeparator = RegExp(r'[\\/]');
  static final Pattern _dash = RegExp(r'-');
  static const Map<String, dynamic> _noAttributes = <String, dynamic>{};
  static const Iterable<XmlNode> _noChildren = <XmlNode>[];

  final String base;
  final String package;

  XmlReport(this.base, this.package);

  @override
  String toXml(Report report) {
    var suites = <XmlNode>[];
    for (var suite in report.suites) {
      var cases = <XmlNode>[];
      var prints = <XmlNode>[];
      var className = _pathToClassName(suite.path);

      for (var test in suite.allTests) {
        if (test.isHidden) {
          _prints(test.prints, prints);
          continue;
        }

        var children = <XmlNode>[];
        if (test.isSkipped) {
          children.add(elem('skipped', _noAttributes, _noChildren));
        }
        if (test.problems.isNotEmpty) children.add(_problems(test.problems));

        _prints(test.prints, children);

        cases.add(elem(
            'testcase',
            <String, dynamic>{
              'classname': className,
              'name': test.name,
              'time': _milliseconds.format((test.duration) / 1000.0)
            },
            children));
      }
      var attributes = <String, dynamic>{
        'errors': suite.problems
            .where((t) => !t.problems.every((p) => p.isFailure))
            .length,
        'failures': suite.problems
            .where((t) => t.problems.every((p) => p.isFailure))
            .length,
        'tests': suite.tests.length,
        'skipped': suite.skipped.length,
        'name': className
      };
      if (report.timestamp != null) {
        attributes['timestamp'] = _dateFormat.format(report.timestamp.toUtc());
      }
      suites.add(elem('testsuite', attributes,
          _suiteChildren(suite.platform, cases, prints)));
    }
    return toXmlString(doc([elem('testsuites', _noAttributes, suites)]));
  }

  String _pathToClassName(String path) {
    String main;
    if (path.endsWith('_test.dart')) {
      main = path.substring(0, path.length - '_test.dart'.length);
    } else if (path.endsWith('.dart')) {
      main = path.substring(0, path.length - '.dart'.length);
    } else {
      main = path;
    }

    if (base.isNotEmpty && main.startsWith(base)) {
      main = main.substring(base.length);
      while (main.startsWith(_pathSeparator)) {
        main = main.substring(1);
      }
    }
    return package +
        main.replaceAll(_pathSeparator, '.').replaceAll(_dash, '_');
  }

  List<XmlNode> _suiteChildren(
      String platform, Iterable<XmlNode> cases, Iterable<XmlNode> prints) {
    var properties =
        platform == null ? <XmlNode>[] : <XmlNode>[(_properties(platform))];
    return properties..addAll(cases)..addAll(prints);
  }

  void _prints(Iterable<String> from, List<XmlNode> to) {
    if (from.isNotEmpty) {
      to.add(
          elem('system-out', _noAttributes, <XmlNode>[txt(from.join('\n'))]));
    }
  }

  XmlElement _properties(String platform) =>
      elem('properties', _noAttributes, <XmlNode>[
        elem(
            'property',
            <String, dynamic>{'name': 'platform', 'value': platform},
            _noChildren)
      ]);

  XmlElement _problems(Iterable<Problem> problems) {
    if (problems.length == 1) {
      var problem = problems.first;
      var message = problem.message;
      if (message != null && !message.contains('\n')) {
        var stacktrace = problem.stacktrace;
        return elem(
            problem.isFailure ? 'failure' : 'error',
            <String, dynamic>{'message': message},
            stacktrace == null ? _noChildren : <XmlNode>[txt(stacktrace)]);
      }
    }

    var failures = problems.where((p) => p.isFailure);
    var errors = problems.where((p) => !p.isFailure);
    var details = <String>[
      ..._details(failures),
      ..._details(errors),
    ];

    var type = errors.isEmpty ? 'failure' : 'error';
    return elem(
        type,
        <String, dynamic>{'message': _message(failures.length, errors.length)},
        <XmlNode>[txt(details.join(r'\n\n\n'))]);
  }

  Iterable<String> _details(Iterable<Problem> problems) {
    final more = problems.length > 1;
    var count = 0;
    return problems.map((p) => _report(more, ++count, p));
  }

  String _report(bool more, int index, Problem problem) {
    var message = problem.message ?? '';
    var stacktrace = problem.stacktrace ?? '';
    var short = '';
    String long;
    if (message.isEmpty) {
      if (stacktrace.isEmpty) short = ' no details available';
    } else if (!message.contains('\n')) {
      short = ' $message';
    } else {
      long = message;
    }

    var report = <String>[];
    var type = problem.isFailure ? 'Failure' : 'Error';
    if (more) {
      report.add('$type #$index:$short');
    } else {
      report.add('$type:$short');
    }
    if (long != null) report.add(long);
    if (stacktrace.isNotEmpty) report.add('Stacktrace:\n$stacktrace');
    return report.join('\n\n');
  }

  String _message(int failures, int errors) {
    var texts = <String>[];
    if (failures == 1) texts.add('1 failure');
    if (failures > 1) texts.add('$failures failures');
    if (errors == 1) texts.add('1 error');
    if (errors > 1) texts.add('$errors errors');
    texts.add('see stacktrace for details');
    return texts.join(', ');
  }
}
