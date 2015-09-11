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
import MultipeerConnectivity

private let _singletonInstance = MultipeerConnectivityService()

@objc
protocol MultipeerConnecivityServiceDelegate {
  func didChangeState(state: MCSessionState, forPeer peer: MCPeerID)
  func didReceiveData(data: NSData, fromPeer peer: MCPeerID)
  
  optional func browserViewControllerDidFinish(browserViewController: MCBrowserViewController)
  optional func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController)
}

class MultipeerConnectivityService: NSObject {
  
  class var sharedInstance: MultipeerConnectivityService {
    return _singletonInstance
  }
  
  var delegate: MultipeerConnecivityServiceDelegate?
  
  var advertiserAssistant: MCAdvertiserAssistant?
  var session: MCSession?
  
  var browserViewController: MCBrowserViewController?
  
  func advertise(#name: String) {
    let peerId = MCPeerID(displayName: name)
    session = MCSession(peer: peerId)
    session?.delegate = self
    
    advertiserAssistant = MCAdvertiserAssistant(serviceType: "rzw-waitlist", discoveryInfo: [String:String](), session: session)
    advertiserAssistant?.start()
  }
  
  func presentBrowserFromViewController(presentingViewController: UIViewController, peerName: String) {
    let peerId = MCPeerID(displayName: peerName)
    session = MCSession(peer: peerId)
    browserViewController = MCBrowserViewController(serviceType: "rzw-waitlist", session: session)
    browserViewController?.delegate = self
    if let browser = browserViewController {
      presentingViewController.presentViewController(browser, animated: true, completion: nil)
    }
  }
  
  func sendMessage(data: NSData, inout error: NSErrorPointer) {
    session?.sendData(data, toPeers: session?.connectedPeers, withMode: .Reliable, error: error)
  }
}

extension MultipeerConnectivityService: MCBrowserViewControllerDelegate {
  // Notifies the delegate, when the user taps the done button
  func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
    delegate?.browserViewControllerDidFinish?(browserViewController)
  }
  
  // Notifies delegate that the user taps the cancel button.
  func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
    delegate?.browserViewControllerWasCancelled?(browserViewController)
  }
}

extension MultipeerConnectivityService: MCSessionDelegate {
  // Remote peer changed state
  func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
    delegate?.didChangeState(state, forPeer: peerID)
  }
  
  // Received data from remote peer
  func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {
    delegate?.didReceiveData(data, fromPeer: peerID)
  }
  
  // Received a byte stream from remote peer
  func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
    // streaming not implemented as it will not be used for this app
  }
  
  // Start receiving a resource from remote peer
  func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {
    // resources not implemented as it will not be used for this app
  }
  
  // Finished receiving a resource from remote peer and saved the content in a temporary location - the app is responsible for moving the file to a permanent location within its sandbox
  func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
    // resources not implemented as it will not be used for this app
  }
  
}