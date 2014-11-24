import 'dart:html';

import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

void main() {
    // Views and application bindings
    var list = [ { 'label': 'Element 1' }, { 'label': 'Element 2' } ];
    var data = new ObservableMap.from({
        'router': new SimpleRouter([ 
            new SimpleView('/view_1', 'view/view_1.html', new SimpleController({
                'list': list,
                'add': (Event event, Router router) {
                    router.path = '/add_view';
                    window.history.pushState(null, '', '#add_view');
                }
            })),
            new SimpleView('/add_view', 'view/add_view.html', new SimpleController({
                'name': 'Marcos',
                'save': (Event event, Router router, Map dataSource) {
                    list.add({ 'label': dataSource['name'] });
                    router.path = '/view_1';
                    window.history.pushState(null, '', '#view_1');
                }
            })),
            new SimpleView('/view_2', 'view/view_2.html', new SimpleController({})),
            new SimpleView('/view_3', 'view/view_3.html', new SimpleController({}))
        ])
    });
    new Template.bind('#view-container', data);
    // Navigation
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