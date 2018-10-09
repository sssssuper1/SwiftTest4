//
//  ViewController.swift
//  ZrySwiftTest4
//
//  Created by Edison on 2018/8/1.
//  Copyright © 2018年 Edison. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func getState(_ sender: UIButton) {
        loadData()
    }
    
    func loadData() {
        Alamofire.request("http://192.168.0.91:94/api/user/getStateNum").responseJSON {(response) in
            if let value = response.result.value {
                let json = JSON(value)
                
                for (index, value) in json {
                    print("\(index): \(value)")
                }
//                print(value)
            }
        }
    }
}

