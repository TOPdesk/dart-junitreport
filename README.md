JUnit Report
============

* [Introduction](#introduction)
* [Installation](#installation)
* [License and contributors](#license-and-contributors)

Introduction
------------

This application can be used to convert the results of dart tests to JUnit xml reports. These XML reports can then be used by other tools like Jenkins CI.

By running

```Shell
dart test simple_test.dart --reporter json > example.jsonl
dart pub global run junitreport:tojunit --input example.jsonl --output TEST-report.xml
```

and the contents of `simple_test.dart` is

```Dart
import 'package:test/test.dart';

main() {
  test('simple', () {
    expect(true, true);
  });
}
```
    
this program will generate 'TEST-report.xml' containing

```XML
<testsuites>
  <testsuite errors="0" failures="0" tests="1" skipped="0" name="simple" timestamp="2016-05-22T21:20:08">
    <properties>
      <property name="platform" value="vm" />
    </properties>
    <testcase classname="simple" name="simple" time="0.026" />
  </testsuite>
</testsuites>
```

For transforming Flutter tests reports, instead of passing `--reporter json`, you need to use `--machine`.

Installation
------------

Run `dart pub global activate junitreport` to download the program and make a launch script available: `<dart-cache>/bin/tojunit`.

If the `<dart-cache>/bin` directory is not on your path, you will get a warning, including tips on how to fix it.

Once the directory is on your path, `tojunit --help` should be able to run and produce the program help.

Then you can also use the example above much simpler:

```Shell
dart test simple_test.dart --reporter json | tojunit
```

And to run all tests for Flutter:

```Shell
flutter test --machine | tojunit
```

License and contributors
------------------------

* The MIT License, see [LICENSE](https://github.com/TOPdesk/dart-junitreport/raw/master/LICENSE).
* For contributors, see [AUTHORS](https://github.com/TOPdesk/dart-junitreport/raw/master/AUTHORS).
