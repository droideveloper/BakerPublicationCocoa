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

class ContentViewControllerImp: AbstractPageViewHolder<URL, ContentViewControllerPresenter>,
	ContentViewController, LogDelegate, UIGestureRecognizerDelegate {
	
	private var wkWebView: WKWebView!;
	private var progressView: UIActivityIndicatorView!;
	
	let dispose = DisposeBag();
	
	convenience init(_ position: Int, _ item: URL?) {
		self.init();
		self.presenter = ContentViewControllerPresenterImp(self);
		self.position = position;
		self.item = item;
	}
	
	override func prepare() {
		super.prepare();
		
		presenter?.setUrl(item);
		
		progressView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge);
		if let theme = application() {
			progressView.color = theme.colorAccent;
		}
		
		view = View(frame: Screen.bounds);
		
		let configuration = WKWebViewConfiguration();
		wkWebView = WKWebView(frame: .zero, configuration: configuration);
		wkWebView.uiDelegate = presenter?.uiDelegate;
		wkWebView.navigationDelegate = presenter?.navigationDelegate;
		
		view.layout(wkWebView)
			.edges();
		
		view.layout(progressView)
			.center();
		
		// much much better approach
		let gesture = UITapGestureRecognizer(target: self, action: #selector(doubleTap(gesture:)));
		gesture.numberOfTapsRequired = 2;
		gesture.delegate = self;
		
		wkWebView.scrollView.addGestureRecognizer(gesture);
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

	func doubleTap(gesture: UITapGestureRecognizer) {
		BusManager.post(event: VisibilityChange());
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return true;
	}
	
	func isLogEnabled() -> Bool {
		return true;
	}
	
	func getClassTag() -> String {
		return String(describing: ContentViewControllerImp.self);
	}
}
