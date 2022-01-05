// Copyright (c) 2016-2021, TOPdesk. Please see the AUTHORS file for details.
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
    XmlAttribute(_name(name), '$value');

XmlText txt(String text) => XmlText(text);

String toXmlString(XmlDocument document) => document.toXmlString(
      pretty: true,
      preserveWhitespace: (XmlNode node) {
        if (node is! XmlElement) return false;
        return const [
          'system-out',
          'error',
          'failure',
        ].contains(node.name.local);
      },
    );

XmlName _name(String name) => XmlName.fromString(name);
