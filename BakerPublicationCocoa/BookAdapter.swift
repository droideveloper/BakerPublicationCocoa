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

class BookAdapter: AbstractAdapter<Book, BookViewHolder>, LogType {
	
	let dispose = DisposeBag();
	var dataSourceObserver: BehaviorSubject<[Book]?>;
	
	init(_ observer: BehaviorSubject<[Book]?>) {
		self.dataSourceObserver = observer;
		super.init();
		self.dataSourceObserver
			.subscribeOn(RxSchedulers.io)
			.observeOn(RxSchedulers.mainThread)
			.subscribe(onNext: { [unowned self] dataSource in
			self.dataSource = dataSource;
			BusManager.post(event: BookAdapterChangeEvent());
		}).addDisposableTo(dispose);
	}
	
	convenience override init() {
		self.init(BehaviorSubject<[Book]?>(value: nil));
	}
	
	override func identifier(_ index: Int) -> String? {
		return BookViewHolder.kIdentifier;
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: BookAdapter.self);
	}
}

class BookAdapterChangeEvent: EventType {}
