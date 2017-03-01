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
 
import Foundation

import Core

class DownloadMagazineJob: Operation {
	
	// headers
	static let kContentLength = "Content-Length";
	static let kRange					= "Range";
	// data chunk size
	static let PART_SIZE: Int64 = 1024 * 1024;

	private var fileStorage: FileStorage;
	private var book: Book;
	
	init(_ fileStorage: FileStorage, _ book: Book) {
		self.fileStorage = fileStorage;
		self.book = book;
	}
	
	override func main() {
		let size = fileSize();
		if let name = book.name {
			let start = fileStorage.forSize("\(name).hpub")
			if let size = size {
				let chunks = fileParts(start, size);
				for chunk in chunks {
					_ = filePart(chunk, fileStorage.forSize("\(name).hpub"), size);
				}
			}
			if let url = fileStorage.forDirectory("\(name).hpub") {
				BusManager.post(event: FileChangeEvent(book, url: url));
			}
		}
	}
	
	func fileSize() -> Int64? {
		if isCancelled { return nil; }
		let requestBuilder = DownloadURLRequest.head(book: book);
		if let request = requestBuilder.urlRequest {
			let lock = DispatchSemaphore(value: 0);
			var contentLength: Int64?;
			URLSession.shared.dataTask(with: request) { (data, response, error) in
				if let response = response as? HTTPURLResponse {
					if response.statusCode / 100 <= 2 {
						let key = response.allHeaderFields[DownloadMagazineJob.kContentLength];
						if let value = key as? String {
							contentLength = Int64(value);
						}
					}
				}
				lock.signal();
			}.resume();
			_ = lock.wait(timeout: .distantFuture);
			return contentLength;
		}
		return nil;
	}
	
	func filePart(_ part: RangePart, _ start: Int64, _ total: Int64) -> Bool {
		if isCancelled { return false; }
		if let name = book.name {
			let requestBuilder = DownloadURLRequest.fetch(book: book, range: part);
			var headers: [String: String] = [:];
			headers[DownloadMagazineJob.kRange] = part.description;
			if let request = requestBuilder.urlRequest {
				let lock = DispatchSemaphore(value: 0);
				URLSession.shared.dataTask(with: request) { [weak weakSelf = self] (data, response, error) in
					do {
						if let uri = weakSelf?.fileUri("\(name).hpub") {
							if let data = data {
								let stream = DataStream(data);
								try stream.persist(uri, start, total);
							}
						}
					} catch {
						print("Don't I know it");
					}
					lock.signal();
				}.resume();
				_ = lock.wait(timeout: .distantFuture);
				return true;
			}
		}
		return false;
	}
	
	func fileParts(_ start: Int64, _ total: Int64) -> [RangePart] {
		var array = [RangePart]();
		var position = start;
		while position < total {
			let end = (position + DownloadMagazineJob.PART_SIZE) < total ? (position + DownloadMagazineJob.PART_SIZE - 1) : (total - 1);
			array.add(item: RangePart(position, end));
			position = end + 1;
		}
		return array;
	}
	
	func fileUri(_ named: String) -> URL? {
		if let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			return directory.appendingPathComponent(named);
		}
		return nil;
	}
}
