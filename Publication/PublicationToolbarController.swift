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
import RxSwift
import Material

class PublicationToolbarController: ToolbarController {
	
	let disposes = DisposeBag();
	var contextView: UIView?;
	
	var isDisplay: Bool = false;
	
	override func prepare() {
		super.prepare();
		// setup toolbar
		if let theme = application() {
			statusBarStyle = .lightContent;
			
			statusBar.backgroundColor = theme.colorPrimaryDark;
			toolbar.backgroundColor = theme.colorPrimary;
			
			toolbar.titleLabel.font = RobotoFont.regular(with: 16);
		}
		
		toolbar.rightViews = [PaginationTextView(frame: .init(x: 0, y: 0, width: 32, height: 32))];
		
		Observable.just(toolbar)
			.delay(5, scheduler: MainScheduler.instance)
			.subscribe(onNext: { [weak weakSelf = self] toolbar in
				weakSelf?.animateOut();
			}).addDisposableTo(disposes);
		
		let context = NavigationController();
		addChildViewController(context);
		view.layout(context.view)
			.bottom()
		context.didMove(toParentViewController: self);
		contextView = context.view;
		// double tap recognition
		let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleInOut));
		recognizer.numberOfTapsRequired = 2;
		view.addGestureRecognizer(recognizer);
	}
	
	func animateOut() -> Void {
		UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseOut, animations: { [weak weakSelf = self] in
			if let weakSelf = weakSelf {
				let diffY = weakSelf.statusBar.height + weakSelf.toolbar.height;
				weakSelf.toolbar.y -= diffY;
				if let view = weakSelf.contextView {
					view.y += view.height;
				}
				weakSelf.view.layoutIfNeeded();
			}
			}, completion: { [weak weakSelf = self] (completed: Bool) in
				if let weakSelf = weakSelf {
					weakSelf.isDisplay = true;
				}
		});
	}
	
	func animateIn() -> Void {
		UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: { [weak weakSelf = self] in
			if let weakSelf = weakSelf {
				let diffY = weakSelf.statusBar.height + weakSelf.toolbar.height;
				weakSelf.toolbar.y += diffY;
				if let view = weakSelf.contextView {
					view.y -= view.height;
				}
				weakSelf.view.layoutIfNeeded();
			}
			}, completion: { [weak weakSelf = self] (completed: Bool) in
				if let weakSelf = weakSelf {
					weakSelf.isDisplay = false;
				}
		});
	}
	
	func toggleInOut() -> Void {
		if isDisplay {
			animateIn();
		} else {
			animateOut();
		}
	}
}
