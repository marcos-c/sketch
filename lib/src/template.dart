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

typedef TemplateCallback(String left_key, String right_key, String value);

class Template {
    Future future;
    
    _parseParameters(String input, Map parameters, TemplateCallback callback, { expectFunction: false }) {
        var pattern = new RegExp(r"^{");
        if (!pattern.hasMatch(input)) { // String
            callback(null, input, parameters[input]);
            if (parameters is ObservableMap) {
                parameters.changes.listen((record) {
                    if (record.first.key == input) {
                        callback(null, input, parameters[input]);
                    }
                });
            }
        } else { // Map
            var left_key, right_key, value;
            pattern = new RegExp(r"(([\w-]*)\s*:\s*([\w-]*)),?\s*");
            var matches = pattern.allMatches(input); 
            matches.forEach((match) {
                left_key = match[2];
                right_key = match[3];
                if (expectFunction) {
                    if (parameters[match[3]] is Function) {
                        value = parameters[match[3]];
                    } else {
                        throw new Exception('A function was expected');
                    }                    
                } else {
                    if (parameters[match[3]] is Function) {
                        value = parameters[match[3]]();
                    } else {
                        value = parameters[match[3]];
                    }
                }
                callback(left_key, right_key, value);
                if (parameters is ObservableMap) {
                    parameters.changes.listen((record) {
                        if (record.first.key == right_key) {
                            callback(left_key, right_key, record.first.newValue);
                        }
                    });
                }
            });
        }
    }
    
    Template.bind(String selector, Map parameters) {
        var validator = new NodeValidatorBuilder.common()
            ..allowElement('a', attributes: ['href']);
        var root = querySelector(selector);
        root.querySelectorAll('[data-bind-text]').forEach((Element element) {
            _parseParameters(element.dataset['bind-text'], parameters, (left_key, right_key, value) {
                if (left_key == null) {
                    // Textarea binding to parameters
                    if (element is TextAreaElement) {
                        element.value = value;
                        element.onInput.listen((event) {
                            parameters[right_key] = element.value;
                        });
                    } else {
                        element.text = value;
                    }
                }
            });
            element.dataset.remove('bind-text');
        });
        root.querySelectorAll('[data-bind-html]').forEach((Element element) {
            _parseParameters(element.dataset['bind-html'], parameters, (left_key, right_key, value) {
                if (left_key == null) {
                    element.setInnerHtml(value);                    
                }
            });
            element.dataset.remove('bind-html');
        });
        root.querySelectorAll('[data-bind-style]').forEach((Element element) {
            _parseParameters(element.dataset['bind-style'], parameters, (left_key, rigth_key, value) {
                if (left_key == null) {
                    element.setAttribute('style', value);
                } else {
                    element.style.setProperty(left_key, value);
                }
            });
            element.dataset.remove('bind-style');
        });
        root.querySelectorAll('[data-bind-attr]').forEach((Element element) {
            _parseParameters(element.dataset['bind-attr'], parameters, (left_key, right_key, value) {
                if (left_key != null) {
                    // InputElement with binding to parameters
                    if (left_key == 'value' && element is InputElement) {
                        element.value = value;
                        element.onInput.listen((event) {
                            parameters[right_key] = element.value;
                        });
                    } else {
                        element.attributes[left_key] = value;
                    }
                }
            });
            element.dataset.remove('bind-attr');
        });
        root.querySelectorAll('[data-bind-class]').forEach((Element element) {
            _parseParameters(element.dataset['bind-class'], parameters, (left_key, right_key, value) {
                if (left_key != null && value) {
                    element.classes.add(left_key);                        
                }
            });
            element.dataset.remove('bind-class');
        });
        root.querySelectorAll('[data-bind-visible]').forEach((Element element) {
            _parseParameters(element.dataset['bind-visible'], parameters, (left_key, right_key, value) {
                if (left_key == null) {
                    element.hidden = !value;
                }
            });
            element.dataset.remove('bind-visible');
        });
        root.querySelectorAll('[data-bind-event]').forEach((Element element) {
            _parseParameters(element.dataset['bind-event'], parameters, (left_key, right_key, value) {
                if (left_key != null) {
                    element.on[left_key].listen(value);
                }
            }, expectFunction: true);
            element.dataset.remove('bind-event');
        });
        root.querySelectorAll('[data-bind-foreach]').forEach((Element element) {
            var innerHtml = element.innerHtml;
            element.children.clear();
            List list = parameters[element.dataset['bind-foreach']];
            list.forEach((Map e) {
                var html = innerHtml.replaceAllMapped(new RegExp('\\\${([^}]*)}'), (match) {
                    if (e.containsKey(match[1])) {
                        return e[match[1]];
                    }
                });
                element.children.add(new Element.html(html, validator: validator));
            });
            element.dataset.remove('bind-foreach');
        });
        root.querySelectorAll('[data-bind-view]').forEach((Element element) {
            var viewRouter = parameters[element.dataset['bind-view']];
            if (viewRouter is! ViewRouter) {
                 throw new Exception("A view needs a router");
            }
            future = HttpRequest.getString(viewRouter.view)
                ..then((String fileContents) {
                    element.children.clear();
                    element.children.add(new Element.html(fileContents, validator: validator));
                })..catchError((error) {
                    print(error.toString());
                });
            element.dataset.remove('bind-view');
        });
        root.style.display = 'block';
    }
}