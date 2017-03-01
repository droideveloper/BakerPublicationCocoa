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

import Material
import RxSwift

class NavigationViewControllerPresenterImp: AbstractPresenter<NavigationViewController>,
	NavigationViewControllerPresenter, LogDelegate,
	WKUIDelegate, WKScriptMessageHandler, WKNavigationDelegate {
	
	var uiDelegate: WKUIDelegate {
		get {
			return self;
		}
	}
	
	var jsBridge: WKScriptMessageHandler {
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
	let FILE_AUTHORITY				= "file";
	
	let INDEX_FILE	= "index.html";
	let INDEX_FILE2 = "index.htm";
	
	let dispose = DisposeBag();
	let hWidth  = Screen.bounds.width / 2;
	
	var index: URL?;
	var contents: [String]?;
	
	var positions: [Int: CGFloat] = [:];
	
	
	func setContentStrings(_ contents: [String]?) {
		self.contents = contents;
	}
	
	func setIndexURL(_ index: URL?) {
		self.index = index;
	}
	
	override func viewDidLoad() {
		if let index = index {
			view.load(url: index);
		}
		BusManager.register { [weak weakSelf = self] evt in
			if let event = evt as? PageSelectedByIndex {
				weakSelf?.selectedScrollX(selected: event.index);
			} else if let event = evt as? PageSelectedByUri {
				let path = event.uri.lastPathComponent;
				let position = weakSelf?.contents?.index(of: path) ?? -1;
				weakSelf?.selectedScrollX(selected: position);
			}
		}.addDisposableTo(dispose);
	}
	
	// WKScriptMessageHandler
	func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
		let from = message.name;
		if from == NavigationViewControllerImp.contentReady {
			if let data = message.body as? [String: Int] {
				let width = data["width"] ?? 0;
				let height = data["height"] ?? 0;				
				view.updateViewSize(width: width, height: height)
			}
		} else if from == NavigationViewControllerImp.contentUpdate {
			if let data = message.body as? [String: Any] {
				let left = (data["left"] as? CGFloat) ?? 0;
				let uri  = (data["uri"] as? String) ?? "";
				
				if let contents = contents {
					for (index, path) in contents.enumerated() {
						if uri.hasSuffix(path) {
							positions[index] = (left - hWidth);
						}
					}
				}
			}
		}
	}
	
	// WKNavigationDelegate
	func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		view.evaluateJavascript(js: SystemJS.js);
	}
	
	// WKNavigationDelegate
	func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
		let urlReequest = navigationAction.request;
		if let uri = urlReequest.url {
			if let scheme = uri.scheme {
				if scheme == WEB_AUTHORITY || scheme == SECURE_WEB_AUTHORITY {
					view.openUrl(uri: uri);
					decisionHandler(.cancel);
				} else if scheme == FILE_AUTHORITY {
					let fileName = uri.lastPathComponent;
					if fileName == INDEX_FILE || fileName == INDEX_FILE2 {
						// we can load this url
						decisionHandler(.allow);
					} else {
						BusManager.post(event: PageSelectedByUri(uri));
						// these are other local files that are needed to be send with event for other page handle those
						decisionHandler(.cancel);
					}
				}
			}
		} else {
			// somehow request does not have url then we don't care what you saying
			decisionHandler(.cancel);
		}
	}
	
	func selectedScrollX(selected: Int) {
		if let x = positions[selected] {
			if x >= 0 {
				view.scrollBy(x: x);
			}
		}
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: NavigationViewControllerPresenterImp.self);
	}
}
