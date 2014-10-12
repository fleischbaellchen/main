//
//  ViewController.swift
//  ReSply
//
//  Created by Zeno Koller on 11.10.14.
//  Copyright (c) 2014 Zeno Koller. All rights reserved.
//

import UIKit


class ViewController: UITableViewController, ScanViewControllerDelegate {
    
    let modelManager = ModelManager()

    var categorizedProducts: [String: [Product]!] = Dictionary<String, [Product]!>()
    
    // Calls Migros API to get Product
    func getProductFromAPI(EAN: String) {
        //let EAN = "7617027097710"
        let url = NSURL(string: "http://api.autoidlabs.ch//products/\(EAN)")
        let request = NSURLRequest(URL: url)
    
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response, data, error) in
    
                //println(NSString(data: data, encoding: NSUTF8StringEncoding))
    
                // Handle no network error
                if data == nil {
                    var alertController = UIAlertController(title: "Oops!", message: "Please check your network connection.", preferredStyle: .Alert)
                    var okAction = UIAlertAction(title: "Okay", style: .Default, handler: nil)
                    alertController.addAction(okAction)
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
    
                // Extract JSON and create Product
                let json = JSON(data: data)
                if json {
                    if let product = Product(data: json, ean: EAN) as Product? {
                        // check if key exists
                        if let arr = self.categorizedProducts[product.mainCategory] as [Product]? {
                            self.categorizedProducts[product.mainCategory]!.append(product)
                        } else {
                            self.categorizedProducts[product.mainCategory] = []
                            self.categorizedProducts[product.mainCategory]!.append(product)
                        }
                        self.modelManager.insertProduct(product)
                    } else {
                        println("Failed to create product")
                    }
                    
                } else {
                    // Handle no product data error!
                    // Maybe fallback to GS1 API?
                    println("No product data")
                }
            
                // Update table view
                self.tableView.reloadData()
        })
    }

    // Gets Product from DB
    func getProductFromDB(EAN: String) {
        if !modelManager.alreadyIn(modelManager.listID, ean: EAN) {
            if modelManager.insertProduct(EAN, inList: modelManager.listID) {
                if let product = modelManager.getProductFor(EAN, inList: modelManager.listID) {
                    if let arr = self.categorizedProducts[product.mainCategory] as [Product]? {
                        self.categorizedProducts[product.mainCategory]!.append(product)
                    } else {
                        self.categorizedProducts[product.mainCategory] = []
                        self.categorizedProducts[product.mainCategory]!.append(product)
                    }
                }
            } else {
                println("Failed to insert product into current list")
            }
        } else {
            // would be nice if it would work. you need to have to update the view, too
            modelManager.check(false, ean: EAN, inList: modelManager.listID) // uncheck item if it's checked
        }
    }
    
    @IBAction func clearShoppingList() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        let deleteAction = UIAlertAction(title: "Delete List", style: .Destructive) { (action) in
            
            var indexSet = NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections()))
            
            self.tableView.beginUpdates()
            self.tableView.deleteSections(indexSet, withRowAnimation: UITableViewRowAnimation.Fade)
            // Clear list
            self.categorizedProducts = Dictionary<String, [Product]!>()
            self.tableView.endUpdates()
        }
        alertController.addAction(deleteAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Fetch existing data
        self.categorizedProducts = modelManager.getProductsFor(modelManager.listID)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var key: String = Array(categorizedProducts.keys)[section]
        if let array = categorizedProducts[key] {
            return array.count
        }
        return 0
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categorizedProducts.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var key: String = Array(categorizedProducts.keys)[section]
        return key
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("productCell", forIndexPath: indexPath) as UITableViewCell
        
        var key: String = Array(categorizedProducts.keys)[indexPath.section]
        if let array = categorizedProducts[key] {
            if let product: Product = array[indexPath.row] as Product? {
                cell.textLabel?.text = product.name
                if product.tickedOff == false {
                    cell.textLabel?.textColor = UIColor.blackColor()
                    cell.imageView?.image = UIImage(named: "Checkbox.png")
                } else {
                    cell.textLabel?.textColor = UIColor.lightGrayColor()
                    cell.imageView?.image = UIImage(named: "Checkbox_checked.png")
                }
            } else {
                println("No product at index path \(indexPath.row)")
                
            }
        } else {
            println("No category at index path \(indexPath.section)")
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // update product status
        var key: String = Array(categorizedProducts.keys)[indexPath.section]
        if let products = categorizedProducts[key] as [Product]? {
            let product = products[indexPath.row];
            let status = product.toggleTickedOff()
            modelManager.check(status, ean: product.EAN, inList: modelManager.listID)
        }
                
        // reload data
        self.tableView.reloadData()
        
        // deselect row
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // from http://www.raywenderlich.com/50310/storyboards-tutorial-in-ios-7-part-2
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // this if triggers a runtime error and i don't know why
        //if segue.identifier == "ScanViewController" {
            // from http://makeapppie.com/2014/07/05/using-delegates-and-segues-part-2-the-pizza-demo-app/
            var scanViewController = segue.destinationViewController as? ScanViewController
            scanViewController?.delegate = self
        //}
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var key: String = Array(categorizedProducts.keys)[indexPath.section]
        var indexSet = NSMutableIndexSet()
        self.categorizedProducts[key]?.removeAtIndex(indexPath.row)
        if self.categorizedProducts[key]?.count == 0 {
            self.categorizedProducts.removeValueForKey(key)
            indexSet.addIndex(indexPath.section)
            self.tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    //MARK: - ScanViewControllerDelegate
    func scanViewControllerDidStopScanning(controller: ScanViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func scanViewControllerScanned(barcode: String) {
        if self.modelManager.alreadyInProducts(barcode) {
            getProductFromDB(barcode)
        } else {
            getProductFromAPI(barcode)
        }
    }
    
}

