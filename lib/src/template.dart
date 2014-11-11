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
        querySelectorAll('[data-bind-text]').forEach((Element element) {
            element.text = parameters[element.dataset['bind-text']];
        });
        querySelectorAll('[data-bind-foreach]').forEach((Element element) {
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
        querySelector(selector).style.display = 'block';
    }
}