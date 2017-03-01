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

import Foundation
import Swinject

class AppComponent {
	
	static var scope: Container = {
		let scope = Container();
		// provide OperationQueue
		scope.register(OperationQueue.self) { _ in
			let queue = OperationQueue();
			queue.maxConcurrentOperationCount = 3;
			return queue;
		};
		// provide BakerService
		scope.register(BakerService.self) { _ in BakerServiceImp() };
		// provide FileStorage
		scope.register(FileStorage.self) { _ in FileStorageImp() };
		
		// register menuNavigationViewController
		scope.register(NavigationViewController.self) { _ in NavigationViewControllerImp() }
			.initCompleted { (injector, menuController) in
				let controller = menuController as! NavigationViewControllerImp;
				controller.presenter = injector.resolve(NavigationViewControllerPresenter.self);
		};
		// register menuNavigationViewControllerPresenter
		scope.register(NavigationViewControllerPresenter.self) { injector in
			NavigationViewControllerPresenterImp(injector.resolve(NavigationViewController.self)!);
		};
		// return parent scope		
		return scope;
	}();
	
}
