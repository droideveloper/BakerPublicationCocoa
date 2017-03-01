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
import ObjectMapper

class Book: NSObject, Mappable {
	
	static let kName	= "name";
	static let kTitle = "title";
	static let kInfo	= "info";
	static let kDate	= "date";
	static let kCover = "cover";
	static let kUrl		= "url";
	
	// Date to Str Converter
	let dateTransform = TransformOf<Date, String>(fromJSON: { (str: String?) -> Date? in
		let formatter = DateFormatter();
		formatter.locale = Locale(identifier: "en_US");
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
		if let str = str {
			return formatter.date(from: str);
		}
		return nil;
	}, toJSON: { (date: Date?) -> String? in
		let formatter = DateFormatter();
		formatter.locale = Locale(identifier: "en_US");
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss";
		if let date = date {
			return formatter.string(from: date);
		}
		return nil;
	});
	
	var name:		String?;
	var title:	String?;
	var info:		String?;
	var date:		Date?;
	var cover:	String?;
	var url:		String?;
	
	override init() {
		super.init();
	}
	
	required init?(map: Map) {}
	
	func mapping(map: Map) {
		name <- map[Book.kName];
		title <- map[Book.kTitle];
		info <- map[Book.kInfo];
		date <- (map[Book.kDate], dateTransform);
		cover <- map[Book.kCover];
		url <- map[Book.kUrl];
	}
}

//LogDelegate
extension Book: LogDelegate {
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: Book.self);
	}
}

