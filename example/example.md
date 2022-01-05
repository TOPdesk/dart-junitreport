# Example

```Shell
dart test simple_test.dart --reporter json > example.jsonl
dart pub global run junitreport:tojunit --input example.jsonl --output TEST-report.xml
```

or after running `dart pub global activate junitreport`:

```Shell
dart test simple_test.dart --reporter json | tojunit > TEST-report.xml
```

See `dart pub global run junitreport:tojunit --help` or simply `tojunit -h` for all supported command line flags. 