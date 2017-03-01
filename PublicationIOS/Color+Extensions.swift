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

extension Color {
	
	static func rgb(hex: Int32) -> Color? {
		let r = CGFloat((hex >> 16) & 0xFF) / 255.0;
		let g = CGFloat((hex >> 8)  & 0xFF) / 255.0;
		let b = CGFloat((hex & 0xFF)) / 255.0;
		return Color(red: r, green: g, blue: b, alpha: 1.0);
	}
	
	static func argb(hex: Int64) -> Color? {
		let a = CGFloat((hex >> 24) & 0xFF) / 255.0;
		let r = CGFloat((hex >> 16) & 0xFF) / 255.0;
		let g = CGFloat((hex >> 8)  & 0xFF) / 255.0;
		let b = CGFloat((hex & 0xFF)) / 255.0;
		return Color(red: r, green: g, blue: b, alpha: a);
	}
	
}
