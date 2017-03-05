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
 
import Foundation

import MVPCocoa
import PublicationCocoa

class ManagazineJob: Operation, LogType {
	
	let kContentLength = "Content-Length";
	let kRange = "Range";
	
	let PART_SIZE: Int64 = 1024 * 1024;
	
	private let fileStorage: FileStorageType;
	private let book: Book;
	
	init(_ fileStorage: FileStorageType, _ book: Book) {
		self.book = book;
		self.fileStorage = fileStorage;
	}
	
	override func main() {
		let total = self.size()
		if let name = book.name {
			let start = fileStorage.size(of: name);
			let chunks = parts(at: start, in: total);
			for (index, chunk) in chunks.enumerated() {
				_ = part(part: chunk, at: ((index + 1) * PART_SIZE), in: total);
			}
			if let url = fileStorage.file(file: name) {
				BusManager.post(event: FileChangeEvent(book, url: url));
			}
		}
	}
	
	func size() -> Int64 {
		if isCancelled { return 0; }
		let requestBuilder = DownloadURLRequest.head(book: book);
		if let request = requestBuilder.urlRequest {
			let lock = DispatchSemaphore(value: 0);
			var contentLength: Int64 = 0;
			URLSession.shared.dataTask(with: request) { [unowned self] (data, response, error) in
				if let response = response as? HTTPURLResponse {
					if response.isSuccess {
						if let value = response.header(for: self.kContentLength) {
							contentLength = Int64(value) ?? 0;
						}
					}
				}
				lock.signal();
			}.resume();
			_ = lock.wait(timeout: .distantFuture);
			return contentLength;
		}
		return 0;
	}
	
	func part(part: RangePart, at start: Int64, in total: Int64) -> Bool {
		if isCancelled { return false; }
		if let name = book.name {
			let requestBuilder = DownloadURLRequest.fetch(book: book, range: part);
			var headers: [String: String] = [:];
			headers[kRange] = part.description;
			if let request = requestBuilder.urlRequest {
				let lock = DispatchSemaphore(value: 0);
				URLSession.shared.dataTask(with: request) { [unowned self] (data, response, error) in
					do {
						if let url = self.url(file: name) {
							if let data = data {
								let stream = DataStream(of: data);
								try stream.write(url: url, at: start, in: total);
							}
						}
					} catch let error {
						self.log(error: error);
					}
					lock.signal();
				}.resume();
				_ = lock.wait(timeout: .distantFuture);
				return true;
			}
		}
		return false;
	}
	
	func parts(at start: Int64, in total: Int64) -> [RangePart] {
		var array = [RangePart]();
		var position = start;
		while position < start {
			let index = position + PART_SIZE;
			let end = index < total ? (index - 1): (total - 1);
			array.add(item: RangePart(position, end));
			position = end + 1;
		}
		return array;
	}
	
	func url(file named: String) -> URL? {
		return fileStorage.file(file: named);
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ManagazineJob.self);
	}
}
