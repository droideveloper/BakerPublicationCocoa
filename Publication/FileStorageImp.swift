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
	
	func forData(_ data: Data, url: URL, position: Int64, total: Int64) throws {
		if let handle = try? FileHandle(forWritingTo: url) {
			handle.seekToEndOfFile();
			handle.write(data);
			handle.closeFile();
		} else {
			try data.write(to: url);
		}
		/*let dataStream = DataStream(data);
		while let chunk = dataStream.read(bufferSize: buffer) {
			do {
				try write(chunk, url: url);
			} catch let error {
				print("write in chunk error is \(error)")
			}
			//let progress = Float(chunk.count + position) / Float(total);
			//BusManager.post(event: ProgressEvent(progress, url: url));
		}*/
	}
	
	func forDirectory(_ named: String) -> URL? {
		if let directory = directory {
			return directory.appendingPathComponent(named);
		}
		return nil;
	}
	
	func forSize(_ named: String) -> Int64 {
		if let url = forDirectory(named) {
			if FileManager.default.fileExists(atPath: url.path) {
				if let attr = try? FileManager.default.attributesOfItem(atPath: url.path) {
					if let size = attr[FileAttributeKey.size] as? Int64 {
						return size;
					}
				}
			}
		}
		return 0;
	}
	
	fileprivate func write(_ data: Data, url: URL) throws {
		if FileManager.default.fileExists(atPath: url.path) {
			if let handle = try? FileHandle(forWritingTo: url) {
				handle.seekToEndOfFile();
				handle.write(data);
				handle.closeFile();
			}
		} else {
			try? data.write(to: url);
		}
	}
}
