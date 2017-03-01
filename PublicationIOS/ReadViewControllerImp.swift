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
import Material

class ReadViewControllerImp: AbstractToolbarController<ReadViewControllerPresenter>,
	ReadViewController, LogDelegate {
	
	private var backButton: IconButton!;
	private var indicatorButton: IconButton!;
	private var progressView: UIActivityIndicatorView!;
	
	private var viewPager: UIPageViewController? {
		get {
			return rootViewController as? UIPageViewController;
		}
	}
	
	private var navigation: NavigationViewControllerImp? {
		get {
			for viewController in childViewControllers {
				if let viewController = viewController as? NavigationViewControllerImp {
					return viewController;
				}
			}
			return nil;
		}
	}
	
	private var shoudDisplayNav: Bool = false;
	
	convenience init(_ storage: FileStorage) {
		self.init(rootViewController: UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil));
		self.presenter = ReadViewControllerPresenterImp(self, storage);
	}
	
	override func prepare() {
		super.prepare();
		
		prepareToolbar();
		
		if let viewPager = viewPager {
			viewPager.dataSource = presenter?.dataSource;
			viewPager.delegate = presenter?.delegate;
		}
		
		progressView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge);
		if let theme = application() {
			progressView.color = theme.colorAccent;
		}
		// add center
		view.layout(progressView)
			.center();
	}
	
	
	
	func showNavigation() {
		if shoudDisplayNav {
			UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { [weak weakSelf = self] in
				if let viewToolbar = weakSelf?.toolbar, let viewNavigation = weakSelf?.navigation?.view {
					let diffToolbarY = (weakSelf?.statusBar.height ?? 0) + (weakSelf?.toolbar.height ?? 0);
					let diffNavigationY = (weakSelf?.navigation?.view?.height ?? 0);
					viewToolbar.topConstraint?.constant -= diffToolbarY;
					viewNavigation.topConstraint?.constant += diffNavigationY;
				}
			}, completion: { [weak weakSelf = self] _ in
				weakSelf?.shoudDisplayNav = false;
			});
		}
	}
	
	func hideNavigation() {
		if !shoudDisplayNav {
			UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { [weak weakSelf = self] in
				if let viewToolbar = weakSelf?.toolbar, let viewNavigation = weakSelf?.navigation?.view {
					let diffToolbarY = (weakSelf?.statusBar.height ?? 0) + (weakSelf?.toolbar.height ?? 0);
					let diffNavigationY = (weakSelf?.navigation?.view?.height ?? 0);
					viewToolbar.topConstraint?.constant += diffToolbarY;
					viewNavigation.topConstraint?.constant -= diffNavigationY;
				}
				}, completion: { [weak weakSelf = self] _ in
					weakSelf?.shoudDisplayNav = true;
			});
		}
	}
	
	func shouldShowNavigation() -> Bool {
		return shoudDisplayNav;
	}

	func setBookTitle(_ title: String?) {
		toolbar.title = title;
	}
	
	func addNavigationController(_ navigationUrl: URL?, _ contents: [String]?) {
		if let application = application() {
			if let navigationController = application.dependencyInjector.resolve(NavigationViewController.self) as? NavigationViewControllerImp {
				navigationController.presenter?.setIndexURL(navigationUrl);
				navigationController.presenter?.setContentStrings(contents);
				addChildViewController(navigationController);
				view.layout(navigationController.view)
					.bottom();
				navigationController.didMove(toParentViewController: self);
			}
		}
	}
	
	func setCurrentPage(_ index: Int) {
		if let dataSource = presenter?.dataSource as? ContentPagerAdapter{
			let viewController = dataSource.viewControllerAtIndex(index: index);
			if let viewController = viewController {
				viewPager?.setViewControllers([viewController], direction: .forward, animated: true, completion: nil);
			}
		}
	}
	
	func showProgress() {
		progressView?.startAnimating();
	}
	
	func hideProgress() {
		progressView?.stopAnimating();
	}
	
	func showError(_ error: String, action actionText: String?, completed on: (() -> Void)?) {
		if let snackbar = snackbarController?.snackbar {
			snackbar.text = error;
			if let str = actionText {
				let button = Flat(title: str, tintColor: Color.red.base, callback: on);
				button.addTarget(self, action: #selector(hideError), for: .touchUpInside);
				snackbar.rightViews = [button];
			}
			_ = snackbarController?.animate(snackbar: .visible);
			_ = snackbarController?.animate(snackbar: .hidden, delay: 5);
		}
	}
	
	@objc func hideError() {
		if let snackbar = snackbarController?.snackbar {
			snackbar.layer.removeAllAnimations();
		}
		_ = snackbarController?.animate(snackbar: .hidden);
	}
	
	func prepareToolbar() {
		if let theme = application() {
			statusBar.backgroundColor = theme.colorPrimaryDark;
			toolbar.backgroundColor = theme.colorPrimaryDark;
			
			toolbar.titleLabel.textColor = .white;
			indicatorButton = IconButton(title: "0", titleColor: .white);
			toolbar.rightViews = [indicatorButton];
			
			backButton = IconButton(image: Material.icon(.ic_arrow_back), tintColor: .white);
			backButton.addTarget(presenter, action: #selector(presenter?.backPressed), for: .touchUpInside);
			toolbar.leftViews = [backButton];
		}
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ReadViewControllerImp.self);
	}
}
