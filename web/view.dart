import 'dart:html';

import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

void main() {
    var data = new ObservableMap.from({
        'router': new SimpleRouter([ 
            new SimpleView('/view_1', 'view/view_1.html', new SimpleController({})),
            new SimpleView('/view_2', 'view/view_2.html', new SimpleController({
                'list': [ { 'label': 'Element 1' }, { 'label': 'Element 2' } ]
            })),
            new SimpleView('/view_3', 'view/view_3.html', new SimpleController({}))
        ])
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