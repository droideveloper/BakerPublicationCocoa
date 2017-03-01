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

protocol FileStorage {
	
	var directory: URL? { get }
	
	func forRead(_ named: String) -> Config?;
	func forRead(_ uri: URL) -> Config?;
	
	func forDirectory(_ named: String) -> URL?;
	
	func forSize(_ named: String) -> Int64;
}
