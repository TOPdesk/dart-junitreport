// Copyright (c) 2016-2017, TOPdesk. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a MIT-style
// license that can be found in the LICENSE file.

import 'package:xml/xml.dart';
import 'package:xml/xml/visitors/pretty_writer.dart';

XmlDocument doc(Iterable<XmlNode> children) {
  return new XmlDocument([
    new XmlProcessing('xml', 'version="1.0" encoding="UTF-8"')
  ]..addAll(children));
}

XmlElement elem(
    String name, Map<String, dynamic> attributes, Iterable<XmlNode> children) {
  List<XmlAttribute> attrs = [];
  attributes.forEach((k, v) => attrs.add(attr(k, v)));
  return new XmlElement(_name(name), attrs, children);
}

XmlAttribute attr(String name, dynamic value) =>
    new XmlAttribute(_name(name), value.toString());

XmlText txt(String text) => new XmlText(text);

String toXmlString(XmlDocument document) {
  var buffer = new StringBuffer();
  document.accept(new XmlPrettyWriter(buffer, 0, '  '));
  return buffer.toString();
}

XmlName _name(String name) => new XmlName.fromString(name);
