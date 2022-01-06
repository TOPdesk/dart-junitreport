dart ../bin/tojunit.dart -i example.jsonl -b "tool/example-tests" -t none > actual.xml
diff example.xml actual.xml
