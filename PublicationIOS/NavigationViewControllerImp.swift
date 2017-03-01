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
import WebKit

import RxSwift

import Core
import Material

class NavigationViewControllerImp: AbstractViewController<NavigationViewControllerPresenter>,
	NavigationViewController, LogDelegate {
	
	static let contentReady  = "onLoadNavigation";
	static let contentUpdate = "onUpdateContent";
	
	private var progressView: UIActivityIndicatorView!;
	private var wkWebView: WKWebView!;
	
	
	let dispose = DisposeBag();
	var displayState = false;
	
	convenience init(_ navigationUri: URL, _ contents: [String]) {
		self.init();
		self.presenter = NavigationViewControllerPresenterImp(self);
		self.presenter?.setIndexURL(navigationUri);
		self.presenter?.setContentStrings(contents);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad();
		BusManager.register(next: { [weak weakSelf = self] evt in
			if let _ = evt as? VisibilityChange {
				weakSelf?.toggleDisplayState();
			}
		}).addDisposableTo(dispose);
	}
	
	override func prepare() {
		super.prepare();
		view = View(frame: .init(x: 0, y: 0, width: Screen.width, height: 1));
		
		let configuration = WKWebViewConfiguration();
		let controller = WKUserContentController();
		if let presenter = presenter {
			controller.add(presenter.jsBridge, name: NavigationViewControllerImp.contentReady);
			controller.add(presenter.jsBridge, name: NavigationViewControllerImp.contentUpdate);
		}
		configuration.userContentController = controller;
		
		wkWebView = WKWebView(frame: .zero, configuration: configuration);
		wkWebView.uiDelegate = presenter?.uiDelegate;
		wkWebView.navigationDelegate = presenter?.navigationDelegate;
		
		view.layout(wkWebView)
			.edges();
	}
	
	func load(url: URL) {
		if #available(iOS 9.0, *) {
			// TODO this is 9.0 fixed bug
			wkWebView.loadFileURL(url, allowingReadAccessTo: url);
		} else {
			// TODO extract book into /temp/www in order to access local html file.
			wkWebView.load(URLRequest(url: url));
		}
	}
	
	func openUrl(uri: URL) {
		UIApplication.shared.openURL(uri);
	}
	
	func updateViewSize(width: Int, height: Int) {
		UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { [weak weakSelf = self] in
			weakSelf?.view.heightConstraint?.constant = CGFloat(height);
			weakSelf?.view.layoutIfNeeded();
		});
	}
	
	func evaluateJavascript(js: String) {
		wkWebView.evaluateJavaScript(js, completionHandler: nil);
	}
	
	func scrollBy(x: CGFloat) {
		UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseInOut, animations: { [weak weakSelf = self] in
			weakSelf?.wkWebView.scrollView.contentOffset.x = x;
		});
	}
	
	func toggleDisplayState() {
		let translateY = view.bounds.origin.y + (displayState ? -1 : 1 * (view.bounds.height));
		UIView.animate(withDuration: 0.3, animations: {
			self.view.transform = CGAffineTransform.identity.translatedBy(x: 0, y: translateY);
		});
		displayState = !displayState;
	}
	
	func showProgress() {
		progressView?.startAnimating();
	}
	
	func hideProgress() {
		progressView?.stopAnimating();
	}
	
	func showError(_ error: String, action actionText: String?, completed on: (() -> Void)?) {
		if let snackbar = snackbarController?.snackbar {
			snackbar.text = error;
			if let str = actionText {
				let button = Flat(title: str, tintColor: Color.red.base, callback: on);
				button.addTarget(self, action: #selector(hideError), for: .touchUpInside);
				snackbar.rightViews = [button];
			}
			_ = snackbarController?.animate(snackbar: .visible);
			_ = snackbarController?.animate(snackbar: .hidden, delay: 5);
		}
	}
	
	@objc func hideError() {
		if let snackbar = snackbarController?.snackbar {
			snackbar.layer.removeAllAnimations();
		}
		_ = snackbarController?.animate(snackbar: .hidden);
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: NavigationViewControllerImp.self);
	}
}
