//
//  WebViewController.swift
//  MySearchApp02
//

import UIKit
import WebKit

//  商品ページを参照する画面
class WebViewController: UIViewController {
//    商品ページのURL（遷移元の画面から受け渡し済）
    var itemUrl: String?
    
//    商品ページを参照するためのWebView
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        UserAgent設定
        webView.customUserAgent =
        "Mozilla/5.0 (iPhone; CPU iPhone OS 11_0_1 like Mac OSX) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A402 Safari/604.1"
        
//        webページの表示
        guard let itemUrl = itemUrl else {
            return
        }
        guard let url = URL(string: itemUrl) else {
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}
