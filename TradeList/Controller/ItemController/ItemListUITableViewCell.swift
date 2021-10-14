//
//  ItemListUITableViewCell.swift
//  TradeList
//
//  Created by Türker on 13.10.2021.
//

import UIKit

class ItemListUITableViewCell: UITableViewCell {
    @IBOutlet private weak var productName: UILabel!
    @IBOutlet private weak var productCategory: UILabel!
    @IBOutlet private weak var productPrice: UILabel!
    @IBOutlet private weak var productDescription: UILabel!
    @IBOutlet private weak var productDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configureCellOutlets(model: Item) {
        productName.text = model.title
        productDate.text = model.dateItem
        productPrice.text = model.price
        productDescription.text = model.descriptionItem
        productCategory.text = model.category
    }
}
