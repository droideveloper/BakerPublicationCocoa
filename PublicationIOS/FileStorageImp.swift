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
import Foundation

class FileStorageImp: FileStorage {
	
	private let buffer = 8192;
	
	private var directories: [URL];

	var directory: URL? {
		get {
			return directories.first;
		}
	}
	
	init() {
		self.directories = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask);
	}
	
	func forRead(_ named: String) -> Config? {
		if let directory = directory {
			let url = directory.appendingPathComponent(named);
			return forRead(url);
		}
		return nil;
	}
	
	func forRead(_ uri: URL) -> Config? {
		if let str = try? String(contentsOf: uri, encoding: .utf8) {
			return Config(JSONString: str);
		}
		return nil;
	}
	
	func forDirectory(_ named: String) -> URL? {
		if let directory = directory {
			return directory.appendingPathComponent(named);
		}
		return nil;
	}
	
	func forSize(_ named: String) -> Int64 {
		if let url = forDirectory(named) {
			let manager = FileManager.default;
			if manager.fileExists(atPath: url.path) {
				if let attr = try? manager.attributesOfItem(atPath: url.path) {
					if let size = attr[FileAttributeKey.size] as? Int64 {
						return size;
					}
				}
			}
		}
		return 0;
	}
}
