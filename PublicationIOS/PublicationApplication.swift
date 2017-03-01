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

import Alamofire
import Swinject
import Material

import RxSwift
 
@UIApplicationMain
class PublicationApplication: UIResponder, UIApplicationDelegate {
	
 	var window: UIWindow?;
	
	let cache = "defaults.json";
	
	let colorPrimary: UIColor			= Color.rgb(0x444444)//Color.indigo.base;
	let colorPrimaryDark: UIColor = Color.rgb(0x333333)//Color.indigo.darken2;
	let colorAccent: UIColor			= Color.pink.accent3;	
	
	let dispatchQueue = OperationQueue();
	
	// TODO change this in production
	static let isDebug = true;
	let bag = DisposeBag();
	
	fileprivate let injector: Container = AppComponent.scope;
 	
 	func applicationDidFinishLaunching(_ application: UIApplication) {
		
		dispatchQueue.maxConcurrentOperationCount = 3;
		
		/*let array = ["baker-framework-tutorial.hpub", "a-study-in-scarlet.hpub"];
		array.forEach { file in
			let fileManager = FileStorageImp();
			if let uri = fileManager.forDirectory(file) {
				if FileManager.default.fileExists(atPath: uri.path) {
					try? FileManager.default.removeItem(atPath: uri.path);
					print("\(uri.path) is deleted.");
				}
			}
		};*/
		
		/*forRead(named: cache)
			.observeOn(RxSchedulers.io)
			.map { json in
				Config(JSONString: json);
			}
			.subscribe { event in
				switch event {
				case .next(let config):
					if let version = config?.version {
						print("version is \(version)");
					}
				case .error(let error):
					print("error: \(error)");
				case .completed: break;
				}
		}.addDisposableTo(bag);*/
		
		BusManager.register { evt in
			if let event = evt as? ProgressEvent {
				print("\(event.url.lastPathComponent) has progress of: \((Float(event.persisted) / Float(event.total)) * 100)");
			} else if let event = evt as? FileChangeEvent {
				print("\(event.url) is completed");
			}
		}.addDisposableTo(bag);
		
		let service = BakerServiceImp();
		service.books()
			.flatMap({ (array: [Book]) -> Observable<Book> in Observable.from(array) })
			.observeOn(RxSchedulers.io)
			.subscribe { [weak weakSelf = self] (evt: Event<Book>) in
				switch evt {
				case .next(let book):
					weakSelf?.dispatchQueue.addOperation(DownloadMagazineJob(FileStorageImp(), book));
				default: break;
				}
			}
			/*.flatMap({ (book: Book) -> Observable<HTTPURLResponse> in
				if let url = book.url {
					return RxNet.request(.head, url);
				}
				return Observable.empty();
			})
			.observeOn(RxSchedulers.io)
			.subscribeOn(RxSchedulers.mainThread)
			.subscribe(onNext: { (httpResponse) in
				let fileSize = RangePart.toInt64(httpResponse.allHeaderFields["Content-Length"]);
				if let fileSize = fileSize {
					let parts = RangePart.toRangeParts(0, fileSize);
					parts.forEach { item in
						print("\(item)");
					};
				}
			})*/
			.addDisposableTo(bag);
		// TODO register components such as scheduler etc
		window = UIWindow(frame: Screen.bounds);
		// resolve injection
		// TODO change rootViewController with others
		// wrap it with Snackbar so we can use it later.
		window!.rootViewController = SnackbarController(rootViewController: ViewPagerController());
		window!.makeKeyAndVisible();
	}
	
	
	func forWrite(text: String, named: String) -> Observable<Bool> {
		if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let filePath = directory.appendingPathComponent(named);
			do {
				try text.write(to: filePath, atomically: false, encoding: .utf8);
				return Observable.just(true);
			} catch let error {
				return Observable.error(error);
			}
		}
		return Observable.just(false);
	}
	
	func forRead(named: String) -> Observable<String> {
		if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let filePath = directory.appendingPathComponent(named);
			do {
				return Observable.just(try String(contentsOf: filePath, encoding: .utf8));
			} catch let error {
				return Observable.error(error);
			}
		}
		return Observable.empty();
	}
	
}

//LogDelegate
extension PublicationApplication: LogDelegate {
	
	func isLogEnabled() -> Bool {
		return PublicationApplication.isDebug;
	}
	
	func getClassTag() -> String {
		return String(describing: PublicationApplication.self);
	}
}

//DependencyInjector
extension PublicationApplication {
	
	var dependencyInjector: Container {
		return self.injector;
	}
	
}

//Application Shared
extension UIViewController {
	
	func application() -> PublicationApplication? {
		return UIApplication.shared.delegate as? PublicationApplication;
	}
	
} 
