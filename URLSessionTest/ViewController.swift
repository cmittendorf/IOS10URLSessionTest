//
//  ViewController.swift
//  URLSessionTest
//
//  Created by Christian Mittendorf on 16/01/2017.
//  Copyright © 2017 freenet.de GmbH. All rights reserved.
//

import UIKit

class ViewController: UIViewController, URLSessionDataDelegate {

    @IBOutlet weak var label: UILabel!

    private let url = URL(string: "http://h1152756.serverkompetenz.net/cookie.php")!
    private var firstRequestComplete = false

    private var body: String? {
        didSet {
            let test = body?.contains("foo") ?? false
            DispatchQueue.main.async {
                self.label.text = (test ? "✅" : "❌") + "🍪"
            }
        }
    }

    private var session: URLSession? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let configuration = URLSessionConfiguration.background(withIdentifier: Bundle.main.bundleIdentifier!)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

        // perform the first network request that will 
        // set a session cookie["foo"] = "bar"
        let req = request(withName: "foo", value: "bar")
        session?.dataTask(with: req).resume()
    }

    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let cookies = HTTPCookieStorage.shared.cookies(for: url)
        print("[🍪🍪]: \(cookies)")
        body = String(data: data, encoding: .utf8)
    }

    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {

        if let response = task.response as? HTTPURLResponse {
            for (key, value) in response.allHeaderFields {
                if let name = key as? String, name == "Set-Cookie" {
                    print("🍪 \(value)")
                }
            }
        }

        guard firstRequestComplete == false else { return }
        firstRequestComplete = true

        // perform a second network request using the same session. we assume that
        // the request does contains the cookie that was set during the first 
        // request.
        // Using the Simulator with iOS 9, the second reqeust does contain the previously
        // set cookie.
        // With iOS 10 this is not the case. The previously set cookie is not added to
        // the request.
        let req = request()
        self.session?.dataTask(with: req).resume()
    }

    private func request(withName name: String? = nil, value: String? = nil) -> URLRequest {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            else { fatalError() }

        if let name = name, let value = value {
            let queryItems = [URLQueryItem(name: "name", value: name),
                              URLQueryItem(name: "value", value: value)]
            components.queryItems = queryItems
        }

        let request = URLRequest(url: components.url!)
        return request
    }
}
