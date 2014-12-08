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
    // Current path
    var _path;

    // True if this router is the main router
    bool pushState;

    // TODO this should be a rule container and not a view container
    Map<String, View> _views;

    /// Getter for the current path
    @reflectable get path => _path;

    /// Setter for the current path
    ///
    /// If this is the main router it also pushes state to the browser
    @reflectable set path(value) {
        _path = notifyPropertyChange(#path, _path, value);
        if (pushState == null || pushState) {
            window.history.pushState(null, '', value);
        }
    }

    /// Add a new path rule to the router
    ///
    void addRule(View view) {
        // TODO input is a view which is inconsistent with adding a rule, view should not contain the path
        if (_views == null) {
            _views = new Map();
        }
        _views[view.path] = view;
    }

    /// Get the current view
    ///
    /// The current view is resolved by checking all rules and returning the view associated to the current path
    String get view {
        for (View view in _views.values) {
            var pattern = new RegExp("^" + view.path.replaceAll('/', r'\/') + "\$");
            if (pattern.hasMatch(_path)) {
                return view.view;
            }
        }
        throw new Exception(_path);
    }

    /// Get the current controller
    ///
    /// Each view as a [Controller] or [Map] as dataSource
    Controller get controller {
        for (View view in _views.values) {
            var pattern = new RegExp("^" + view.path.replaceAll('/', r'\/') + "\$");
            if (pattern.hasMatch(_path)) {
                return view.controller;
            }
        }
        throw new Exception(_path);
    }
}