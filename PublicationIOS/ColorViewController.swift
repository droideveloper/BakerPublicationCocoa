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

class ColorViewController: UIViewController {
	
	var color: Int32?;
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let color = color {
			self.view.backgroundColor = UIColor.rgb(color);
		}
	}
	
	static func rgbControllers() -> [ColorViewController] {
		let red = ColorViewController();
		red.color = 0xFF0000;
		
		let green = ColorViewController();
		green.color = 0x00FF00;
		
		let blue = ColorViewController();
		blue.color = 0x0000FF;
		
		return [red, green, blue];
	}
}
