// Copyright 2014 Marcos Cooper <marcos@releasepad.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

part of sketch;

/// Router interface for [Template] bind-view
abstract class Router extends Object with ChangeNotifier {
    var _path;
    
    @reflectable get path => _path;
    
    @reflectable set path(value) {
        _path = notifyPropertyChange(#path, _path, value);
        // TODO pushState only in main router
        window.history.pushState(null, '', value);
    }
    
    Map<String, View> _views;
    
    void addRule(View view) {
        if (_views == null) {
            _views = new Map();
        }
        _views[view.path] = view;
    }
    
    String get view => _views[path].view;
    
    Controller get controller => _views[path].controller;
}