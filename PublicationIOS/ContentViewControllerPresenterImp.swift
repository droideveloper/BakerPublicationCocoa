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

import WebKit
import Core

class ContentViewControllerPresenterImp: AbstractPresenter<ContentViewController>,
	ContentViewControllerPresenter, LogDelegate,
	WKNavigationDelegate, WKUIDelegate {
	
	var uiDelegate: WKUIDelegate {
		get {
			return self;
		}
	}
	
	var navigationDelegate: WKNavigationDelegate {
		get {
			return self;
		}
	}
	
	let WEB_AUTHORITY					= "http";
	let SECURE_WEB_AUTHORITY	= "https";
	let LOCALE_AUTHORITY			= "file";
	
	var file: URL?;
	
	override init(_ view: ContentViewController) {
		super.init(view);
	}
	
	override func viewDidLoad() {
		if let file = file {
			view.load(url: file);
		}
	}
	
	func setUrl(_ file: URL?) {
		self.file = file;
	}
	
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		let urlRequest = navigationAction.request;
		if let uri = urlRequest.url {
			if let scheme = uri.scheme {
				if scheme == WEB_AUTHORITY || scheme == SECURE_WEB_AUTHORITY {
					view.openUrl(uri: uri);
					decisionHandler(.cancel);
				} else if scheme == LOCALE_AUTHORITY {
					if file == uri {
						view.showProgress()
						decisionHandler(.allow);
					} else {
						BusManager.post(event: PageSelectedByUri(uri));
						decisionHandler(.cancel);
					}
				}
			}
		} else {
			// we do not care about you
			decisionHandler(.cancel);
		}
	}
	
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		view.hideProgress();
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ContentViewControllerPresenterImp.self);
	}
}
