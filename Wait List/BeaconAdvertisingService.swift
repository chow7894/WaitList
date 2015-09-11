/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import CoreBluetooth
import CoreLocation
import UIKit

private let _singletonInstance = BeaconAdvertisingService()

class BeaconAdvertisingService: NSObject {
  class var sharedInstance: BeaconAdvertisingService {
    return _singletonInstance
  }
  
  let bluetoothStateErrorDomain = "com.razeware.waitlist.bluetoothstate"
  dynamic private(set) var advertising = false
  
  private var peripheralManager: CBPeripheralManager!
  
  override init() {
    super.init()
    peripheralManager = CBPeripheralManager(delegate: self, queue: dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0))
    
  }
  
  func startAdvertising(#uuid: NSUUID, major: CLBeaconMajorValue, minor: CLBeaconMinorValue) {
    var bluetoothState = obtainBluetoothState()
    if bluetoothState.valid == false {
      if bluetoothState.valid == false {
        if let error = bluetoothState.error {
          presentBluetoothError(error.userInfo?["message"] as? String ?? "Unknown")
        }
      }
    } else {
      let region = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: "com.razeware.waitlist")
      let peripheralData = region.peripheralDataWithMeasuredPower(nil) as NSDictionary
      peripheralManager.startAdvertising(peripheralData as [NSObject : AnyObject])
    }
  }
  
  func stopAdvertising() {
    peripheralManager.stopAdvertising()
    advertising = false
  }
  
  func obtainBluetoothState() -> (valid: Bool, error: NSError?) {
    
    var state: (Bool, NSError?) = (true, nil)
    
    switch (peripheralManager.state) {
    case .PoweredOff:
      let error = NSError(domain: bluetoothStateErrorDomain,
        code: CBPeripheralManagerState.PoweredOff.rawValue,
        userInfo: ["message": "You must turn Bluetooth on in order to use the beacon feature."])
      state = (false, error)
    case .Resetting:
      let error = NSError(domain: bluetoothStateErrorDomain,
        code: CBPeripheralManagerState.Resetting.rawValue,
        userInfo: ["message": "Bluetooth is not available at this time, please try again in a moment."])
      state = (false, error)
    case .Unauthorized:
      let error = NSError(domain: bluetoothStateErrorDomain,
        code: CBPeripheralManagerState.Unauthorized.rawValue,
        userInfo: ["message": "This application is not authorized to use Bluetooth, verify your settings or check with your device's administrator."])
      state = (false, error)
    case .Unknown:
      let error = NSError(domain: bluetoothStateErrorDomain,
        code: CBPeripheralManagerState.Unknown.rawValue,
        userInfo: ["message": "Bluetooth is not available at this time, please try again in a moment."])
      state = (false, error)
    case .Unsupported:
      let error = NSError(domain: bluetoothStateErrorDomain,
        code: CBPeripheralManagerState.Unsupported.rawValue,
        userInfo: ["message": "Your device does not support Bluetooth. You will not be able to use the beacon feature."])
      state = (false, error)
    case .PoweredOn:
      state = (true, nil)
    }
    
    return state
  }
  
  func presentBluetoothError(errorMessage: String) {
    let alert = UIAlertController(title: "Bluetooth Issue",
      message: errorMessage,
      preferredStyle: .Alert)
    
    let okAction = UIAlertAction(title: "OK", style: .Default) { action in
      alert.dismissViewControllerAnimated(true, completion: nil)
    }
    
    alert.addAction(okAction)
    UIApplication.sharedApplication().keyWindow?.rootViewController?.presentViewController(alert, animated: true, completion: nil)
  }
}

extension BeaconAdvertisingService: CBPeripheralManagerDelegate {
  
  func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager!) {
    let bluetoothState = obtainBluetoothState()
    if bluetoothState.valid == false {
      if let error = bluetoothState.error {
        NSOperationQueue.mainQueue().addOperationWithBlock {
          self.presentBluetoothError(error.userInfo?["message"] as? String ?? "Unknown")
        }
      }
    }
  }
  
  func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager!, error: NSError!) {
    if error != nil {
      NSOperationQueue.mainQueue().addOperationWithBlock {
        self.presentBluetoothError("There was an issue starting the advertisement of your beacon.")
        println("Advertising error: \(error)")
      }
    } else {
      println("Advertising!")
      advertising = true
    }
  }
}