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
import RxSwift
import Material

class PublicationToolbarController: ToolbarController, LogDelegate,
	UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	
	let disposes = DisposeBag();
	var contextView: UIView?;
	
	var isDisplay: Bool = false;
	
	var viewPager: UIPageViewController? {
		get {
			return rootViewController as? UIPageViewController;
		}
	}
	
	let dataSource = ColorViewController.rgbControllers();
	
	convenience init() {
		self.init(rootViewController: UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil));
	}
	
	override func prepare() {
		super.prepare();
		// setup toolbar
		if let theme = application() {
			statusBarStyle = .lightContent;
			
			statusBar.backgroundColor = theme.colorPrimaryDark;
			toolbar.backgroundColor = theme.colorPrimary;
			
			toolbar.titleLabel.font = RobotoFont.regular(with: 16);
		}
		
		toolbar.rightViews = [IconButton(title: "0", titleColor: UIColor.rgb(0xf5f5f5))];
		
		/*Observable.just(toolbar)
			.delay(5, scheduler: MainScheduler.instance)
			.subscribe(onNext: { [weak weakSelf = self] toolbar in
				weakSelf?.animateOut();
			}).addDisposableTo(disposes);*/
		
		if let injector = application()?.dependencyInjector {
			let context = injector.resolve(NavigationViewController.self) as! NavigationViewControllerImp;
			addChildViewController(context);
			view.layout(context.view)
				.bottom()
			context.didMove(toParentViewController: self);
			contextView = context.view;
		}
		
		// double tap recognition
		/*let recognizer = UITapGestureRecognizer(target: self, action: #selector(toggleInOut));
		recognizer.numberOfTapsRequired = 2;
		view.addGestureRecognizer(recognizer);
		
		log(message: "x:\(view.bounds.origin.x) y:\(view.bounds.origin.y)");*/
		if let viewPager = viewPager {
			viewPager.dataSource = self;
			viewPager.delegate = self;
			if let first = dataSource.first {
				viewPager.setViewControllers([first], direction: .forward, animated: true, completion: nil);
			}
		}
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? ColorViewController {
			let index = dataSource.index(of: viewController) ?? dataSource.size();
			if (index + 1) < dataSource.size() {
				return dataSource[index  + 1];
			}
		}
		return nil;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? ColorViewController {
			let index = dataSource.index(of: viewController) ?? 0;
			if (index - 1) >= 0 {
				return dataSource[index - 1];
			}
		}
		return nil;
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return dataSource.size();
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed && finished {
			if let viewController = pageViewController.viewControllers?.last as? ColorViewController {
				let index = dataSource.index(of: viewController) ?? -1;
				print("\(index)");
			}
		}
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
					weakSelf.toolbar.isHidden = true;
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
					weakSelf.toolbar.isHidden = false;
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
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: PublicationToolbarController.self);
	}
}
