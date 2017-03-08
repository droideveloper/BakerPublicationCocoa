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
	let bookAdapter = BookAdapter(dataSource: []);
	
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
			if let component = application.component as? Container {
				if let bakerEndpoint = component.resolve(BakerEndpointType.self) {
					bakerEndpoint.books()
						.retry(3)
						.subscribeOn(RxSchedulers.io)
						.observeOn(RxSchedulers.mainThread)
						.subscribe(onNext: { [weak weakSelf = self] books in
							weakSelf?.view?.hideProgress();
							weakSelf?.bookAdapter.dataSource = books;
							weakSelf?.view?.reload();
						})
						.disposed(by: dispose);
				}
			}
		}
	}	
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 120;
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if let component = view?.application?.component as? Container {
			if let fileStorage = component.resolve(FileStorageType.self) {
				if let book = bookAdapter.dataSource.get(index: indexPath.row) {
					// TODO check read and write donwload and unarzhive options
					if let file = fileStorage.file(file: book.name!) {
						if let directory = fileStorage.directory?.appendingPathComponent(book.name!) {
							if let navigationController = view?.navigationController {
								let viewController = ReadViewController(book: directory);
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
