# run from project root
dart test tool/example-tests --reporter json | sed 's_"[^"]*[/\]tool/_"ROOT/tool/_g' > tool/new-example.jsonl