//
//  ItemTableViewCell.swift
//  MySearchApp02
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemViewCell: UIImageView!   // 商品画像
    @IBOutlet weak var itemTitleLabel: UILabel!     // 商品タイトル
    @IBOutlet weak var itemPriceLabel: UILabel!     // 商品価格
    
    var itemUrl: String?    // 商品ページのURL。遷移先の画面で利用
    
//    初期化処理
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
//        元々入っている情報を再利用時にクリア
//        別の商品画像の読み込みに失敗すると、前の画像が残ってしまうので、
//        再利用の度にクリア
        itemViewCell.image = nil
    }
}
