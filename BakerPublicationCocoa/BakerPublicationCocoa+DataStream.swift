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
 
import MVPCocoa

extension DataStream {
	
	var manager: FileManager {
		get {
			return FileManager.default;
		}
	}
	
	func write(url: URL, at start: Int64, in total: Int64) throws -> Void {
		if manager.fileExists(atPath: url.path) {
			if let fs = try? FileHandle(forWritingTo: url) {
				var position = start;
				fs.seekToEndOfFile();
				while let buffer = read() {
					fs.write(buffer);
					position += Int64(buffer.count);
					BusManager.post(event: ProgressEvent(position, total, url: url));
				}
				fs.closeFile();
			}
		} else if let buffer = read() {
			try buffer.write(to: url);
			try write(url: url, at: Int64(buffer.count), in: total);
		}
	}
	
}
