// Copyright (c) 2016, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:testreport/testreport.dart';
import 'package:junitreport/src/impl/report.dart';

abstract class JUnitReport {
  factory JUnitReport({String base, String package}) {
    return new XmlReport(base, package);
  }

  String toXml(Report report);
}
