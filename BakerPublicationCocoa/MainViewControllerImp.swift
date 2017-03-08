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
import Material

import RxSwift
import RxCocoa

class MainViewControllerImp: AbstractViewController<MainViewControllerPresenter>,
	MainViewController, LogType {
	
	let padding: CGFloat = 5;
	
	var tableView: UITableView? {
		get {
			for view in view.subviews {
				if let view = view as? UITableView {
					return view;
				}
			}
			return nil;
		}
	}
	
	override func prepare() {
		super.prepare();
		// navigation view is there
		navigationItem.title = "Baker Book Shelf"
		navigationItem.titleLabel.font = RobotoFont.regular(with: 15);
		navigationItem.titleLabel.textAlignment = .left;
		navigationItem.titleLabel.textColor = .white;
		
		self.view.backgroundColor = Color.grey.lighten3;
		let tablewView = UITableView(frame: .zero, style: .plain);
		tablewView.register(BookViewHolder.self, forCellReuseIdentifier: BookViewHolder.kIdentifier);
		// registered viewHolder
		if let presenter = presenter {
			tablewView.dataSource = presenter.dataSource;
			tablewView.delegate = presenter.delegate;
		}
		tablewView.backgroundView = nil;
		tablewView.backgroundColor = Color.grey.lighten3;
		tablewView.tableFooterView = View(frame: .zero);
		tablewView.separatorStyle = .singleLine;
		tablewView.separatorColor = Color.grey.base;
		tablewView.allowsMultipleSelection = false;
		view.layout(tablewView)
			.edges(top: padding, left: padding, bottom: padding, right: padding);
		let progress = UIActivityIndicatorView(activityIndicatorStyle: .gray);
		if let theme = application {
			progress.color = theme.colorAccent;
		}
		view.layout(progress)
			.center();
	}
	
	func reload() {
		if let tableView = tableView {
			tableView.reloadData();
		}
	}
	
	func isLogEnabled() -> Bool {
		#if DEBUG
			return true;
		#else
			return false;
		#endif
	}
	
	func getClassTag() -> String {
		return String(describing: MainViewControllerImp.self);
	}
}
