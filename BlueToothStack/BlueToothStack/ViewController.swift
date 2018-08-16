//
//  ViewController.swift
//  BlueToothStack
//
//  Created by Manjunath Shivakumara on 04/01/18.
//  Copyright © 2018 Manjunath Shivakumara. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UICollectionViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    
    var myCentralManager : CBCentralManager!
    var discoveredPheriperals : NSMutableArray = NSMutableArray()
    var alreadyDiscovered : NSMutableArray!
    
//    @IBOutlet var currentStatus : UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.collectionView?.alwaysBounceVertical = true
        let gradient = CAGradientLayer()
        
        gradient.frame = view.bounds
        let myTopcolor = UIColor(red: 1.0/255.0, green: 16.0/255.0, blue: 27.0/255.0, alpha: 1.0)
        let myMiddlecolor = UIColor(red: 13.0/255.0, green: 52.0/255.0, blue: 89.0/255.0, alpha: 1.0)
        let myBottomcolor = UIColor(red: 18.0/255.0, green: 62.0/255.0, blue: 104.0/255.0, alpha: 1.0)
        
        gradient.colors = [myTopcolor.cgColor, myMiddlecolor.cgColor, myBottomcolor.cgColor]
        
        view.layer.zPosition = -1
        view.layer.insertSublayer(gradient, at: 0)
        collectionView?.backgroundColor = UIColor.clear
        
        
        NotificationCenter.default .addObserver(self, selector: #selector(whenViewAppears), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        self.navigationItem.title = "Breathe Mapper"
        
        //Setup Collection View Flow layout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: CGFloat(view.frame.size.width / 2)-8, height: 100.0)
        flowLayout.sectionInset = UIEdgeInsetsMake(4, 4, 4, 4)
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 5
        self.collectionView?.collectionViewLayout = flowLayout
        self.collectionView?.showsVerticalScrollIndicator = false
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self .whenViewAppears()
    }
    
    @objc func whenViewAppears()
    {
        alreadyDiscovered = NSMutableArray.init()
//        currentStatus.text = "Looking for Bluetooth Connection status"
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.myCentralManager = CBCentralManager.init(delegate: self, queue: nil, options: nil)
        }
    }
}

extension ViewController
{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .poweredOff:
            print("Powered Off")
//            currentStatus.text = "Bluetooth Powered Off"
            break
        case .poweredOn:
            print("Powered On")
//            currentStatus.text = "Bluetooth Powered On! Scanning for SGr123"
            central.scanForPeripherals(withServices: nil, options: nil)
            break
        case .unknown:
            print("Unknown")
            break
        case .unsupported:
            print("Unsupported")
            break
        case .unauthorized:
            print("UnAuthorised")
            break
        case .resetting:
//            currentStatus.text = "Bluetooth Resetting"
            print("Resetting")
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("Discovered - \(peripheral)")
        discoveredPheriperals .add(peripheral)
        
        if !alreadyDiscovered.contains(peripheral)
        {
           if peripheral.name != nil
           {
            alreadyDiscovered .add(peripheral)
            self.collectionView? .reloadData()
           }
           
        }
//        if peripheral.name == "SGr123"
//        {
//            currentStatus.text = "Found SGr123. Connecting!!!"
//            central.connect(peripheral, options: nil)
//        }
//        else
//        {
//            currentStatus.text = "Could not find SGr123. Failed!!!"
//        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        collectionView?.reloadData()
//        let connected = "Connected: \(peripheral.state == .connected ? "YES" : "NO")"
//        if connected == "YES"
//        {
////            currentStatus.text = "Connected to SGr123"
//            print("connected")
//        }
//        else
//        {
////            currentStatus.text = "Could not connect to SGr123"
//            print("not connected")
//        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
//        currentStatus.text = "Disconnected from SGr123"
        collectionView?.reloadData()

    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
}

extension ViewController
{
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for service : CBService in peripheral.services!
        {
            print("Peripheral - \(peripheral), Services - \(service)")
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        for characteristic : CBCharacteristic in service.characteristics!{
            peripheral.setNotifyValue(true, for: characteristic)
            print("service - \(service), characteristic - \(characteristic)")
        }
    }
}

extension ViewController
{
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.alreadyDiscovered.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell! = collectionView.dequeueReusableCell(withReuseIdentifier: "myElements", for: indexPath)
        
        let myLbl =  cell.contentView.viewWithTag(10) as! UILabel
        let myPheripheral : CBPeripheral = alreadyDiscovered.object(at: indexPath.row) as! CBPeripheral
        print("my pheripheral name \(String(describing: myPheripheral.name))")
        
        
        if myPheripheral.name != nil
        {
            myLbl.text = myPheripheral.name!
        }
        else
        {
            myLbl.text = "No name"
        }
        
        switch myPheripheral.state.rawValue {
        case 0:
            myLbl.textColor = UIColor.red
            myLbl.textAlignment = NSTextAlignment.center
        case 1:
            myLbl.textColor = UIColor.magenta
            myLbl.textAlignment = NSTextAlignment.center
        default:
            myLbl.textColor = UIColor.green
            myLbl.textAlignment = NSTextAlignment.center
        }
        
        cell.backgroundColor = UIColor.clear
        cell.layer.masksToBounds = false
        cell.layer.shadowOpacity = 0.75
        cell.layer.shadowRadius = 2.0
        cell.layer.shadowOffset = CGSize.zero
        cell.layer.borderColor = UIColor.white.cgColor
        cell.layer.borderWidth = 2.0
        cell.layer.cornerRadius = 10.0
        cell.layer.shouldRasterize = false
        
        return cell

    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let myPheripheral : CBPeripheral = alreadyDiscovered.object(at: indexPath.row) as! CBPeripheral
        switch myPheripheral.state.rawValue {
        case 0:
            myCentralManager.connect(myPheripheral, options: nil)
        case 1:
            print("connecting")
            collectionView.reloadData()
        default:
            myCentralManager.cancelPeripheralConnection(myPheripheral)
        }
        
        
    }
}

