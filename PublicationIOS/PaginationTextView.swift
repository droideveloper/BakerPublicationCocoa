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
import Core
import Material

class PaginationTextView: View {
	
	fileprivate var label: UILabel!;
	
	var text: String? {
		didSet {
			label.text = text;
		}
	}
	
	override func prepare() {
		super.prepare();
		self.backgroundColor = .white;
		self.shapePreset = .circle;
		
		label = UILabel(frame: .zero);
		label.textAlignment = .center;
		
		if let theme = application() {
			label.textColor = theme.colorPrimary;
		}
		label.text = "0";
		layout(label)
			.right()
			.centerVertically();
	}
	
	
	fileprivate func application() -> PublicationApplication? {
		return UIApplication.shared.delegate as? PublicationApplication;
	}
}
