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

protocol AddGuestDelegate {
  func guestAdded(guest: Guest, atIndex: NSInteger);
}

class AddGuestTableViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {
  
  @IBOutlet weak var arrivalTimePicker: UIDatePicker!
  @IBOutlet weak var quotedTimePicker: UIPickerView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var partySizeTextField: UITextField!
  @IBOutlet weak var arrivalTimeLabel: UILabel!
  @IBOutlet weak var quotedTimeLabel: UILabel!
  @IBOutlet weak var moodSegmentedControl: UISegmentedControl!
  @IBOutlet weak var notesTextView: UITextView!
  
  var delegate: AddGuestDelegate?
  var guest: Guest?
  var editMode = false
  let quoteTimes = [5, 10, 15, 20, 25, 30, 35, 40, 45, 60, 75, 90, 105, 120]
  let arrivalDateFormatter: NSDateFormatter
  let nonNumberCharacterSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
  
  required init(coder aDecoder: NSCoder) {
    self.arrivalDateFormatter = GuestService.sharedInstance.arrivalDateFormatter
    self.arrivalDateFormatter.dateFormat = "hh:mm a"
    super.init(coder: aDecoder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    quotedTimePicker.hidden = true
    arrivalTimePicker.hidden = true
    arrivalTimePicker.date = NSDate()
    
    arrivalTimeLabel.text = arrivalDateFormatter.stringFromDate(arrivalTimePicker.date)
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if guest != nil {
      populateForm()
      editMode = true
    } else {
      nameTextField.becomeFirstResponder()
    }
  }
  
  override func disablesAutomaticKeyboardDismissal() -> Bool {
    return false
  }
  
  func populateForm() {
    if let guest = guest {
      nameTextField.text = guest.name
      partySizeTextField.text = "\(guest.partySize)"
      arrivalTimePicker.date = guest.arrivalTime
      arrivalTimeLabel.text = arrivalDateFormatter.stringFromDate(arrivalTimePicker.date)
      quotedTimePicker.selectRow(find(quoteTimes, guest.quotedTime) ?? 0, inComponent: 0, animated: false)
      quotedTimeLabel.text = guest.quotedTime.spokenTime()
      moodSegmentedControl.selectedSegmentIndex = guest.mood.rawValue
      notesTextView.text = guest.notes
    }
  }
  
  func validateForm() -> Bool {
    var validationMessage = ""
    var hasValidationError = false
    if count(nameTextField.text) == 0 {
      hasValidationError = true
      validationMessage += "Name"
    }
    
    if count(partySizeTextField.text) == 0 {
      hasValidationError = true
      if count(validationMessage) > 0 {
        validationMessage += " and Party Size are required."
      } else {
        validationMessage = "Party Size is required."
      }
      
    } else {
      validationMessage += " is required"
    }
    
    if hasValidationError {
      let alert = UIAlertController(title: "Missing Required Fields", message: validationMessage, preferredStyle: .Alert)
      let cancelAction = UIAlertAction(title: "Cance", style: .Cancel) { _ in
        self.dismissViewControllerAnimated(true, completion: nil)
      }
    }
    
    return hasValidationError
  }
  
  @IBAction func done(sender: UIBarButtonItem) {
    if validateForm() == false {
      
      let name = nameTextField.text
      let partySize = partySizeTextField.text.toInt() ?? 1
      let arrivalTime = arrivalTimePicker.date
      let quotedTime = quoteTimes[quotedTimePicker.selectedRowInComponent(0)]
      let mood = Mood(rawValue: moodSegmentedControl.selectedSegmentIndex) ?? .Happy
      let notes = notesTextView.text
      
      if let guest = guest {
        GuestService.sharedInstance.removeGuest(guest)
      }
      
      guest = Guest(name: name, partySize: partySize, arrivalTime: arrivalTime, quotedTime: quotedTime, mood: mood, notes: notes)
      let index = GuestService.sharedInstance.addGuest(guest!)
      self.delegate?.guestAdded(guest!, atIndex: index)
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
  
  @IBAction func cancel(sender: UIBarButtonItem) {
    dismissViewControllerAnimated(true, completion: nil)
  }
  
  @IBAction func arrivalTimeValueChanged(sender: UIDatePicker) {
    arrivalTimeLabel.text = arrivalDateFormatter.stringFromDate(arrivalTimePicker.date)
  }
  
  @IBAction func moodSegmentedControlDidChange(sender: UISegmentedControl) {
    view.endEditing(true)
    hidePickers()
  }
}

// MARK: UITextFieldDelegate, UITextViewDelegate

enum AddGuestCell: Int {
  case Name = 1
  case PartySize
  case ArrivalTime
  case QuotedTime
  case Mood
}

extension AddGuestTableViewController: UITextFieldDelegate, UITextViewDelegate {
  
  @IBAction func editingDidBeginForNameField(sender: UITextField) {
    hidePickers()
  }
  
  @IBAction func editingDidBeginForPartySizeField(sender: AnyObject) {
    hidePickers()
  }
  
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == partySizeTextField {
      if count(string) == 0 {
        return true
      } else {
        return count(string.stringByTrimmingCharactersInSet(nonNumberCharacterSet)) > 0
      }
    } else {
      return true
    }
  }
  
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == nameTextField {
      partySizeTextField.becomeFirstResponder()
    } else if textField == partySizeTextField {
      partySizeTextField.resignFirstResponder()
    }
    
    return true
  }
  
  func textViewDidBeginEditing(textView: UITextView) {
    hidePickers()
  }
}

// MARK: UITableViewDataSource, UITableViewDelegate

extension AddGuestTableViewController {
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    var height: CGFloat = 44.0
    
    if indexPath == NSIndexPath(forRow: 0, inSection: 1) { // notes index path
      return 200.0
    }
    
    if indexPath == NSIndexPath(forRow: 3, inSection: 0) { // arrival time picker
      if arrivalTimePicker.hidden == true {
        return 0.0
      } else {
        return 216.0
      }
    }
    
    if indexPath == NSIndexPath(forRow: 5, inSection: 0) { // quoted time picker
      if quotedTimePicker.hidden {
        return 0.0
      } else {
        return 216.0
      }
    }
    
    return height
  }
  
  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let cell = tableView.cellForRowAtIndexPath(indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
    
    if cell?.tag == AddGuestCell.ArrivalTime.rawValue {
      view.endEditing(true)
      tableView.beginUpdates()
      quotedTimePicker.hidden = true
      toggleArrivalTimePicker()
      tableView.endUpdates()
    } else if cell?.tag == AddGuestCell.QuotedTime.rawValue {
      view.endEditing(true)
      tableView.beginUpdates()
      arrivalTimePicker.hidden = true
      toggleQuotedTimePicker()
      tableView.endUpdates()
    } else {
      hidePickers()
    }
  }
  
  func hidePickers() {
    tableView.beginUpdates()
    arrivalTimePicker.hidden = true
    quotedTimePicker.hidden = true
    tableView.endUpdates()
  }
  
  func toggleArrivalTimePicker() {
    arrivalTimePicker.hidden = !arrivalTimePicker.hidden
  }
  
  func toggleQuotedTimePicker() {
    quotedTimePicker.hidden = !quotedTimePicker.hidden
  }
}

// MARK: UIPickerViewDataSource, UIPickerViewDelegate

extension AddGuestTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
  
  func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return quoteTimes.count
  }
  
  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return quoteTimes[row].spokenTime()
  }
  
  func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    quotedTimeLabel.text = quoteTimes[row].spokenTime()
  }
}

extension UINavigationController {
  public override func disablesAutomaticKeyboardDismissal() -> Bool {
    return topViewController.disablesAutomaticKeyboardDismissal()
  }
}