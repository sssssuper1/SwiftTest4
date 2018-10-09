//
//  DeviceController.swift
//  ZrySwiftTest4
//
//  Created by Edison on 2018/8/3.
//  Copyright © 2018年 Edison. All rights reserved.
//

import UIKit
import CoreBluetooth

class DeviceController: UIViewController, CBPeripheralDelegate, UITextFieldDelegate {


    @IBOutlet weak var deviceName: UILabel!
    @IBOutlet weak var characterTextView: UITextView!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var writeTextField: UITextField!
    @IBOutlet weak var writeSwitch: UISwitch!
    
    @IBOutlet weak var manufacturer: UILabel!
    @IBOutlet weak var firmware: UILabel!
    @IBOutlet weak var hardware: UILabel!
    @IBOutlet weak var serial: UILabel!
    @IBOutlet weak var power: UILabel!
    @IBOutlet weak var speed: UILabel!
    
    let CIRCLEFERENCE = 2.096
    
    var mainPeripheral: CBPeripheral!
    var myCBCentralManager: CBCentralManager!
    var cyclingPowerCharacteristics = [String: CBCharacteristic]()
    var wahooMeasurement = WahooMeasurement()
    
    var lastTime : Float = 0
    var lastRevolution : Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        writeTextField.delegate = self
        setInfo()
        searchServices()
    }
    
    @IBAction func readData(_ sender: UIButton) {
        if mainPeripheral.state == .connected {
            if let sensor = cyclingPowerCharacteristics["2A5D"] {
                // Sensor Location
                mainPeripheral.readValue(for: sensor)
            }
            
            if let feature = cyclingPowerCharacteristics["2A65"] {
                // Cycling Power Feature
                mainPeripheral.readValue(for: feature)
            }
            
        }
    }
    
    @IBAction func swichNotify(_ sender: UISwitch) {
        if let cyclingPowerCT = cyclingPowerCharacteristics["2A63"] {
            if notifySwitch.isOn {
                mainPeripheral.setNotifyValue(true, for: cyclingPowerCT)
            } else {
                mainPeripheral.setNotifyValue(false, for: cyclingPowerCT)
            }
        }
    }
    
    @IBAction func turnONWrite(_ sender: UISwitch) {
        if let writer = cyclingPowerCharacteristics["A026E005-0A7D-4AB3-97FA-F1500F9FEB8B"] {
            if writeSwitch.isOn {
                mainPeripheral.setNotifyValue(true, for: writer)
                mainPeripheral.writeValue(Data(bytes: [32, 0xee, 0xfc]), for: writer, type: .withResponse)
            } else {
                mainPeripheral.setNotifyValue(false, for: writer)
            }
        }
    }
    
    // standard model
    @IBAction func writeData(_ sender: UIButton) {
        if mainPeripheral.state == .connected {
            if let textData = writeTextField.text {
                let level = UInt8(textData)!
                if level >= 0 {
                    let standardModeLevel : [UInt8] = [65, level]
                    print(standardModeLevel)
                    if let writer = cyclingPowerCharacteristics["A026E005-0A7D-4AB3-97FA-F1500F9FEB8B"] {
                        
                        mainPeripheral.writeValue(Data(bytes: standardModeLevel), for: writer, type: .withResponse)
                    }
                }
            }
        }
    }
    
    // ERG model
    @IBAction func setToERG(_ sender: UIButton) {
        if mainPeripheral.state == .connected {
            if let textData = writeTextField.text {
                let watts = UInt16(textData)!
                if watts >= 0 {
                    let ergModelData : [UInt8] = [66, UInt8(watts & 0xFF), UInt8(watts >> 8 & 0xFF)]
                    print(ergModelData)
                    if let writer = cyclingPowerCharacteristics["A026E005-0A7D-4AB3-97FA-F1500F9FEB8B"] {
                        mainPeripheral.writeValue(Data(bytes: ergModelData), for: writer, type: .withResponse)
                    }
                }
            }
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        writeTextField.resignFirstResponder()
        return true
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("搜索到服务")
        if let services = peripheral.services {
            print("服务数: \(services.count)")
            for service in services {
                print(service)
                mainPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        switch service.uuid.uuidString {
        // Device Information
        case "180A":
            getDeviceInfo(by: service)
        case "1818":
            if let characteristics = service.characteristics {
                for character in characteristics {
                    // print(character)
                    // let properties = propertiesString(characteristic: character)
                    // print("属性: \(properties!)")
                    let key = character.uuid.uuidString
                    cyclingPowerCharacteristics[key] = character
                }
            }
        default:
            break
        }
    }
    
    // 响应读取(read/notify)
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            if let value = characteristic.value {
                switch characteristic.service.uuid.uuidString {
                // 设备信息
                case "180A":
                    let str = String(data: value, encoding: .utf8)
                    switch characteristic.uuid.uuidString {
                    case "2A29":
                        manufacturer.text = str
                    case "2A26":
                        firmware.text = str
                    case "2A27":
                        hardware.text = str
                    case "2A25":
                        serial.text = str
                    default:
                        break
                    }
                // 骑行台数据
                case "1818":
                    switch characteristic.uuid.uuidString {
                    case "2A5D":
                        let sl = [UInt8](value)
                        characterTextView.insertText("Sensor Location: \(sl[0])\n")
                    case "2A65":
                        let feature = [UInt8](value)
                        var str = ""
                        for ft in feature {
                            str += ("00000000" + String(ft, radix: 2)).suffix(8)
                        }
                        characterTextView.insertText("Feature: \(str) \n")
                    case "2A63":
                        wahooMeasurement.wahooCyclingPowerMeasurementUpdate(value)
                        let timeSlot = (Float(wahooMeasurement.speedTime1024) - lastTime)/2048
                        let revolution = Float(wahooMeasurement.speedEventCount) - lastRevolution
                        
                        if self.lastTime > 0 && self.lastRevolution > 0 && revolution >= 0 && timeSlot >= 0 {
                            let kph = revolution * 3.6 * 2.096 / timeSlot
                            speed.text = "\(String(format: "%.1f", kph)) kph"
                        }
                        power.text = String(wahooMeasurement.instantaneousPower)
                        
                        self.lastTime = Float(wahooMeasurement.speedTime1024)
                        self.lastRevolution = Float(wahooMeasurement.speedEventCount)
                    default:
                        break
                    }
                default:
                    break
                }
                
            }
        }
    }
    
    // 响应写入(write)
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            let responese = [UInt8](characteristic.value!)
            print("写入成功，数据：\(responese)成功")
            characterTextView.insertText("写入成功，数据：\(responese)成功\n")
        } else {
            print("写入错误 \(error.debugDescription)")
            characterTextView.insertText("写入错误 \(error.debugDescription)\n")
        }
    }
    
    private func setInfo() {
        deviceName.text = mainPeripheral.name
    }
    
    private func searchServices() {
        if (mainPeripheral.state == .connected) {
            self.mainPeripheral.delegate = self
            mainPeripheral.discoverServices(nil)
        }
    }
    
    // 获取设备信息(0x180A)
    private func getDeviceInfo(by service: CBService) {
        if let characteristics = service.characteristics {
            if mainPeripheral.state == .connected {
                for character in characteristics {
                    mainPeripheral.readValue(for: character)
                }
            }
        }
    }
    
    //显示属性权限
    func propertiesString(characteristic: CBCharacteristic)->(String)!{
        let properties = characteristic.properties
        var propertiesReturn : String = ""
        // Just to see what we are dealing with
        if (properties.rawValue & CBCharacteristicProperties.broadcast.rawValue) != 0 {
            propertiesReturn += "broadcast|"
        }
        if (properties.rawValue & CBCharacteristicProperties.read.rawValue) != 0 {
            propertiesReturn += "read|"
        }
        if (properties.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue) != 0 {
            propertiesReturn += "write without response|"
        }
        if (properties.rawValue & CBCharacteristicProperties.write.rawValue) != 0 {
            propertiesReturn += "write|"
        }
        if (properties.rawValue & CBCharacteristicProperties.notify.rawValue) != 0 {
            propertiesReturn += "notify|"
        }
        if (properties.rawValue & CBCharacteristicProperties.indicate.rawValue) != 0 {
            propertiesReturn += "indicate|"
        }
        if (properties.rawValue & CBCharacteristicProperties.authenticatedSignedWrites.rawValue) != 0 {
            propertiesReturn += "authenticated signed writes|"
        }
        if (properties.rawValue & CBCharacteristicProperties.extendedProperties.rawValue) != 0 {
            propertiesReturn += "indicate|"
        }
        if (properties.rawValue & CBCharacteristicProperties.notifyEncryptionRequired.rawValue) != 0 {
            propertiesReturn += "notify encryption required|"
        }
        if (properties.rawValue & CBCharacteristicProperties.indicateEncryptionRequired.rawValue) != 0 {
            propertiesReturn += "indicate encryption required|"
        }
        return propertiesReturn
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        print(segue.identifier ?? "no identify")
        myCBCentralManager.cancelPeripheralConnection(mainPeripheral)
    }

}
