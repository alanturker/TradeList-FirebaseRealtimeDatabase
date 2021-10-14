//
//  ViewController.swift
//  TradeList
//
//  Created by Türker on 13.10.2021.
//

import UIKit
import FirebaseFirestore
import FirebaseDatabase
import FirebaseAuth

class ItemViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var filterScreen: UIView!
    
    let db = Firestore.firestore()
    var ref: DatabaseReference!
    private var keyArray: [String] = []
    var index: IndexPath?
    
    static let listCell = "listCell"
    
    private var listArray: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        filterScreen.isHidden = true
        ref = Database.database().reference()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            self.loadItemData()
        }
       
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}

// MARK: TableView Delegate&DataSource Methods
extension ItemViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemViewController.listCell, for: indexPath) as? ItemListUITableViewCell else { return UITableViewCell() }
        cell.configureCellOutlets(model: listArray[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            getAllKeys()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.deleteData(index: indexPath)
                self.listArray.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = listArray[indexPath.row]
        let index = indexPath
        guard let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "detailVC") as? DetailViewController else { return }
        detailVC.itemSelected = selectedItem
        detailVC.selectedIndex = index
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

// MARK: Add Button Methods
extension ItemViewController {
    
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        var textField2 = UITextField()
        var textField3 = UITextField()
        var textField4 = UITextField()
        
        let alert = UIAlertController(title: "Add a New Product", message: "", preferredStyle: .alert)
        
        let dismissAction = UIAlertAction(title: "Dismiss", style: .destructive) { dismissAction in
            self.dismiss(animated: true, completion: nil)
        }
        
        let action = UIAlertAction(title: "Add", style: .default) { (actionResponse) in
            let date = Date()
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateformatter.string(from: date)
            
            let newItem = Item(category: textField.text ?? "", price: textField3.text ?? "", title: textField2.text ?? "", descriptionItem: textField4.text ?? "", dateItem: dateString)
            
            self.writeData(with: newItem)
            self.loadAddedData()
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
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

// MARK: FirebaseFirestore Methods
extension ItemViewController {
    
    func writeData(with model: Item) {
        ref?.child("TradeItemsList").childByAutoId().setValue(["ItemCategory": model.category, "ItemName": model.title, "ItemPrice": model.price, "ItemDescription": model.descriptionItem, "ItemDate": model.dateItem])
    }
    
    func loadItemData() {
        self.listArray = []
        self.ref.child("TradeItemsList").observeSingleEvent(of: .value, with: { snapshot in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                let value = child.value as? NSDictionary
                let itemCategory = value?["ItemCategory"] as? String ?? ""
                let itemName = value?["ItemName"] as? String ?? ""
                let itemPrice = value?["ItemPrice"] as? String ?? ""
                let itemDescription = value?["ItemDescription"] as? String ?? ""
                let itemDate = value?["ItemDate"] as? String ?? ""
                let newItem = Item(category: itemCategory, price: itemPrice, title: itemName, descriptionItem: itemDescription, dateItem: itemDate)
                self.listArray.append(newItem)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func loadAddedData() {
        self.ref.child("TradeItemsList").observeSingleEvent(of: .childAdded, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let itemCategory = value?["ItemCategory"] as? String ?? ""
            let itemName = value?["ItemName"] as? String ?? ""
            let itemPrice = value?["ItemPrice"] as? String ?? ""
            let itemDescription = value?["ItemDescription"] as? String ?? ""
            let itemDate = value?["ItemDate"] as? String ?? ""
            let newItem = Item(category: itemCategory, price: itemPrice, title: itemName, descriptionItem: itemDescription, dateItem: itemDate)
            self.listArray.append(newItem)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { error in
            print(error.localizedDescription)
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
    
    func deleteData(index: IndexPath) {
        ref.child("TradeItemsList").child(self.keyArray[index.row]).removeValue()
    }
}

// MARK: Filter Button Methods
extension ItemViewController {
    
    @IBAction func filterButtonTapped(_ sender: UIBarButtonItem) {
        filterScreen.isHidden = false
    }
    @IBAction func orderingPriceDescending(_ sender: UIButton) {
        filterScreen.isHidden = true
        listArray.sort(by: { (Double($0.price) ?? 0) > (Double($1.price) ?? 0) })
        tableView.reloadData()
    }
    
    @IBAction func orderingPriceAscending(_ sender: UIButton) {
        filterScreen.isHidden = true
        listArray.sort(by: { (Double($0.price) ?? 0) < (Double($1.price) ?? 0) })
        tableView.reloadData()
    }
    @IBAction func orderingNameDescending(_ sender: UIButton) {
        filterScreen.isHidden = true
        listArray.sort(by: { ($0.title).localizedCaseInsensitiveCompare($1.title) == .orderedDescending })
        tableView.reloadData()
    }
    @IBAction func orderingNameAscending(_ sender: UIButton) {
        filterScreen.isHidden = true
        listArray.sort(by: { ($0.title).localizedCaseInsensitiveCompare($1.title) == .orderedAscending })
        tableView.reloadData()
    }
    @IBAction func closeButtonTaped(_ sender: UIButton) {
        filterScreen.isHidden = true
    }
}

