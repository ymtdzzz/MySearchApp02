//
//  ItemSearchResultSet.swift
//  MySearchApp02
//
//
//  商品検索結果を格納するクラス
//  ＜イメージ＞
//          ResultSet
//              |
//        |----------|
//     Result     Request
//       |
//   |-----|-----|-----|----|--...
//  [1]   [2]   ...
//   |
//   |--------|--------|-------|
// [Image]  [Name]  [Price]  [Url]

import Foundation

// 検索結果全体を保持
//　JSONDecoderクラスのメソッドを利用するためにCodableｗプロトコルを適用する
class ItemSearchResultSet: Codable {
    var resultSet: ResultSet
    
//    プロパティ名とJSON形式のレスポンスのキーを一致させるための定義
    private enum CodingKeys: String, CodingKey {
        case resultSet = "ResultSet"
    }
}

//  検索結果セットを格納する
class ResultSet: Codable {
    var firstObject: FirstObject
    private enum CodingKeys: String, CodingKey {
        case firstObject = "0"
    }
}

//  検索結果の先頭を格納する
class FirstObject: Codable {
    var result: Result
    private enum CodingKeys: String, CodingKey {
        case result = "Result"
    }
}

//  検索結果を格納
class Result: Codable {
//    ItemData型のインスタンスを配列として宣言（DTO感）
    var items: [ItemData] = [ItemData]()
//    独自のデコード処理を定義
    required init(from decoder: Decoder) throws {
//        デコードのためのコンテナを取得
        let container = try decoder.container(keyedBy: CodingKeys.self)
//        コンテナ内のキーを取得。キーが文字列であるため、数値の昇順でソートも行う。
        let keys = container.allKeys.sorted {
            Int($0.rawValue)! < Int($1.rawValue)!
        }
//        キーを使用して検索結果を１件ずつ取り出す
        for key in keys {
//            検索結果１件に対するデコード処理
            let item = try container.decode(ItemData.self, forKey: key)
//            デコードしたitemを配列に追加
            items.append(item)
        }
    }
    
//    エンコード処理
    func encode(to encoder: Encoder) throws {
//        エンコードしない
    }
    
//    Resultクラスの値を取得するキーをプロパティ名に一致させる
    private enum CodingKeys: String, CodingKey {
        case hit0 = "0"
        case hit1 = "1"
        case hit2 = "2"
        case hit3 = "3"
        case hit4 = "4"
        case hit5 = "5"
        case hit6 = "6"
        case hit7 = "7"
        case hit8 = "8"
        case hit9 = "9"
        case hit10 = "10"
        case hit11 = "11"
        case hit12 = "12"
        case hit13 = "13"
        case hit14 = "14"
        case hit15 = "15"
        case hit16 = "16"
        case hit17 = "17"
        case hit18 = "18"
        case hit19 = "19"
        case hit20 = "20"
    }
}

//  商品情報を格納する
class ItemData: Codable {
//    商品名
    var name: String = ""
//    商品URL
    var url: String  = ""
    
//    商品の画像情報
    class ImageInfo: Codable {
//        Imageクラスから取得するためのキー
        private enum CodingKeys: String, CodingKey {
            case medium = "Medium"
        }
        
//        商品画像URL
        var medium: String?
    }
//    商品画像URL
    var imageInfo: ImageInfo = ImageInfo()
    
//    価格情報
    class PriceInfo: Codable {
        private enum CodingKeys: String, CodingKey {
            case price = "_value"
        }
        
//        価格
        var price: String?
    }
    
//    価格
    var priceInfo: PriceInfo = PriceInfo()
    
    private enum CodingKeys: String, CodingKey {
        case name = "Name"
        case url = "Url"
        case imageInfo = "Image"
        case priceInfo = "Price"
    }
}
