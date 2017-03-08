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
 
import UIKit

import MVPCocoa
import Swinject
import Material
 
@UIApplicationMain
class BakerPublicationApplication: UIResponder, UIApplicationDelegate, 
	ApplicationType, LogType {
 	
 	var window: UIWindow?;
 	// Theme
 	var colorPrimary: UIColor			= Color.blueGrey.base;
	var colorPrimaryDark: UIColor = Color.blueGrey.darken2;
	var colorAccent: UIColor			= Color.pink.accent3;	
	// injector
	var component: Any = AppModule.shared;
	
 	func applicationDidFinishLaunching(_ application: UIApplication) {
		window = UIWindow(frame: Screen.bounds);
		if let component = component as? Container {
			if let viewController = component.resolve(MainViewController.self) as? MainViewControllerImp {
				window!.rootViewController = MainNavigationController.create(viewController: viewController);
			}
		}
		window!.makeKeyAndVisible();
	}

	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: BakerPublicationApplication.self);
	}
}
