//
//  ProductTableViewController.swift
//  ShoppingTracker
//
//  Created by zb-nju on 2020/11/12.
//

import UIKit
import os.log

class ProductTableViewController: UITableViewController {
    
    //MARK: Properties
    var products = [Product]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Use the edit button item provided by the table view controller
        navigationItem.leftBarButtonItem = editButtonItem
        
        if let savedProducts = loadProducts(){
            products += savedProducts
        }
        else{

            //Load the sample data.
            loadSampleProducts()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ProductTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProductTableViewCell else{
            fatalError("The dequeued cell is not an instance of ProductTableViewCell.")
        }
       
        //Fetches the appropriate product for the data source layout.
        let product = products[indexPath.row]
        
        cell.nameLabel.text = product.name
        cell.photoImageView.image = product.photo
        cell.ratingControl.rating = product.rating

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            products.remove(at: indexPath.row)
            saveProducts()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier ?? "" {
        
        case "AddItem":
            os_log("Adding a new product.", log:OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let productDetailViewController = segue.destination as? ProductViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedProductCell = sender as? ProductTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedProductCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedProduct = products[indexPath.row]
            productDetailViewController.product = selectedProduct
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
    
    //MARK: Actions
    @IBAction func unwindToProductList(sender: UIStoryboardSegue){
        if let sourceViewController = sender.source as? ProductViewController, let product = sourceViewController.product{
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                //Update an existing product
                products[selectedIndexPath.row] = product
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else{
                //Add a new product.
                let newIndexPath = IndexPath(row: products.count, section: 0)
                
                products.append(product)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            //Save the products.
            saveProducts()
        }
    }
    
    //MARK: Private Methods to modify
    private func loadSampleProducts(){
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        guard let product1 = Product(name: "Caprese Salad", photo: photo1, rating: 4) else {
            fatalError("Unable to instantiate product1")
        }
        
        guard let product2 = Product(name: "Chicken and Potatos", photo: photo2, rating: 5) else {
            fatalError("Unable to instantiate product2")
        }
        
        guard let product3 = Product(name: "Pasta with Meatballs", photo: photo3, rating: 3) else {
            fatalError("Unable to instantiate product3")
        }
        
        products += [product1, product2, product3]
    }

    private func saveProducts(){
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: products, requiringSecureCoding: false)
            try data.write(to: Product.ArchiveURL)
        }catch{
                os_log("Failed to save products...", log: OSLog.default, type: .error)
                return
        }
        os_log("Products succeessfully saved.", log: OSLog.default, type: .debug)
        return
    }
    
    private func loadProducts() -> [Product]? {
        do{
            let data = try Data(contentsOf: Product.ArchiveURL)
            let products = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [Product]
            os_log("Succeessfully save products.", log: OSLog.default, type: .debug)
            return products
        }catch{
            os_log("Failed to load products...", log: OSLog.default, type: .error)
            return []
        }
    }
}
