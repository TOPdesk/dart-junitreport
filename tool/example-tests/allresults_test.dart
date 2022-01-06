// Copyright (c) 2016-2018, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:test/test.dart';

void main() {
  test('successful test', () {
    expect('', '');
  });

  test('successful test with output', () {
    print('a printed line');
    print('and another on printed line');
    print('and even\ntwo in one go');
    expect('', '');
  });

  test('output with control character ', () {
    print('a\t tab should be fine but bell not \u0008!');
    expect('', '');
  });

  test('failing test', () {
    expect('two\nlines that are not expected',
        'two\nlines for seeing how it is rendered');
  });

  test('failing test with reason', () {
    expect('fails', 'should fail', reason: 'the failure reason');
  });

  test('error in test', () {
    throw StateError('oops, it failed');
  });

  test('error test and failure', () {
    expect('actual1', 'expected1');
    throw ArgumentError('the error');
  });

  test('skipped top level test', () {}, skip: 'reason for skipping');

  print('a print outside any test');
}
