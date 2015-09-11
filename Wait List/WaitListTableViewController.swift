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
import UIKit
import MultipeerConnectivity

extension UIColor {
  var grayscale: UIColor {
    get {
      var red: CGFloat = 0.0
      var blue: CGFloat = 0.0
      var green: CGFloat = 0.0
      var alpha: CGFloat = 0.0
      if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
        return UIColor(white: 0.299*red + 0.587*green + 0.114*blue, alpha: alpha)
      } else {
        return self
      }
    }
  }
}

extension UITableView {
  public override func tintColorDidChange() {
    super.tintColorDidChange()
    UIView.animateWithDuration(0.3) { _ in
      if self.backgroundView != nil {
        if self.tintAdjustmentMode == .Dimmed {
          self.backgroundView!.backgroundColor = self.backgroundView!.backgroundColor!.grayscale;
        } else {
          self.backgroundView!.backgroundColor = UIColor(red: 252.0/255.0, green: 237.0/255.0, blue: 224.0/255.0, alpha: 1.0)
        }
      }
    }
  }
}

extension UINavigationBar {
  public override func tintColorDidChange() {
    super.tintColorDidChange()
    UIView.animateWithDuration(0.3) { _ in
      if self.tintAdjustmentMode == .Dimmed {
        self.barTintColor = self.barTintColor?.grayscale
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
      } else {
        self.barTintColor = UIColor(red: 231.0/255.0, green: 113.0/255.0, blue: 37.0/255.0, alpha: 1.0)
        self.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 252.0/255.0, green: 234.0/255.0, blue: 218.0/255.0, alpha: 1.0)]
      }
    }
  }
}

class WaitListTableViewController: UITableViewController, UIActionSheetDelegate {
  
  var addGuestButton: UIBarButtonItem!
  var startBeaconButton: UIBarButtonItem!
  var stopBeaconButton: UIBarButtonItem!
  
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  
    self.addGuestButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addGuestButtonTouched:")
    self.startBeaconButton = UIBarButtonItem(title: "Start Beacon", style: .Plain, target: self, action: "startAdvertising")
    self.stopBeaconButton = UIBarButtonItem(title: "Stop Beacon", style: .Plain, target: self, action: "stopAdvertising")
    BeaconAdvertisingService.sharedInstance.addObserver(self, forKeyPath: "advertising", options: .New, context: nil)
    self.updateAdvertiseButton()
  
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    let tableBackgroundView = UIView(frame: view.frame)
    tableBackgroundView.backgroundColor = UIColor(red: 252.0/255.0, green: 237.0/255.0, blue: 224.0/255.0, alpha: 1.0)
    tableView.backgroundView = tableBackgroundView
    
    navigationItem.rightBarButtonItem = addGuestButton
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    MultipeerConnectivityService.sharedInstance.advertise(name: "Host Stand")
    MultipeerConnectivityService.sharedInstance.delegate = self
  }
  
  override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
    if (keyPath == "advertising") {
      updateAdvertiseButton()
    }
  }
  
  func startAdvertising() {
    
    let alert = UIAlertController(title: "Select Beacon", message: nil, preferredStyle: .ActionSheet)
    alert.view.tintColor = UIColor(red: 231.0/255.0, green: 113.0/255.0, blue: 37.0/255.0, alpha: 1.0)
    alert.modalPresentationStyle = .Popover
    alert.popoverPresentationController?.barButtonItem = startBeaconButton
    
    let cupcakesAction = UIAlertAction(title: "Core Cupcakes", style: .Default) { action in
      if let cupcakesUUID = NSUUID(UUIDString: "EC6F3659-A8B9-4434-904C-A76F788DAC43") {
        BeaconAdvertisingService.sharedInstance.startAdvertising(uuid: cupcakesUUID, major: 0, minor: 0)
        self.navigationItem.title = action.title
      }
    }
    alert.addAction(cupcakesAction)
    
    let saladsAction = UIAlertAction(title: "@synthesize salads", style: .Default) { action in
      if let saladsUUID = NSUUID(UUIDString: "7B377E4A-1641-4765-95E9-174CD05B6C79") {
        BeaconAdvertisingService.sharedInstance.startAdvertising(uuid: saladsUUID, major: 0, minor: 0)
        self.navigationItem.title = action.title
      }
    }
    alert.addAction(saladsAction)
    
    
    let wrapsAction = UIAlertAction(title: "Weak Wraps", style: .Default) { action in
      if let wrapsUUID = NSUUID(UUIDString: "2B144D35-5BA6-4010-B276-FC4D4845B292") {
        BeaconAdvertisingService.sharedInstance.startAdvertising(uuid: wrapsUUID, major: 0, minor: 0)
        self.navigationItem.title = action.title
      }
    }
    alert.addAction(wrapsAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func stopAdvertising() {
    BeaconAdvertisingService.sharedInstance.stopAdvertising()
  }
  
  func addGuestButtonTouched(sender: UIBarButtonItem) {
    if let addGuestForm = storyboard?.instantiateViewControllerWithIdentifier("AddGuestForm") as? UINavigationController {
      addGuestForm.modalPresentationStyle = UIModalPresentationStyle.FormSheet
      self.presentViewController(addGuestForm, animated: true, completion: nil)
      let addGuestTableViewController = addGuestForm.topViewController as! AddGuestTableViewController
      addGuestTableViewController.delegate = self;
    }
  }
  
  func updateAdvertiseButton() {
    NSOperationQueue.mainQueue().addOperationWithBlock {
      if BeaconAdvertisingService.sharedInstance.advertising == true {
        self.navigationItem.rightBarButtonItems = [self.addGuestButton, self.stopBeaconButton]
      } else {
        self.navigationItem.rightBarButtonItems = [self.addGuestButton, self.startBeaconButton]
      }
    }
  }
  
  
}

extension WaitListTableViewController: AddGuestDelegate {
  func guestAdded(guest: Guest, atIndex: NSInteger) {
    tableView.beginUpdates()
    let newIndexPath = NSIndexPath(forRow: atIndex, inSection: 0)
    tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    tableView.endUpdates()
  }
}


// MARK: Table View Data Source & Delegate
extension WaitListTableViewController {
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return GuestService.sharedInstance.guests.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Guest", forIndexPath: indexPath) as! GuestCell
    let guest = GuestService.sharedInstance.guests[indexPath.row]
    
    if indexPath.row % 2 == 0 {
      cell.evenRow = true
    } else {
      cell.evenRow = false
    }
    
    cell.guest = guest
    cell.numberLabel.text = "\(indexPath.row+1)"
    cell.setupCell()
    
    return cell
  }
  
  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let headerView = NSBundle.mainBundle().loadNibNamed("GuestListHeaderView", owner: nil, options: nil)[0] as! UIView
    return headerView
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    let guest = GuestService.sharedInstance.guests[indexPath.row]
    
    let alert = UIAlertController(title: guest.name, message: guest.notes, preferredStyle: .Alert)
    
    let seatAction = UIAlertAction(title: "Seat", style: .Default) { (action) -> Void in
      self.seatOrRemove(guest, indexPath: indexPath)
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    alert.addAction(seatAction)
    
    let editAction = UIAlertAction(title: "Edit", style: .Default) { (action) -> Void in
      if let addGuestForm = self.storyboard?.instantiateViewControllerWithIdentifier("AddGuestForm") as? UINavigationController {
        addGuestForm.modalPresentationStyle = .FormSheet
        self.presentViewController(addGuestForm, animated: true, completion: nil)
        let addGuestTableViewController = addGuestForm.topViewController as! AddGuestTableViewController
        addGuestTableViewController.guest = guest
        addGuestTableViewController.delegate = self
      }
    }
    alert.addAction(editAction)
    
    let removeAction = UIAlertAction(title: "Remove", style: .Default) { (action) -> Void in
      self.seatOrRemove(guest, indexPath: indexPath)
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    alert.addAction(removeAction)
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
      self.dismissViewControllerAnimated(true, completion: nil)
    }
    alert.addAction(cancelAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  func seatOrRemove(guest: Guest, indexPath: NSIndexPath) {
    tableView.beginUpdates()
    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    GuestService.sharedInstance.removeGuest(guest)
    tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Fade)
    tableView.endUpdates()
  }
}

extension WaitListTableViewController: MultipeerConnecivityServiceDelegate {
  func didChangeState(state: MCSessionState, forPeer peer: MCPeerID) {
    println("State Changed \(state) for Peer: \(peer.displayName)")
  }
  
  func didReceiveData(data: NSData, fromPeer peer: MCPeerID) {
    NSOperationQueue.mainQueue().addOperationWithBlock{
      if let guestInfo = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String: String]  {
        let name = guestInfo["name"] ?? "No Name"
        let partySize = guestInfo["partySize"]?.toInt() ?? 0
        let arrivalTime = NSDate()
        let quotedTime = 5
        let mood = Mood.Happy
        let notes = "Added self to list"
        
        let guest = Guest(name: name, partySize: partySize, arrivalTime: arrivalTime, quotedTime: quotedTime, mood: mood, notes: notes)
        let index = GuestService.sharedInstance.addGuest(guest)
        self.guestAdded(guest, atIndex: index)
      }
    }
  }
}