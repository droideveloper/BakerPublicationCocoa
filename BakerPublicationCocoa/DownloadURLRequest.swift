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
import Alamofire

enum DownloadURLRequest: URLRequestConvertible {
	case fetch(book: Book, range: RangePart);
	case head(book: Book);
	
	func asURLRequest() throws -> URLRequest {
		throw HttpError(0, "Not implemented error");
	}
	
	var urlRequest: URLRequest? {
		get {
			do {
				switch self {
				case .fetch(let book, let range):
					if let url = book.url {
						var request = try URLRequest(url: url, method: .get);
						request.setValue(range.description, forHTTPHeaderField: "Range");
						request.cachePolicy = .reloadIgnoringCacheData;
						return request;
					}
					throw HttpError(404, "no such url");
				case .head(let book):
					if let url = book.url {
						var request = try URLRequest(url: url, method: .head);
						request.cachePolicy = .reloadIgnoringCacheData;
						return request;
					}
					throw HttpError(404, "no such url");
				}
			} catch {
				return nil;
			}
		}
	}
}
