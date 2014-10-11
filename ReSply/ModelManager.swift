//
//  ModelManager.swift
//  ReSply
//
//  Created by Dave on 11.10.14.
//  Copyright (c) 2014 Zeno Koller. All rights reserved.
//

import UIKit

class ModelManager {
    let db: FMDatabase
    let listID = 1
    
    init() {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentDirectory: String = paths[0] as String
        let databasePath = documentDirectory.stringByAppendingPathComponent("data.db")
        var needsNewList = false
        
        // copy empty database if it doesn't exist
        if (NSFileManager.defaultManager().fileExistsAtPath(databasePath)) {
            let bundleDatabasePath = NSBundle.mainBundle().pathForResource("empty", ofType: ".db")
            
            if !NSFileManager.defaultManager().copyItemAtPath(bundleDatabasePath!, toPath: databasePath, error: nil) {
                println("Undable to copy database. Abort")
                abort() // stop running if the database can't be copied
            }
            
            needsNewList = true
        }
        
        db = FMDatabase(path: databasePath)
        
        if needsNewList == true {
            db.open()
            db.executeUpdate("insert into ShoppingList values(?)", withArgumentsInArray: [listID])
            db.close()
        }
    }
    
    func alreadyInProducts(ean: String) -> Bool {
        db.open()
        
        let result = db.executeQuery("select count(*) from Product where EAN=?", withArgumentsInArray: [ean])
        
        var count: Int32 = 0
        if result.next() {
            count = result.intForColumnIndex(0)
        }
        
        db.close()
        
        if (count > 0) { // that ean exist already and is returned
            return true
        } else { // that ean doen't exist already
            return false
        }
    }
    
    func insertProduct(ean: String, inList list: Int) -> Bool {
        db.open()
        
        let success = db.executeUpdate("insert into ShoppingList(listId, EAN, tickedOff, addedDate) values (?, ?, 0, ?)", withArgumentsInArray: [list, ean, currentTimestamp()])
        
        db.close()
        return success
    }
    
    func insertProduct(product: Product) -> Bool {
        return insertProduct(product.EAN, inProductAndList: self.listID, withName: product.name, andCategory: product.mainCategory)
    }
    
    func insertProduct(ean: String, inProductAndList list: Int, withName name: String, andCategory category: String) -> Bool {
        db.open()
        var success = false
        
        // add category
        let result = db.executeQuery("select count(*) from Category where categoryName=?", withArgumentsInArray: [category])
        if result.next() {
            if result.intForColumnIndex(0) == 0 {
                success = db.executeUpdate("insert into Category values (?)", withArgumentsInArray: [category])
            } else {
                success = true
            }
        }
        
        if success {
            if db.executeUpdate("insert into Product(EAN, name, creationDate, mainCategory) values (?, ?, ?, ?)", withArgumentsInArray: [ean, name, currentTimestamp(), category]) {
                success = self.insertProduct(ean, inList: list) // calls a second time db.open() and .close() this might lead to a bug (?)
            } else {
                success = false
            }
        }
        
        db.close()
        return success
    }
    
    func check(check: Bool, ean: String, inList list: Int) -> Bool {
        db.open()
        
        let success = db.executeUpdate("update ShoppingList set tickedOff=? where EAN=? and listId=?", withArgumentsInArray: [check, ean, list])
        
        db.close()
        return success
    }
    
    func getProductFor(ean: String, inList list: Int) -> Product? {
        db.open()
        
        let result = db.executeQuery("select * from Product p, ShoppingList l where p.EAN = l.EAN and p.EAN=? and l.listId=?", withArgumentsInArray: [ean, list])
        
        var product: Product?
        if (result.next()) {
            let ean = result.stringForColumn("EAN")
            let name = result.stringForColumn("name")
            let mainCategory = result.stringForColumn("mainCategory")
            let addedDate = NSDate(timeIntervalSince1970: result.doubleForColumn("creationDate"))
            let tickedOff = result.boolForColumn("tickedOff")
            product = Product(ean: ean, name: name, mainCategory: mainCategory, addedDate: addedDate, tickedOff: tickedOff)
        }
        
        db.close()
        return product
    }
    
    func getProductsFor(list: Int) -> [String: [Product]] {
        db.open()
        var products: [String: [Product]] = [String: [Product]]()
        
        let result = db.executeQuery("select * from Product p, ShoppingList l, Category c where p.ean = l.ean and c.categoryName = p.mainCategory and l.listId=? group by c.categoryName", withArgumentsInArray: [list])
        
        var product: Product
        while result.next() {
            let ean = result.stringForColumn("EAN")
            let name = result.stringForColumn("name")
            let mainCategory = result.stringForColumn("mainCategory")
            let addedDate = NSDate(timeIntervalSince1970: result.doubleForColumn("creationDate"))
            let tickedOff = result.boolForColumn("tickedOff")
            product = Product(ean: ean, name: name, mainCategory: mainCategory, addedDate: addedDate, tickedOff: tickedOff)
            
            if let array = products[mainCategory] as [Product]? {
                products[mainCategory]!.append(product)
            } else {
                products[mainCategory] = [Product]()
                products[mainCategory]!.append(product)
            }
        }
        
        
        return products
    }
    
    private func currentTimestamp() -> Int {
        return Int(NSDate().timeIntervalSince1970)
    }
    
}