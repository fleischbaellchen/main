//
//  ViewController.swift
//  FMDB_test
//
//  Created by Dave on 11.10.14.
//  Copyright (c) 2014 ReSply. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dbPath = "/tmp/tmp.db"
        
        let fileManager = NSFileManager.defaultManager()
        fileManager.removeItemAtPath(dbPath, error: nil)
        
        let db = FMDatabase(path: dbPath)
        if db.open() {
            if !db.executeUpdate("create table Category (categoryName text)", withArgumentsInArray: nil) {
                println("error create table")
            }
            if !db.executeUpdate("insert into Category values (?)", withArgumentsInArray: ["Testcat"]) {
                println("error insert cat")
            }
            let result = db.executeQuery("select * from Category", withArgumentsInArray: nil)
            while result.next() {
                println(result.stringForColumn("categoryName"))
            }
            db.close()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

