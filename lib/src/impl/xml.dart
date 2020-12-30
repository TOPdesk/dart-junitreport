// Copyright (c) 2016-2019, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:xml/xml.dart';

XmlDocument doc(Iterable<XmlNode> children) => XmlDocument([
      XmlProcessing('xml', 'version="1.0" encoding="UTF-8"'),
      ...children,
    ]);

XmlElement elem(
  String name,
  Map<String, dynamic> attributes,
  Iterable<XmlNode> children,
) =>
    XmlElement(
      _name(name),
      attributes.entries.map<XmlAttribute>(
        (MapEntry<String, dynamic> e) => attr(e.key, e.value),
      ),
      children,
    );

XmlAttribute attr(String name, dynamic value) =>
    XmlAttribute(_name(name), value.toString());

XmlText txt(String text) => XmlText(text);

String toXmlString(XmlDocument document) {
  final result = document.toXmlString(
      pretty: true,
      preserveWhitespace: (XmlNode node) {
        if (node is! XmlElement) return false;
        return ['system-out', 'error', 'failure']
            .contains((node as XmlElement).name.local);
      },
    );
  // https://stackoverflow.com/questions/1176904/php-how-to-remove-all-non-printable-characters-in-a-string
  // 0x0d \r 0x0a \n
  return result.replaceAll(RegExp('[\x00-\x09\x0B-\x1F\x7F]'), '');
}

XmlName _name(String name) => XmlName.fromString(name);
