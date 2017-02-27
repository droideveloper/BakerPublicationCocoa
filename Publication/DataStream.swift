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

class DataStream {
	// chunk size for each write operation we are ok with it.
	private let bufferSize = 8192;
	// data start chunking.
	var data: Data;
	// data chunk position where we left.
	var position: Int;
	
	init(_ data: Data) {
		self.data = data;
		self.position = 0;
	}
	
	func read(bufferSize: Int) -> Data? {
		if position < data.count {
			let chunk = (position + bufferSize) < data.count ? (position + bufferSize) : data.count;
			let buffer = data.subdata(in: position..<chunk);
			self.position = chunk;
			return buffer;
		}
		return nil;
	}
	
	func hasNext() -> Bool {
		return position < data.count;
	}
	
	func persist(_ uri: URL, _ position: Int64, _ total: Int64) throws -> Void {
		let manager = FileManager.default;
		if manager.fileExists(atPath: uri.path) {
			if let handle = try? FileHandle(forWritingTo: uri) {
				var cursor: Int64 = position;
				handle.seekToEndOfFile();
				while let buffer = read(bufferSize: bufferSize) {
					handle.write(buffer);
					cursor += Int64(bufferSize);
					// notify users after first chunk people won't notice it
					BusManager.post(event: ProgressEvent(cursor, total, url: uri));
				}
				handle.closeFile();
			}
		} else if let createBuffer = read(bufferSize: bufferSize) {
			// just to write first one in file create mode
			try createBuffer.write(to: uri);
			// write rest with chunk
			try persist(uri, Int64(bufferSize), total);
		}
	}
}
