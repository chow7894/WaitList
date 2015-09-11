// Playground - noun: a place where people can play

import UIKit


class Guest: NSObject, NSCoding, Equatable {
    
    var name: String
    var partySize = 0
    var arrivalTime = NSDate()
    var quotedTime = 0
    var mood: Int
    var notes: String
    
    init(name: String, partySize: Int, quotedTime: Int, mood: Int, notes: String = "") {
        self.name = name
        self.partySize = partySize
        self.quotedTime = quotedTime
        self.mood = mood
        self.notes = notes
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObjectForKey("name") as String
        partySize = aDecoder.decodeIntegerForKey("partySize")
        arrivalTime = aDecoder.decodeObjectForKey("arrivalTime") as NSDate
        quotedTime = aDecoder.decodeIntegerForKey("quotedTime")
        mood = aDecoder.decodeIntegerForKey("mood")
        notes = aDecoder.decodeObjectForKey("notes") as String
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(name, forKey: "name")
        aCoder.encodeInteger(partySize, forKey: "partySize")
        aCoder.encodeObject(arrivalTime, forKey: "arrivalTime")
        aCoder.encodeInteger(quotedTime, forKey: "quotedTime")
        aCoder.encodeInteger(mood, forKey: "mood")
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


//////


class GuestService {
    
    class var sharedInstance: GuestService {
        return _singletonInstance
    }
    
    let arrivalDateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
        }()
    
    private(set) var guests = [Guest]()
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

private let _singletonInstance = GuestService()

////


let john = Guest(name: "John", partySize: 3, quotedTime: 15, mood: 0)
let jerry = Guest(name: "Jerry", partySize: 2, quotedTime: 10, mood: 0)

GuestService.sharedInstance.addGuest(john)
GuestService.sharedInstance.addGuest(jerry)

GuestService.sharedInstance.guests


