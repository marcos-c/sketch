import 'dart:html';

import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

void main() {
    var data = toObservable({
        'router': new SimpleRouter({ 
            '/view_1': 'view/view_1.html',
            '/view_2': 'view/view_2.html',
            '/view_3': 'view/view_3.html'
        })
    });
    new Template.bind('#view-container', data);
    querySelector('#view_1').onClick.listen((event) {
        data['router'].path = '/view_1';
    });
    querySelector('#view_2').onClick.listen((event) {
        data['router'].path = '/view_2';
    });
    querySelector('#view_3').onClick.listen((event) {
        data['router'].path = '/view_3';
    });
}