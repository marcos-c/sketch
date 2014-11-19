import 'dart:html';

import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

class View1Controller extends Controller {
    Map dataSource = {
        'list': [ { 'url': '/view_1', 'label': '/View 1' }, { 'url': '/view_2', 'label': '/View 2' } ]
    };
}

class View2Controller extends Controller {
    Map dataSource = {
        'list': [ { 'url': '/view_1', 'label': '/View 1' }, { 'url': '/view_2', 'label': '/View 2' } ]
    };
}

class View3Controller extends Controller {
    Map dataSource = {
        'list': [ { 'url': '/view_1', 'label': '/View 1' }, { 'url': '/view_2', 'label': '/View 2' } ]
    };
}

void main() {
    var data = new ObservableMap.from({
        'router': new SimpleRouter([ 
            new SimpleView('/view_1', 'view/view_1.html', new View1Controller()),
            new SimpleView('/view_2', 'view/view_2.html', new View2Controller()),
            new SimpleView('/view_3', 'view/view_3.html', new View3Controller())
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