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
import AlamofireImage

class BookViewHolder: AbstractViewHolder<Book>, LogType {
	
	static let kIdentifier = "kBookViewHolder";
	
	let dispose = DisposeBag();
	
	override var item: Book? {
		didSet {
			if let book = item {
				if let cover = book.cover {
					RxNet.data(.get, cover)
						.map({ data in UIImage(data: data) })
						.subscribeOn(RxSchedulers.io)
						.observeOn(RxSchedulers.mainThread)
						.bindTo(coverView.rx.image)
						.addDisposableTo(dispose);
				}
				if let title = book.title {
					titleView.text = title;
				}
				if let date = book.date {
					let formatter = DateFormatter();
					formatter.locale = Locale(identifier: "en_US");
					formatter.dateFormat = "dd MMM yyyy";
					dateView.text = formatter.string(from: date);
				}
				if let description = book.info {
					descriptionView.text = description;
				}
			}
		}
	}
	
	var coverView: UIImageView!;
	var titleView: UILabel!;
	var dateView: UILabel!;
	var descriptionView: UILabel!;
	var progressView: UIProgressView!;
	var action: Flat!;
	
	override func prepare() {
		super.prepare();
		coverView = UIImageView();
		layout(coverView).top(5).left(5).width(60).height(80);
		
		titleView = UILabel();
		titleView.font = RobotoFont.regular(with: 14);
		layout(titleView).left(70).top(5).right(5).height(24);
		
		dateView = UILabel();
		dateView.font = RobotoFont.light(with: 10);
		layout(dateView).left(70).top(34).right(5).height(20);
		
		descriptionView = UILabel();
		descriptionView.font = RobotoFont.light(with: 10);
		descriptionView.numberOfLines = 4;
		layout(descriptionView).left(70).top(59).right(5);
		
		progressView = UIProgressView(progressViewStyle: .bar);
		layout(progressView).left(5).top(100).width(160);
		
		action = Flat(callback: { [unowned self] in
			self.updateUI();
		});
		action.title = "START";
		action.titleColor = Color.blueGrey.base;
		action.titleLabel?.font = RobotoFont.light(with: 10);
		layout(action).left(175).right(5).top(86).height(32)
		
		BusManager.register(next: { [unowned self] evt in
			if let event = evt as? ProgressEvent {
				if let book = self.item {
					var url: URL?;
					if let urlString = book.url {
						url = URL(string: urlString);
					}
					if let url = url {
						let progress = Float(event.persisted) / Float(event.total);
						if event.url == url {
							self.progressView.progress = progress;
						}
					}
				}
			} else if let event = evt as? FileChangeEvent {
				if let book = self.item {
					if book.url == event.book.url {
						self.updateUI();
					}
				}
			}
		}).addDisposableTo(dispose);
	}
	
	func updateUI() {
		if let item = item {
			print("\(item.cover)\n\(item.name)");
		}
	}

	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: BookViewHolder.self);
	}
}
