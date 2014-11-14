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

class Template {
    Future future;
    
    _parseParameters(String input, Map parameters, Function callback) {
        var pattern = new RegExp(r"^{");
        if (!pattern.hasMatch(input)) { // String
            callback(null, parameters[input]);
        } else { // Map
            pattern = new RegExp(r"(([\w-]*)\s*:\s*([\w-]*)),?\s*");
            var matches = pattern.allMatches(input); 
            matches.forEach((match) {
                if (parameters[match[3]] is Function) {
                    callback(match[2], parameters[match[3]]());                    
                } else {
                    callback(match[2], parameters[match[3]]);
                }
            });
        }
    }
    
    Template.bind(String selector, Map parameters) {
        var validator = new NodeValidatorBuilder.common()
            ..allowElement('a', attributes: ['href']);
        var root = querySelector(selector);
        root.querySelectorAll('[data-bind-text]').forEach((Element element) {
            element.text = parameters[element.dataset['bind-text']];
        });
        root.querySelectorAll('[data-bind-html]').forEach((Element element) {
            element.setInnerHtml(parameters[element.dataset['bind-text']]);
        });
        root.querySelectorAll('[data-bind-style]').forEach((Element element) {
            _parseParameters(element.dataset['bind-style'], parameters, (key, value) {
                if (key == null) {
                    element.setAttribute('style', value);
                } else {
                    element.style.setProperty(key, value);
                }
            });
            element.dataset.remove('bind-style');
        });
        root.querySelectorAll('[data-bind-attr]').forEach((Element element) {
            _parseParameters(element.dataset['bind-attr'], parameters, (key, value) {
                if (key != null) {
                    element.attributes[key] = value;
                }
            });
            element.dataset.remove('bind-attr');
        });
        root.querySelectorAll('[data-bind-class]').forEach((Element element) {
            _parseParameters(element.dataset['bind-class'], parameters, (key, value) {
                if (key != null && value) {
                    element.classes.add(key);                        
                }
            });
            element.dataset.remove('bind-class');
        });
        root.querySelectorAll('[data-bind-visible]').forEach((Element element) {
            element.hidden = !parameters[element.dataset['bind-visible']];
            element.dataset.remove('bind-visible');
        });
        root.querySelectorAll('[data-bind-event]').forEach((Element element) {
            // TODO implementation
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
        });
        root.style.display = 'block';
    }
}