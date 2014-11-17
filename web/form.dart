import 'dart:html';

import 'package:sketch/sketch.dart';
import 'package:observe/observe.dart';

void main() {
    var data = new ObservableMap.from({
        'name': 'Marcos',
        'surname': 'Cooper',
        'comments': null
    });
    var bind = new Template.bind('#user-form', data);
    querySelector('#change-name').onClick.listen((event) {
        data['name'] = 'Eli';
    });
    data.changes.listen((record) {
        print(record.first);
    });
}