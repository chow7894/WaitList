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

import UIKit

enum Mood: Int {
  case Happy
  case Meh
  case Unhappy
  
  var image: UIImage {
    get {
      switch self {
      case .Happy:
        return UIImage(named: "Happy")!.imageWithRenderingMode(.AlwaysTemplate)
      case .Meh:
        return UIImage(named: "Meh")!.imageWithRenderingMode(.AlwaysTemplate)
      case .Unhappy:
        return UIImage(named: "Unhappy")!.imageWithRenderingMode(.AlwaysTemplate)
      }
    }
  }
  
  var tintColor: UIColor {
    get {
      switch self {
      case .Happy:
        return UIColor(red: 68.0/255.0, green: 162.0/255.0, blue: 78.0/255.0, alpha: 1)
      case .Meh:
        return UIColor(red: 232.0/255.0, green: 188.0/255.0, blue: 37.0/255.0, alpha: 1)
      case .Unhappy:
        return UIColor(red: 176.0/255.0, green: 37.0/255.0, blue: 33.0/255.0, alpha: 1)
      }
    }
  }
}

class Guest: NSObject, NSCoding, Equatable {
  
  var name: String
  var partySize = 0
  var arrivalTime: NSDate
  var quotedTime = 0
  var mood: Mood
  var notes: String
  
  init(name: String, partySize: Int, arrivalTime: NSDate, quotedTime: Int, mood: Mood, notes: String = "") {
    self.name = name
    self.partySize = partySize
    self.arrivalTime = arrivalTime
    self.quotedTime = quotedTime
    self.mood = mood
    self.notes = notes
  }
  
  required init(coder aDecoder: NSCoder) {
    name = aDecoder.decodeObjectForKey("name") as! String
    partySize = aDecoder.decodeIntegerForKey("partySize")
    arrivalTime = aDecoder.decodeObjectForKey("arrivalTime") as! NSDate
    quotedTime = aDecoder.decodeIntegerForKey("quotedTime")
    mood = Mood(rawValue: aDecoder.decodeIntegerForKey("mood")) ?? .Happy
    notes = aDecoder.decodeObjectForKey("notes") as! String
  }
  
  func encodeWithCoder(aCoder: NSCoder) {
    aCoder.encodeObject(name, forKey: "name")
    aCoder.encodeInteger(partySize, forKey: "partySize")
    aCoder.encodeObject(arrivalTime, forKey: "arrivalTime")
    aCoder.encodeInteger(quotedTime, forKey: "quotedTime")
    aCoder.encodeInteger(mood.rawValue, forKey: "mood")
    aCoder.encodeObject(notes, forKey: "notes")
  }
  
  override var hash: Int {
    return name.hash ^ partySize.hashValue ^ arrivalTime.hashValue ^ quotedTime.hashValue ^ mood.hashValue ^ notes.hashValue
  }
}

func ==(lhs: Guest, rhs: Guest) -> Bool {
  if lhs.name == rhs.name &&
    lhs.partySize == rhs.partySize &&
    lhs.arrivalTime.isEqualToDate(rhs.arrivalTime) &&
    lhs.quotedTime == rhs.quotedTime &&
    lhs.mood == rhs.mood &&
    lhs.notes == rhs.notes
  {
    return true
  } else {
    return false
  }
}