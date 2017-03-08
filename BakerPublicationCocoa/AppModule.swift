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
 
import Swinject
import PublicationCocoa

class AppModule: AppComponent {
	
	public static let shared: Container = {
		let module = AppModule();
		return module.component;
	}();
	
	override init() {
		super.init();
		self.component.register(BakerEndpointType.self) { r in
			return BakerEndpoint();
		}.inObjectScope(.container);
		self.component.register(DispatchQueue.self) { r in
			return DispatchQueue(label: "jobQueue", attributes: .concurrent);
		}.inObjectScope(.container);
		self.component.register(MainViewController.self) { r in
			return MainViewControllerImp();
		}.initCompleted{ (r, viewController) in
			if let viewController = viewController as? MainViewControllerImp {
				viewController.presenter = MainViewControllerPresenterImp(viewController);
			}
		}.inObjectScope(.graph);
	}
}
