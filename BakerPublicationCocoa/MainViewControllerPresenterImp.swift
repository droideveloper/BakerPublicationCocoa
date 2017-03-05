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
import RxSwift
import Swinject
import PublicationCocoa

class MainViewControllerPresenterImp: AbstractPresenter<MainViewController>,
	MainViewControllerPresenter, LogType, UITableViewDelegate {
	
	let dispose = DisposeBag();
	let bookAdapter = BookAdapter();
	
	var dataSource: UITableViewDataSource {
		get {
			return self.bookAdapter;
		}
	}
	
	var delegate: UITableViewDelegate {
		get {
			return self;
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		if let navigationViewController = view?.navigationController {
			navigationViewController.setNavigationBarHidden(false, animated: animated);
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		if let navigationViewController = view?.navigationController {
			navigationViewController.setNavigationBarHidden(true, animated: animated);
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		view?.showProgress();
		if let application = view?.application {
			if let dependencyInjector = application.dependencyInjector as? Container {
				if let bakerEndpoint = dependencyInjector.resolve(BakerEndpointType.self) {
					bakerEndpoint.books()
						.bindTo(bookAdapter.dataSourceObserver)
						.addDisposableTo(dispose);
				}
			}
		}
		BusManager.register(next: { [unowned self] evt in
			if let _ = evt as? BookAdapterChangeEvent {
				self.view?.hideProgress();
				self.view?.reload();
			}
		}).addDisposableTo(dispose);
	}	
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120;
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		view?.showError((bookAdapter.dataSource?.get(index: indexPath.row)?.cover)!, action: nil, completed: nil);
		if let dependency = view?.application?.dependencyInjector as? Container {
			if let fileStorage = dependency.resolve(FileStorageType.self) {
				if let book = bookAdapter.dataSource?.get(index: indexPath.row) {
					if let file = fileStorage.file(file: book.name!) {
						if let directory = fileStorage.directory?.appendingPathComponent(book.name!) {
							if let navigationController = view?.navigationController {
								let viewController = ReadViewController(book: directory, dependency: dependency);
								navigationController.pushViewController(viewController, animated: true);
							}
						}
					}
				}
			}
		}
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: MainViewControllerPresenterImp.self);
	}
}
