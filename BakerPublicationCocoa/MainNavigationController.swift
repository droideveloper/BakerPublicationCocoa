/*
 * BakerPublicationCocoa Copyright (C) 2017 Fatih.
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

import MVPCocoa
import Material
import UIKit

class MainNavigationController: NavigationController, LogType {
	// wrapped 4 layer in here
	static func create(viewController: UIViewController) -> SnackbarController {
		let statusController = MainStatusBarController(rootViewController: MainNavigationController(rootViewController: viewController));
		return SnackbarController(rootViewController: statusController);
	}
	
	override func prepare() {
		super.prepare();
		navigationBar.backgroundColor = application?.colorPrimary;
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}
	
	func getClassTag() -> String {
		return String(describing: MainNavigationController.self);
	}
}

class MainStatusBarController: StatusBarController, LogType {
	
	override func prepare() {
		super.prepare();
		statusBar.backgroundColor = application?.colorPrimaryDark;
		statusBarStyle = .lightContent;
	}
	
	func isLogEnabled() -> Bool {
		return BuildConfig.DEBUG;
	}
	
	func getClassTag() -> String {
		return String(describing: MainStatusBarController.self);
	}
}

