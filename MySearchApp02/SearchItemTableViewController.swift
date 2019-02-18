//
//  SearchItemTableViewController.swift
//  MySearchApp02
//

import UIKit

// 商品検索画面の実装クラス
class SearchItemTableViewController: UITableViewController, UISearchBarDelegate {
//    itemDataを格納する配列を生成
    var itemDataArray = [ItemData]()
    
//    NSCacheでパフォーマンス改善（商品画像）
//    キーがAnyObject型、valueがUIImage型
    var imageCache = NSCache<AnyObject, UIImage>()
    
//    API利用のためのID(マスキング済)
    let appid: String = "************"
//    リクエストURLの発行
    let entryURL: String = "https://shopping.yahooapis.jp/ShoppingWebService/V1/json/itemSearch"
    
//    金額のFormatterを定義
    let priceFormat = NumberFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        価格のフォーマット設定
        priceFormat.numberStyle = .currency
        priceFormat.currencyCode = "JPY"
    }
    
//    検索ボタン押下時に呼び出されるメソッド
//    入力フォームの中身を取得し、それをAPIのパラメータに設定し、リクエストを飛ばす
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        searchBarに入力された文字を取得
//        中身が無い場合はすぐに処理を終了
        guard let inputText = searchBar.text else {
            return
        }
        
//        文字列長が0以下の場合は処理終了
        guard inputText.lengthOfBytes(using: String.Encoding.utf8)  > 0 else {
            return
        }
        
//        商品情報をクリア
        itemDataArray.removeAll()
        
//        パラメータの指定（key=value形式）
        let parameter = ["appid": appid, "query": inputText]
        
//        パラメータのエンコード（使用できない文字列を変換）
        let requestUrl = createRequestUrl(parameter: parameter)
        
//        APIにリクエストを飛ばす
        request(requestUrl: requestUrl)
        
//        キーボードを閉じる
        searchBar.resignFirstResponder()
    }
    
//    パラメータに利用できない文字列をエスケープ処理する
    func encodeParameter(key: String, value: String) -> String? {
        guard let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) else {
//            エンコードに失敗した場合
            return nil
        }
//        key=value形式で返却
        return "\(key)=\(escapedValue)"
    }
    
//    URL作成処理
    func createRequestUrl(parameter: [String:String]) -> String {
        var parameterString = ""
        for key in parameter.keys {
//            値の取出し
            guard let value = parameter[key] else {
//                値がないので次のループへ
                continue
            }
//            パラメータ設定済みの場合
            if parameterString.lengthOfBytes(using: String.Encoding.utf8) > 0 {
//                &を付与する
                parameterString += "&"
            }
//            値のエンコード
            guard let encodeValue = encodeParameter(key: key, value: value) else {
//                失敗した場合は次のループへ
                continue
            }
//            エンコードした値をパラメータとして追加
            parameterString += encodeValue
        }
        let requestUrl = entryURL + "?" + parameterString
        return requestUrl
    }
    
//    リクエストを行う
    func request(requestUrl: String) {
//        URL生成->そのurlでrequest生成->request使ってsessionのtaskを呼び出す
//        URLの生成
        guard let url = URL(string: requestUrl) else {
//            生成に失敗
            return
        }
//        リクエスト生成
        let request = URLRequest(url: url)
//        APIを呼び出し、賞品検索実行
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data:Data?, response:URLResponse?, error:Error?) in
//            通信完了後
//            エラーチェック
            guard error == nil else {
//                show error
                let alert = UIAlertController(title: "エラー", message: error?.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//                メインスレッドで表示
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
                return
            }
//            正常終了
            guard let data = data else {
                return
            }
            
            do {
//                JSON形式のデータを各クラスに対応して変換
                let resultSet = try JSONDecoder().decode(ItemSearchResultSet.self, from: data)
//                商品のリストに追加
                self.itemDataArray.append(contentsOf: resultSet.resultSet.firstObject.result.items)
            } catch let error {
                print("エラー発生: \(error)")
            }
            
//            テーブル再描画
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
//        通信を開始する
        task.resume()
    }
    
//    TableViewDataSourceに関連するメソッド
//    セクション数
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
//    セクション内の商品数
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemDataArray.count
    }
    
//    テーブルセルの取得
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        let itemData = itemDataArray[indexPath.row]
//        商品のタイトル
        cell.itemTitleLabel.text = itemData.name
//        商品価格
        let number = NSNumber(integerLiteral: Int(itemData.priceInfo.price!)!)
        cell.itemPriceLabel.text = priceFormat.string(for: number)
//        商品のURL
        cell.itemUrl = itemData.url
//        初めての画像かチェックし、画像がまだ設定されたなければ実施
        guard let itemImageUrl = itemData.imageInfo.medium else {
//            画像がない商品
            return cell
        }
//        キャッシュの画像取得
        if let cacheImage = imageCache.object(forKey: itemImageUrl as AnyObject) {
//            見つかったら、キャッシュ画像を設定
            cell.itemViewCell.image = cacheImage
            return cell
        }
        
//        見つからなかったらダウンロードする
//        まずはあURLを生成する
        guard let url = URL(string: itemImageUrl) else {
            return cell
        }
//        requestの生成
        let request = URLRequest(url: url)
//        requestを用いてsessionのtask生成
//        決まり文句
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?,  response: URLResponse?,  error:Error?)  in
            guard  error == nil else {
                return
            }
            guard let data = data else {
//                データなし
                return
            }
            guard let image = UIImage(data: data) else {
//                image生成失敗
                return
            }
//            キャッシュへ登録
            self.imageCache.setObject(image, forKey: itemImageUrl as AnyObject)
//            画像はメインスレッドで設定
            DispatchQueue.main.async {
                cell.itemViewCell.image = image
            }
        }
//        画像読み込み通信開始
        task.resume()
        
        return cell
    }
    
//    商品をタップして次の画面へ遷移
//    WebViewControllerインスタンスを生成し、そのURLに設定
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? ItemTableViewCell {
            if let webViewController  = segue.destination as? WebViewController {
//                商品ページのURLを設定
                webViewController.itemUrl = cell.itemUrl
            }
        }
    }
}
