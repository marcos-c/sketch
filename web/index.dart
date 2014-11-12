import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:sketch/sketch.dart';

import 'dart:html';

void main() {
    useHtmlConfiguration();
    test('data-bind-text', () {
        new Template.bind('#test1', {
            'text': 'Text'
        });
        expect(querySelector('#test1 p').innerHtml, equals('Text: <span data-bind-text="text">Text</span>'));
    });
    test('data-bind-style', () {
        new Template.bind('#test2', {
            'style': 'color: red; background-color: black;'
        });
        expect(querySelector('#test2 p').innerHtml, equals('Text: <span style="color: red; background-color: black;"></span>'));
    });
    test('data-bind-style', () {
        new Template.bind('#test3', {
            'textColor': 'red',
            'backgroundColor': () => 'black'
        });
        expect(querySelector('#test3 p').innerHtml, equals('Text: <span style="color: red; background-color: black;"></span>'));
    });
}