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
 
import MVPCocoa

class ProgressEvent: EventType {
	
	private var _persisted: Int64;
	private var _total: Int64;
	private var _url: URL;
	
	var persisted: Int64 {
		get {
			return self._persisted;
		}
	}
	
	var total: Int64 {
		get {
			return self._total;
		}
	}
	
	var url: URL {
		get {
			return self._url;
		}
	}
	
	init(_ persited: Int64, _ total: Int64, url: URL) {
		self._persisted = persited;
		self._total = total;
		self._url = url;
	}
}
