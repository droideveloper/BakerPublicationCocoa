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
	
	// TODO change this in production
	static let isDebug = true;
	let bag = DisposeBag();
	
	fileprivate let injector: Container = Container();
 	
 	func applicationDidFinishLaunching(_ application: UIApplication) {
		
		PublicationApplication.shift(hex: 0xfff);
		//forWrite(text: "{ \"version\": 1 }", named: cache);
		
		if let versionStr = forRead(named: cache) {
			print("cache: \(versionStr)");
		}
		
		let service = BakerServiceImp();
		service.books()
			.observeOn(ConcurrentDispatchQueueScheduler(queue: DispatchQueue(label: "Schedulers.io", attributes: .concurrent)))
			.subscribe({ (event: Event<[Book]>) in
				switch event {
					case .next(let array):
						array.forEach({ (entry) in
							print("\(entry.name) as \(entry.title)");
						});
					case .error(let error):
						print("error: \(error)");
					case .completed:
						print("completed");
				}
			}).addDisposableTo(bag);
		
		// TODO register components such as scheduler etc.
		
		window = UIWindow(frame: Screen.bounds);
		
		// TODO change rootViewController with others
		window!.rootViewController = PublicationToolbarController(rootViewController: UIViewController());
		window!.makeKeyAndVisible();
	}
	
	
	func forWrite(text: String, named: String) -> Void {
		if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let filePath = directory.appendingPathComponent(named);
			do {
				try text.write(to: filePath, atomically: false, encoding: .utf8);
			} catch {
				print("error occured while trying to write");
			}
		}
	}
	
	func forRead(named: String) -> String? {
		if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let filePath = directory.appendingPathComponent(named);
			do {
				return try String(contentsOf: filePath, encoding: .utf8);
			} catch {
				print("error occured while trying to read");
			}
		}
		return nil;
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
	
	static func shift(hex: Int) -> Void {
		let r = (hex >> 4) & 0xFF;
		let g = (hex >> 0) & 0xFF;
		let b = hex & 0xFF;
		print("red: \(r) green: \(g) blue: \(b)");
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
