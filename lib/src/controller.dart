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

/// Controller interface for [Template] bind-view
abstract class Controller {
    // TODO dataSource implementation should be private and have a better name
    ObservableMap dataSource;

    /// Default constructor
    Controller() {
        this.dataSource = new ObservableMap();
    }

    /// Build a new controller from an external dataSource
    Controller.from(Map dataSource) {
        this.dataSource = new ObservableMap.from(dataSource);
    }

    /// Binds a variable to the dataSource
    bind(String key, value) {
        dataSource[key] = value;
    }
}