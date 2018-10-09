//
//  BlueToothListController.swift
//  ZrySwiftTest4
//
//  Created by Edison on 2018/8/3.
//  Copyright © 2018年 Edison. All rights reserved.
//

import UIKit
import CoreBluetooth

class BlueToothListController: UITableViewController, CBCentralManagerDelegate {
    var isScanning = false
    var myCBCentralManager: CBCentralManager!
    var myPeripherals: NSMutableArray = NSMutableArray()
    var mainPeripheral: CBPeripheral!
    
    let alertConnect = UIAlertController(title: "连接中...", message: nil, preferredStyle: .alert)
    
    @IBAction func searchPeripherals(_ sender: UIBarButtonItem) {
        scan()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("蓝牙已开启")
        case .unauthorized:
            print("无蓝牙权限")
        case .poweredOff:
            print("蓝牙未开启")
        default:
            print("无变化")
        }
    }
    
    func scan() {
        if isScanning {
            myCBCentralManager.stopScan()
            isScanning = false
        } else {
            if myPeripherals.count > 0 {
                myPeripherals.removeAllObjects()
                tableView.reloadData()
            } else {
                self.myCBCentralManager.scanForPeripherals(withServices: nil, options: nil)
                isScanning = true
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let nsPeripheral = myPeripherals.value(forKey: "peripheral") as! NSArray
        if peripheral.name != nil && !nsPeripheral.contains(peripheral) {
            let r: NSMutableDictionary = NSMutableDictionary()
            r.setValue(peripheral, forKey: "peripheral")
            r.setValue(RSSI, forKey: "RSSI")
            r.setValue(advertisementData, forKey: "advertisementData")
            myPeripherals.add(r)
            print("搜索到设备，Name=\(peripheral.name!) UUID=\(peripheral.identifier)")
            
//            let indexPath = IndexPath(row: myPeripherals.count, section: 0)
//            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("已连接")
        alertConnect.dismiss(animated: true, completion: {
            self.performSegue(withIdentifier: "deviceConnected", sender: nil)
        })
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myCBCentralManager = CBCentralManager(delegate: self, queue: nil)
        alertConnect.addAction(UIAlertAction(title: "取消连接", style: .default, handler: { action in
            self.myCBCentralManager.cancelPeripheralConnection(self.mainPeripheral)
        }))
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return myPeripherals.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PeripheralCell", for: indexPath) as? PeripheralCell else {
            fatalError("celltype error")
        }
        
        let s:NSDictionary = myPeripherals[indexPath.row] as! NSDictionary
        let p:CBPeripheral = s.value(forKey: "peripheral") as! CBPeripheral
//        let d:NSDictionary = s.value(forKey: "advertisementData") as! NSDictionary
//        let rsi:NSNumber  = s.value(forKey: "RSSI") as! NSNumber
        
        cell.title.text = p.name
        cell.uuid.text = p.identifier.uuidString
        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        isScanning = false
        myCBCentralManager.stopScan()
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath) as! PeripheralCell
        alertConnect.message = cell.title.text
        self.present(alertConnect, animated: true, completion: nil)
        let myPeriDict:NSDictionary = myPeripherals[indexPath.row] as! NSDictionary
        mainPeripheral = myPeriDict.value(forKey:"peripheral") as! CBPeripheral
        myCBCentralManager.connect(mainPeripheral, options: nil)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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
        switch segue.identifier {
        case "deviceConnected":
            if let deviceController = segue.destination as? DeviceController {
                deviceController.mainPeripheral = self.mainPeripheral
                deviceController.myCBCentralManager = self.myCBCentralManager
            }
        default:
            break
        }
    }

}
