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

import RxSwift
import Core

class ReadViewControllerPresenterImp: AbstractPresenter<ReadViewController>,
	ReadViewControllerPresenter, LogDelegate, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
	
	var gesture: UIGestureRecognizerDelegate {
		get {
			return self;
		}
	}
	
	var delegate: UIPageViewControllerDelegate {
		get {
			return self;
		}
	}
	
	var dataSource: UIPageViewControllerDataSource {
		get {
			return contentPagerAdapter;
		}
	}
	
	let JSON		= "book.json";
	let INDEX		= "index.html";
	let INDEX2	= "index.htm";
	
	let dispose = DisposeBag();
	var storage: FileStorage;
	var contentPagerAdapter: ContentPagerAdapter;
	var directory: URL?;
	
	init(_ view: ReadViewController, _ storage: FileStorage) {
		self.contentPagerAdapter = ContentPagerAdapter();
		self.storage = storage;
		super.init(view);
	}
	
	override func viewDidLoad() {
		let manager = FileManager.default;
		directory = manager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("a-study-in-scarlet");
		
		view.showProgress();
		if let directory = directory {
			Observable.just(directory.appendingPathComponent(JSON))
				.map ({ uri -> Config? in self.storage.forRead(uri) })
			  .subscribeOn(RxSchedulers.io)
			  .observeOn(RxSchedulers.mainThread)
				.subscribe(onNext: { config in
					if let config = config {
						self.updateContents(config);
					}
				}, onError: { error in
					print("\(error.localizedDescription)");
				})
				.addDisposableTo(dispose);
		}
	}
	
	func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		if gestureRecognizer.isKind(of: UITapGestureRecognizer.self) {
			BusManager.post(event: VisibilityChange());
		}
		return true;
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		if completed && finished {
			if let contentViewController = pageViewController.viewControllers?.last as? ContentViewControllerImp {
				if let index = contentViewController.position {
					BusManager.post(event: PageSelectedByIndex(index));
				}
			}
		}
	}

	func updateContents(_ config: Config) {
		view.hideProgress();
		// get items
		if let contents = config.contents {
			let urls = contents.map { str -> URL in
				return directory!.appendingPathComponent(str);
			};
			contentPagerAdapter.dataSource = urls;
			view.setCurrentPage(0);
		}
		// set title if needed
		if let title = config.title {
			view.setBookTitle(title);
		}
		// we check if we need navigation
		if let indexUri = directory?.appendingPathComponent(INDEX),
			 let index2Uri = directory?.appendingPathComponent(INDEX2) {
			let manager = FileManager.default;
			if manager.fileExists(atPath: indexUri.path) {
				view.addNavigationController(indexUri, config.contents);
			} else if manager.fileExists(atPath: index2Uri.path) {
				view.addNavigationController(index2Uri, config.contents);
			}
		}
	}
	
	func backPressed() {
		
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ReadViewControllerPresenterImp.self);
	}
}
