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

extension Int {
  func spokenTime() -> String {
    if Float(self) / 60.0 < 1 {
      return "\(self) minutes"
    } else if Float(self) / 60.0 < 2 {
      return "1 hour \(self % 60) minutes"
    } else {
      return "2 hours"
    }
  }
}

class GuestCell: UITableViewCell {
  
  @IBOutlet weak var numberLabel: UILabel!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var partySizeLabel: UILabel!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var quotedTimeLabel: UILabel!
  @IBOutlet weak var timeTilQuoteLabel: UILabel!
  @IBOutlet weak var moodImageView: UIImageView!
  
  var evenRow = false
  
  var guest: Guest?
  
  var timeTilQuoteTimer: NSTimer?
  let calendar = NSCalendar(calendarIdentifier: NSGregorianCalendar)!
  let evenRowColor = UIColor(red: 245.0/255.0, green: 228.0/255.0, blue: 218.0/255.0, alpha: 1.0)
  let oddRowColor = UIColor(red: 252.0/255.0, green: 237.0/255.0, blue: 224.0/255.0, alpha: 1.0)
  
  func setupCell() {
    timeTilQuoteTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: "updateTimeTilQuoteLabel", userInfo: nil, repeats: true)
    timeTilQuoteTimer?.tolerance = 5.0
    if let guest = guest {
      nameLabel.text = guest.name
      partySizeLabel.text = "\(guest.partySize)"
      arrivalTimeLabel.text = GuestService.sharedInstance.arrivalDateFormatter.stringFromDate(guest.arrivalTime)
      quotedTimeLabel.text = guest.quotedTime.spokenTime()
      updateTimeTilQuoteLabel()
      moodImageView.image = guest.mood.image
      moodImageView.tintColor = guest.mood.tintColor
    } else {
      println("Error rendering row, no guest instance available")
    }
    
    if evenRow == true {
      contentView.backgroundColor = evenRowColor
    } else {
      contentView.backgroundColor = oddRowColor
    }
  }
  
  func updateTimeTilQuoteLabel() {
    if let guest = guest {
      let quotedTimeDate = NSDate(timeInterval: NSTimeInterval(guest.quotedTime*60), sinceDate: guest.arrivalTime)
      let components = calendar.components(NSCalendarUnit.MinuteCalendarUnit | NSCalendarUnit.SecondCalendarUnit, fromDate: NSDate(), toDate: quotedTimeDate, options: nil)
      if components.minute < 0 {
        if components.minute < -59 {
          timeTilQuoteLabel.text = "Over an hour ago"
        } else if components.minute == -1 {
          timeTilQuoteLabel.text = "1 minute ago"
        } else {
          timeTilQuoteLabel.text = "\(abs(components.minute)) minutes ago"
        }
      } else if components.minute == 0 {
        timeTilQuoteLabel.text = "Now!"
      } else {
        if components.minute > 59 {
          timeTilQuoteLabel.text = "Over an hour"
        } else if components.minute == 1 {
          timeTilQuoteLabel.text = "1 minute"
        } else {
          timeTilQuoteLabel.text = "\(components.minute) minutes"
        }
      }
    }
  }
}