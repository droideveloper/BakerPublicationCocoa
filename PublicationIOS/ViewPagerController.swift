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
import RxSwift

class ViewPagerController: ToolbarController, LogDelegate,
	UIPageViewControllerDelegate, UIPageViewControllerDataSource {
	
	
	private var backButton: IconButton!;
	private var pageButton: IconButton!;
	
	private var contentNavigationController: NavigationViewControllerImp? {
		get {
			for controller in rootViewController.childViewControllers {
				if let controller = controller as? NavigationViewControllerImp {
					return controller;
				}
			}
			return nil;
		}
	}
	
	private var viewController: UIPageViewController? {
		get {
			return rootViewController as? UIPageViewController;
		}
	}
	
	var dataSet: [URL]?;
	var displayState: Bool = false;
	
	let dispose = DisposeBag();
	
	convenience init() {
		self.init(rootViewController: UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil));
	}
	
	override func prepare() {
		super.prepare();
		// set up color for Toolbar and StatusBar
		statusBar.backgroundColor = Color.blueGrey.darken2;
		toolbar.backgroundColor = Color.blueGrey.base;
		toolbar.titleLabel.textColor = .white;
		display = .full;		
		
		backButton = IconButton(image: Material.icon(.ic_arrow_back), tintColor: .white);
		toolbar.leftViews = [backButton];
		
		pageButton = IconButton(title: "0", titleColor: .white);
		toolbar.rightViews = [pageButton];
		
		if let viewController = viewController {
			viewController.dataSource = self;
			viewController.delegate = self;
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		if let injector = application()?.dependencyInjector {
			if let storage = injector.resolve(FileStorage.self) {
				if let directory = storage.forDirectory("a-study-in-scarlet") {
					let manager = FileManager.default;
					let indexUri = directory.appendingPathComponent("index.html");
					let index2Uri = directory.appendingPathComponent("index.htm");
					
					let str = try? String(contentsOf: directory.appendingPathComponent("book.json"), encoding: .utf8);
					if let str = str {
						let config = Config(JSONString: str);
						if let contents = config?.contents {
							if manager.fileExists(atPath: indexUri.path) {
								addContentNavigation(indexUri, contents);
							} else if manager.fileExists(atPath: index2Uri.path) {
								addContentNavigation(index2Uri, contents);
							}
							dataSet = contents.map({ path in
								return directory.appendingPathComponent(path);
							});
							if (dataSet?.size() ?? 0) > 0 {
								changePageAt(0);
							}
						}
						if let title = config?.title {
							toolbar.title = title;
						}
					}
				}
			}
		}
		BusManager.register(next: { [weak weakSelf = self] evt in
			if let event = evt as? PageSelectedByUri {
				let index = weakSelf?.dataSet?.index(of: event.uri) ?? -1;
				weakSelf?.changePageAt(index);
			} else if let _ = evt as? VisibilityChange {
				weakSelf?.toggleContentNavigation();
			}
		}).addDisposableTo(dispose);
		
		/*Observable<Int>.interval(5, scheduler: RxSchedulers.mainThread)
			.map{ _ in VisibilityChange() }
			.subscribe(onNext: { event in
				BusManager.post(event: event);
			}).addDisposableTo(dispose);*/
	}
	
	func changePageAt(_ index: Int) {
		if let viewController = viewController {
			var direction: UIPageViewControllerNavigationDirection = .forward;
			if let currentViewController = viewController.viewControllers?.last as? ContentViewControllerImp {
				if currentViewController.position == index {
					return;
				} else if (currentViewController.position ?? 0) < index {
					direction = .forward;
				} else {
					direction = .reverse;
				}
			}
			if let controller = viewControllerAt(index) {
				viewController.setViewControllers([controller], direction: direction, animated: true, completion: nil);
				if pageButton != nil {
					pageButton.title = "\(index + 1)";
				}
			}
		}
	}
	
	func toggleContentNavigation() {
		UIView.animate(withDuration: 0.3, delay: 0.0, animations: {
			self.toolbar.alpha = self.displayState ? 1.0 : 0.0;
		}, completion: { _ in
			self.toolbar.isHidden = self.displayState;
		});
		displayState = !displayState;
	}
	
	func addContentNavigation(_ indexUri: URL, _ contents: [String]) {
		let contentNavigationController = NavigationViewControllerImp(indexUri, contents);
		rootViewController?.addChildViewController(contentNavigationController);
		rootViewController?.view.layout(contentNavigationController.view)
			.bottom();
		contentNavigationController.didMove(toParentViewController: rootViewController);
		displayState = false;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? ContentViewControllerImp {
			let index = ((viewController.position ?? dataSet?.size() ?? 0) + 1);
			return viewControllerAt(index);
		}
		return nil;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		if let viewController = viewController as? ContentViewControllerImp {
			let index = ((viewController.position ?? 0) - 1);
			return viewControllerAt(index);
		}
		return nil;
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return dataSet?.size() ?? 0;
	}
	
	func viewControllerAt(_ index: Int) -> UIViewController? {
		if insideBounds(index) {
			return ContentViewControllerImp(index, dataSet?.get(index: index));
		}
		return nil;
	}
	
	func insideBounds(_ index: Int) -> Bool {
		return index >= 0 && index < (dataSet?.size() ?? 0);
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed && finished {
			if let viewController = pageViewController.viewControllers?.last as? ContentViewControllerImp {
				BusManager.post(event: PageSelectedByIndex(viewController.position ?? -1));
				pageButton.title = "\((viewController.position ?? 0) + 1)";
			}
		}
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ViewPagerController.self);
	}
}
