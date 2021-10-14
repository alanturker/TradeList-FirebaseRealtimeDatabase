//
//  DetailViewController.swift
//  TradeList
//
//  Created by Türker on 13.10.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class DetailViewController: UIViewController {
    @IBOutlet private weak var categoryName: UILabel!
    @IBOutlet private weak var itemImage: UIImageView!
    @IBOutlet private weak var itemName: UILabel!
    @IBOutlet private weak var itemDate: UILabel!
    @IBOutlet private weak var itemDescription: UILabel!
    @IBOutlet private weak var itemPrice: UILabel!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    private var keyArray: [String] = []
    var selectedIndex: IndexPath?
    
    var itemSelected: Item?
    override func viewDidLoad() {
        super.viewDidLoad()
        configureOutlets()
        ref = Database.database().reference()
    }
    
}

// MARK: Outlets Configure Methods
extension DetailViewController {
    func configureOutlets() {
        categoryName.text = itemSelected?.category
        itemName.text = itemSelected?.title
        itemPrice.text = itemSelected?.price
        itemDescription.text = itemSelected?.descriptionItem
        itemDate.text = itemSelected?.dateItem
    }
}

// MARK: Customize Item Methods
extension DetailViewController {
    @IBAction func customizeButtonTapped(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        var textField2 = UITextField()
        var textField3 = UITextField()
        var textField4 = UITextField()
        
        let alert = UIAlertController(title: "Customize Item Info", message: "", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { dismissAction in
            self.dismiss(animated: true, completion: nil)
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (actionResponse) in
            let date = Date()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateformatter.string(from: date)
            
            let newItem = Item(category: textField.text ?? "", price: textField3.text ?? "", title: textField2.text ?? "", descriptionItem: textField4.text ?? "", dateItem: dateString)
            
            self.getAllKeys()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.updateItem(with: newItem)
            }
        
            let indexChangedItem = self.selectedIndex
            guard let itemVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "itemVC") as? ItemViewController else { return }
            itemVC.index = indexChangedItem
            self.navigationController?.pushViewController(itemVC, animated: true)
        }
        
        alert.addAction(action)
        alert.addAction(dismissAction)
        
        alert.addTextField { (alertTextField) in
            textField = alertTextField
            alertTextField.placeholder = "Enter Item Category"
        }
        
        alert.addTextField { (alertTextField2) in
            textField2 = alertTextField2
            alertTextField2.placeholder = "Enter Item Name"
        }
        
        alert.addTextField { (alertTextField3) in
            textField3 = alertTextField3
            alertTextField3.placeholder = "Enter Item Price"
        }
        
        alert.addTextField { (alertTextField4) in
            textField4 = alertTextField4
            alertTextField4.placeholder = "Enter Item Description"
        }
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: Firebase Methods
extension DetailViewController {
    
    func updateItem(with model: Item) {
        if let index = selectedIndex {
            ref.child("TradeItemsList").child(self.keyArray[index.row]).setValue(["ItemCategory": model.category, "ItemName": model.title, "ItemPrice": model.price, "ItemDescription": model.descriptionItem, "ItemDate": model.dateItem])
        }
    }
    
    func getAllKeys() {
        ref.child("TradeItemsList").observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let key = child.key
                self.keyArray.append(key)
            }
        }
    }
}
