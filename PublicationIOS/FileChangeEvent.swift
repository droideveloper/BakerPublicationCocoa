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
 
import Core

class FileChangeEvent: EventDelegate {
	
	private var _url: URL;
	private var _book: Book;
	
	var url: URL {
		get {
			return self._url;
		}
	}
	
	var book: Book {
		get {
			return self._book;
		}
	}
	
	init(_ book: Book, url: URL) {
		self._book = book;
		self._url = url;
	}
}
