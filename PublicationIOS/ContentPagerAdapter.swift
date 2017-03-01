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
 
import UIKit
import Core
import Material

class ContentPagerAdapter: AbstractPagerAdapter<URL, ContentViewControllerPresenter>, LogDelegate {
	
	override func itemAtIndex(index: Int) -> URL? {
		if let dataSource = dataSource {
			if index >= 0 && index < dataSource.size() {
				return dataSource.get(index: index);
			}
		}
		return nil;
	}

	override func viewControllerAtIndex(index: Int) -> AbstractPageViewHolder<URL, ContentViewControllerPresenter>? {
		if let item = itemAtIndex(index: index) {
			let viewController = ContentViewControllerImp();
			viewController.item = item;
			viewController.position = index;
		}
		return nil;
	}
	
	func presentationCount(for pageViewController: UIPageViewController) -> Int {
		return dataSource?.size() ?? 0;
	}
	
	public func isLogEnabled() -> Bool {
		return true;
	}
	
	public func getClassTag() -> String {
		return String(describing: ContentPagerAdapter.self);
	}
}
