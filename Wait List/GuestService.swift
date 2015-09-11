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

private let _singletonInstance = GuestService()
class GuestService {
  
  class var sharedInstance: GuestService {
    return _singletonInstance
  }
  
  let arrivalDateFormatter: NSDateFormatter = {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "hh:mm a"
    return dateFormatter
    }()
  
  lazy private(set) var guests: [Guest] = {
    if NSFileManager.defaultManager().fileExistsAtPath(self.guestsFilePath) {
      return NSKeyedUnarchiver.unarchiveObjectWithFile(self.guestsFilePath) as! [Guest]
    } else {
      return [Guest]()
    
    }
    }()
  
  private let guestsFilePath = NSHomeDirectory().stringByAppendingPathComponent("/Documents/guests.dat")
  
  func writeGuestsToDisk() {
    let data = NSKeyedArchiver.archivedDataWithRootObject(guests)
    if data.writeToFile(guestsFilePath, atomically: true) {
      println("Guest data persisted to disk")
    } else {
      println("Could not persist guest data to disk")
    }
  }
  
  func addGuest(guest: Guest) -> Int {
    guests.sort { (g1, g2) -> Bool in
      g1.arrivalTime.compare(g2.arrivalTime) == NSComparisonResult.OrderedDescending
    }
    
    var insertedAtIndex = 0
    if let index = find(guests, guest) {
      guests.insert(guest, atIndex: index)
      insertedAtIndex = index
    } else {
      guests.append(guest)
      insertedAtIndex = guests.count-1
    }
    
    writeGuestsToDisk()
    return insertedAtIndex
  }
  
  func removeGuest(guest: Guest) {
    if let index = find(guests, guest) {
      guests.removeAtIndex(index)
    }
  }
}