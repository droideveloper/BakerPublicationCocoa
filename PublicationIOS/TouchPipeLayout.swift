/*
 * PublicationIOS Copyright (C) 2017 Fatih.
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

import RxSwift

class TouchPipeLayout: UIView, UIGestureRecognizerDelegate {
	
	let dispose		 = DisposeBag();
	let gesture		 = UITapGestureRecognizer(target: self, action: #selector(doubleTap));
	let dataSource = BehaviorSubject<Int>(value: 0);

	convenience init() {
		self.init(frame: .zero);
		self.gesture.delegate = self;
	}
	
	func doubleTap() {
		print("tap tap tap");
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		dataSource.on(.next(touch.tapCount));
		return false;
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true;
	}
}

