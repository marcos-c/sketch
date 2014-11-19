import 'dart:html';

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

void main() {
    useHtmlConfiguration();
    test('data-bind-text', () {
        var data = new ObservableMap.from({ 'text': 'Text' });
        var bind = new Template.bind('#test1', data);
        expect(querySelector('#test1 > p').innerHtml, equals('<span>Text</span>'));
        data['text'] = 'Text2';
        data.changes.listen((record) {
            expect(querySelector('#test1 > p').innerHtml, equals('<span>Text2</span>'));
        });
    });
    test('data-bind-style (String)', () {
        new Template.bind('#test2', {
            'style': 'color: red; background-color: black;'
        });
        expect(querySelector('#test2 > p').innerHtml, equals('<span style="color: red; background-color: black;"></span>'));
    });
    test('data-bind-style (Map)', () {
        new Template.bind('#test3', {
            'textColor': 'red',
            'backgroundColor': () => 'black'
        });
        expect(querySelector('#test3 > p').innerHtml, equals('<span style="color: red; background-color: black;"></span>'));
    });
    test('data-bind-attr', () {
        new Template.bind('#test4', {
            'action': '/list'
        });
        expect(querySelector('#test4 > p').innerHtml, equals('<a href="/list">Action</a>'));
    });
    test('data-bind-class', () {
        new Template.bind('#test5', {
            'isBox': true,
            'isHouse': () => false,
            'isTree': false
        });
        expect(querySelector('#test5 > p').innerHtml, equals('<span class="box">Action</span>'));
    });
    test('data-bind-visible', () {
        var data = { 'isMale': true };
        new Template.bind('#test6', data);
        expect(querySelector('#test6 > p > span').hidden, false);
    });
    test('data-bind-event', () {
        var data = {
            'click': (event) {
                querySelector('#test7 a').setInnerHtml('Clicked');
            }
        };
        new Template.bind('#test7', data);
        querySelector('#test7 a').click();
        expect(querySelector('#test7 a').innerHtml, equals('Clicked'));
    });
    test('data-bind-view', () { 
        var data = { 'router': new SimpleRouter([ new SimpleView('/index', 'view/test.html', new SimpleController({})) ]) };
        var bind = new Template.bind('#test8', data);
        expect(bind.future, completion(equals('<p>Test</p>')));
    });
    test('data-bind-foreach', () {
        var data = { 'list': [ { 'url': '/view_1', 'label': '/View 1' }, { 'url': '/view_2', 'label': '/View 2' }] };
        var bind = new Template.bind('#test9', data);
        expect(querySelector('#test9 ul').innerHtml, equals('<li><a href="/view_1">/View 1</a></li><li><a href="/view_2">/View 2</a></li>'));
    });
}