//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

class ToDoListViewController: UITableViewController, UIPickerViewDelegate, UIImagePickerControllerDelegate {
    
    let realm = try! Realm()
    
    var itemArray : Results<Item>?
    
    var selectedCategory: Category?{
        didSet{
            loadItems()
        }
    }
    
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        
        if let item = itemArray?[indexPath.row]{
            cell.textLabel?.text = item.title
            
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //MARK: Update the checkmark in Realm
        if let item = itemArray? [indexPath.row]{
            do{
                try realm.write {
                    item.done = !item.done
                }
            } catch {
                print("Error update the files, \(error.localizedDescription)")
            }
        }
        
        //MARK: Delete the selected row in Realm
        //        if let item = itemArray? [indexPath.row]{
        //                   do{
        //                       try realm.write {
        //                        realm.delete(item)
        //                       }
        //                   } catch {
        //                       print("Error update the files, \(error.localizedDescription)")
        //                   }
        //               }
        
        tableView.reloadData()
        
        //        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        //        saveItems()
        
//        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    
    @IBAction func addButtonClicked(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item here", style: .default) { (action) in
            print(textField.text!)
            
            
            //MARK: Add new item in Realm
            if let currentCategory = self.selectedCategory{
                do{
                    try self.realm.write{
                        let newItem = Item()
                        newItem.title = textField.text!
                        newItem.done = false
                        newItem.dateCreated = Date()
                        currentCategory.items.append(newItem)
                    }
                    
                } catch {
                    print("Error saving new items, \(error.localizedDescription)")
                }
                
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Write here..."
            
            textField = alertTextField
            
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
        
    }
    
    func saveItems(item: Item){
        
        do{
            try realm.write {
                realm.add(item)
            }
        } catch {
            print("Error saving context, \(error.localizedDescription) ")
        }
        self.tableView.reloadData()
    }
    
    func loadItems(){
        
        itemArray = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        
        tableView.reloadData()
    }
    
}

//MARK: EXTENSION

extension ToDoListViewController: UISearchBarDelegate{
    
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            
            itemArray = itemArray?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)

            searchBar.text = ""
            
            tableView.reloadData()
    
        }
    
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if searchBar.text?.count == 0{
                loadItems()
    
                DispatchQueue.main.async {
                    searchBar.resignFirstResponder()
                }
    
            }
    
        }
}

