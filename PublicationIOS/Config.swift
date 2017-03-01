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
import ObjectMapper

class Config: Mappable {
	
	static let kTitle			= "title";
	static let kIndex			= "index";
	static let kContents	= "contents";
	
	var title: String?;
	var index: String?;
	var contents: [String]?;
	
	required init?(map: Map) { }
	
	func mapping(map: Map) {
		title <- map[Config.kTitle];
		index <- map[Config.kIndex];
		contents <- map[Config.kContents];
	}
}
