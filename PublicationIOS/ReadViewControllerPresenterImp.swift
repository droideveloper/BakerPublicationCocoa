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
	
	let json = "book.json";
	let dispose = DisposeBag();
	var contentPagerAdapter: ContentPagerAdapter!;
	var directory: URL?;
	var book: Book?;
	
	init(_ view: ReadViewController, _ storage: FileStorage) {
		super.init(view);
		self.directory = storage.directory;
		self.contentPagerAdapter = ContentPagerAdapter();
		self.book = Book();
		self.book?.name = "a-study-in-scarlet";
		self.book?.title = "a Study in Scarlet";
	}
	
	override func viewDidLoad() {
		Observable.just(book)
			.flatMap { [weak weakSelf = self] entity -> Observable<URL> in
				if let entity = entity {
					if let directory = weakSelf?.directory, let json = weakSelf?.json, let unzip = entity.name {
						return Observable.just(directory.appendingPathComponent(unzip).appendingPathComponent(json));
					}
				}
				return Observable.empty();
			}.flatMap { uri -> Observable<Config> in
				if let str = try? String(contentsOf: uri, encoding: .utf8) {
					if let config = Config(JSONString: str) {
						return Observable.just(config);
					}
				}
				return Observable.empty();
			}
		 .subscribeOn(RxSchedulers.io)
		 .observeOn(RxSchedulers.mainThread)
		 .subscribe(onNext: { [weak weakSelf = self] (config: Config) in
				weakSelf?.updateContents(config);
			})
		 .addDisposableTo(dispose);
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
		contentPagerAdapter.dataSource = config.contents?.map { entry -> URL in
			return (directory?.appendingPathComponent(entry))!;
		};
		log(message: "content updated \(contentPagerAdapter.dataSource!)")
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ReadViewControllerPresenterImp.self);
	}
}
