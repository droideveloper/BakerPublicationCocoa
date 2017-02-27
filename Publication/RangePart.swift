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

class RangePart: CustomStringConvertible {
	
	static let PART_SIZE = 512 * 1024;
	
	var start: Int64?;
	var end: Int64?;
	
	init(_ start: Int64, _ end: Int64) {
		self.start = start;
		self.end = end;
	}
	
	var description: String {
		if let start = start, let end = end {
			return "bytes=\(start)-\(end)";
		}
		return "\(self)";
	}	
}
