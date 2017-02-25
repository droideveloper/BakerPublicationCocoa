/*
* Publication Copyright (C) 2017 Fatih.
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*      http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import UIKit
import Material

class NavigationController: UIViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		prepare();
	}
	
	open func prepare() {
		view = View(frame: .init(x: 0, y: 0, width: Screen.bounds.width, height: 150));
		if let theme = application() {
			view.backgroundColor = theme.colorAccent;
		}
	}
}
