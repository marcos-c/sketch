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

/// Binding callback definition
///
/// Where [left_key] refers to the parameter key, [right_key] refers to the
/// key inside the data source and [value] refers to the value inside
/// the data source for the [right_key].
typedef BindingCallback(String left_key, String right_key, value);

/// Event callback with [router] definition
typedef EventCallback(Event event, Router router);

/// Event callback with [router] and [dataSource] definition
typedef EventWithDataCallback(Event event, Router router, Map dataSource);

/// This class provides an easy to use templating system with data bindings
///
/// Binding parameters are set throgh dataset attributes.
///
/// Data sources are set using [Map]s.
class Template {
    NodeValidatorBuilder _validator;

    Future future;

    /// Bind each parameter to it's data source
    void _bindParameters(String parameters, Map dataSource, BindingCallback callback, { expectFunction: false }) {
        var pattern = new RegExp(r"^{");
        if (!pattern.hasMatch(parameters)) {
            callback(null, parameters, dataSource[parameters]);
            if (dataSource is ObservableMap) {
                dataSource.changes.listen((record) {
                    if (record.first is PropertyChangeRecord) {
                        // TODO check why we get a PropertyChangeRecord the first time
                    } else if (record.first is MapChangeRecord) {
                        if (record.first.key == parameters) {
                            callback(null, parameters, dataSource[parameters]);
                        }
                    }
                });
            }
        } else {
            var left_key, right_key, value;
            pattern = new RegExp(r"(([\w-]*)\s*:\s*([\w-]*)),?\s*");
            var matches = pattern.allMatches(parameters);
            matches.forEach((match) {
                left_key = match[2];
                right_key = match[3];
                if (expectFunction) {
                    if (dataSource[match[3]] is Function) {
                        value = dataSource[match[3]];
                    } else {
                        throw new Exception('A function was expected');
                    }
                } else {
                    if (dataSource[match[3]] is Function) {
                        value = dataSource[match[3]]();
                    } else {
                        value = dataSource[match[3]];
                    }
                }
                callback(left_key, right_key, value);
                if (dataSource is ObservableMap) {
                    dataSource.changes.listen((record) {
                        if (record.first is PropertyChangeRecord) {
                            // TODO check why we get a PropertyChangeRecord the first time
                        } else if (record.first is MapChangeRecord) {
                            if (record.first.key == right_key) {
                                callback(left_key, right_key, record.first.newValue);
                            }
                        }
                    });
                }
            });
        }
    }

    /// Request an set the view router path
    void _requestView(Element element, Router router) {
        future = HttpRequest.getString(router.view)
            ..then((String fileContents) {
                element.children.clear();
                element.children.add(new Element.html(fileContents, validator: _validator));
                // Resolve all bindings inside the view
                new Template.bindContainer(element, router.controller.dataSource, router);
            })
            ..catchError((error) {
                print(error.toString());
            });
    }

    /// Resolve all bindings inside a container element
    Template.bindContainer(Element container, Map dataSource, [ Router router ]) {
        // Allow additional elements when adding new content to the DOM
        // TODO the validator should only be set once
        _validator = new NodeValidatorBuilder.common()
            ..allowElement('a', attributes: ['href'])
            ..allowElement('span', attributes: ['data-bind-text'])
            ..allowElement('button', attributes: ['data-bind-event'])
            ..allowElement('input', attributes: ['data-bind-attr'])
            ..allowElement('ul', attributes: ['data-bind-foreach']);
        // Bind each element of the datasource to the embedded HTML
        container.querySelectorAll('[data-bind-foreach]').forEach((Element element) {
            var innerHtml = element.innerHtml;
            element.children.clear();
            List list = dataSource[element.dataset['bind-foreach']];
            list.forEach((e) {
                var new_element = new Element.html(innerHtml, validator: _validator);
                if (e is Controller) {
                    new Template.bindContainer(new_element, e.dataSource, router);
                } else if (e is Map) {
                    new Template.bindContainer(new_element, e, router);
                }
                element.children.add(new_element);
            });
            element.dataset.remove('bind-foreach');
        });
        // Bind dataSource variables to element text values
        container.querySelectorAll('[data-bind-text]').forEach((Element element) {
            _bindParameters(element.dataset['bind-text'], dataSource, (left_key, right_key, value) {
                if (left_key == null) {
                    // Textarea onInput bind
                    if (element is TextAreaElement) {
                        element.value = value;
                        element.onKeyUp.listen((event) {
                            dataSource[right_key] = element.value;
                        });
                    } else {
                        element.text = value;
                    }
                }
            });
            element.dataset.remove('bind-text');
        });
        // Bind dataSource variables to element innerHtml values
        container.querySelectorAll('[data-bind-html]').forEach((Element element) {
            _bindParameters(element.dataset['bind-html'], dataSource, (left_key, right_key, value) {
                if (left_key == null) {
                    element.setInnerHtml(value);
                }
            });
            element.dataset.remove('bind-html');
        });
        // Bind dataSource variables to element style attribute values
        container.querySelectorAll('[data-bind-style]').forEach((Element element) {
            _bindParameters(element.dataset['bind-style'], dataSource, (left_key, rigth_key, value) {
                if (left_key == null) {
                    element.setAttribute('style', value);
                } else {
                    element.style.setProperty(left_key, value);
                }
            });
            element.dataset.remove('bind-style');
        });
        // Bind dataSource variables to element attributes
        container.querySelectorAll('[data-bind-attr]').forEach((Element element) {
            _bindParameters(element.dataset['bind-attr'], dataSource, (left_key, right_key, value) {
                if (left_key != null) {
                    // InputElement onInput bind
                    if (left_key == 'value' && element is InputElement) {
                        element.value = value;
                        element.onKeyUp.listen((KeyboardEvent event) {
                            dataSource[right_key] = element.value;
                        });
                    } else {
                        element.attributes[left_key] = value;
                    }
                }
            });
            element.dataset.remove('bind-attr');
        });
        // Bind dataSource variables to element class attribute values
        container.querySelectorAll('[data-bind-class]').forEach((Element element) {
            _bindParameters(element.dataset['bind-class'], dataSource, (left_key, right_key, value) {
                if (left_key != null && value) {
                    element.classes.add(left_key);
                }
            });
            element.dataset.remove('bind-class');
        });
        // Bind dataSource variables to element visibility
        container.querySelectorAll('[data-bind-visible]').forEach((Element element) {
            _bindParameters(element.dataset['bind-visible'], dataSource, (left_key, right_key, value) {
                if (left_key == null) {
                    element.hidden = !value;
                }
            });
            element.dataset.remove('bind-visible');
        });
        // Bind dataSource functions to element event handlers
        container.querySelectorAll('[data-bind-event]').forEach((Element element) {
            _bindParameters(element.dataset['bind-event'], dataSource, (left_key, right_key, value) {
                if (left_key != null) {
                    element.on[left_key].listen((event) {
                        if (value is EventCallback) {
                            value(event, router);
                        } else if (value is EventWithDataCallback) {
                            value(event, router, dataSource);
                        }
                    });
                }
            }, expectFunction: true);
            element.dataset.remove('bind-event');
        });
        // Bind router instances to elements that will act as view containers
        container.querySelectorAll('[data-bind-view]').forEach((Element element) {
            _bindParameters(element.dataset['bind-view'], dataSource, (left_key, right_key, viewRouter) {
               if (left_key == null) {
                   if (viewRouter is! Router) {
                        throw new Exception("A view needs a router");
                   }
                   _requestView(element, viewRouter);
                   viewRouter.changes.listen((record) {
                       _requestView(element, viewRouter);
                   });
                }
            });
            element.dataset.remove('bind-view');
        });
        // Show the container
        container.style.display = 'block';
    }

    /// Resolve all bindings inside a container element identified by a CSS selector
    Template.bind(String selector, Map dataSource) : this.bindContainer(querySelector(selector), dataSource);
}