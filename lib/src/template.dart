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
    Template.bind(selector, parameters) {
        var validator = new NodeValidatorBuilder.common()
            ..allowElement('a', attributes: ['href']);
        
        var root = querySelector(selector);
        
        root.querySelectorAll('[data-bind-text]').forEach((Element element) {
            element.text = parameters[element.dataset['bind-text']];
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
        root.querySelectorAll('[data-bind-html]').forEach((Element element) {
            // TODO implementation
        });
        root.querySelectorAll('[data-bind-style]').forEach((Element element) {
            var pattern = new RegExp(r"(([\w-]*)\s*:\s*([\w-]*)),?\s*");
            var matches = pattern.allMatches(element.dataset['bind-style']);
            var style = new List(); 
            matches.forEach((match) {
                var key = match[2];
                var value = match[3];
                if (parameters[match[3]] is Function) {
                    element.style.setProperty(match[2], parameters[match[3]]());
                } else {
                    element.style.setProperty(match[2], parameters[match[3]]);
                }
            });
            element.dataset.remove('bind-style');
            /* element.setAttribute('style', style.join(", ")); */
        });
        root.querySelectorAll('[data-bind-attr]').forEach((Element element) {
            // TODO implementation
        });
        root.querySelectorAll('data-bind-prop').forEach((Element element) {
            // TODO implementation
        });
        root.querySelectorAll('data-bind-class').forEach((Element element) {
            // TODO implementation
        });
        root.querySelectorAll('data-bind-visible').forEach((Element element) {
            // TODO implementation
        });
        root.querySelectorAll('data-bind-event').forEach((Element element) {
            // TODO implementation
        });
        root.style.display = 'block';
    }
}