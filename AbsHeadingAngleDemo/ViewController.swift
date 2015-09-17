//
//  ViewController.swift
//  AbsHeadingAngleDemo
//
//  Created by Cyrus Huang on 9/13/15.
//  Copyright (c) 2015 Cyrus Huang. All rights reserved.
//


import UIKit
import CoreMotion

class ViewController: UIViewController {

  var rollValue:  Int = 0
  var pitchValue: Int = 0
  var yawValue:   Int = 0
  
  @IBOutlet weak var rollLabel: UILabel!
  @IBOutlet weak var pitchLabel: UILabel!
  @IBOutlet weak var yawLabel: UILabel!
  @IBOutlet weak var rotateImg: UIImageView!
  
  var motionManager = CMMotionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    motionManager.deviceMotionUpdateInterval = 0.1
    motionManager.startDeviceMotionUpdates()
    
    // update altitude data
    if motionManager.deviceMotionAvailable{
      let queue = NSOperationQueue()
      motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XTrueNorthZVertical, toQueue: queue, withHandler:
        {data, error in
          
          guard let data = data else{
            return
          }
      
          self.outputData(data)
          
        }
      )
    } else {
      print("Device motion data is not available")
    }
    
  }
      
  func outputData(data: CMDeviceMotion)
  {
    // turn Euler angles into degree
    rollValue  = Int(data.attitude.roll / M_PI * 180)
    pitchValue = Int(data.attitude.pitch / M_PI * 180)
    yawValue   = Int(data.attitude.yaw / M_PI * 180)

    // debug
    print("Roll  = \(rollValue)")
    print("Pitch = \(pitchValue)")
    print("Yaw   = \(yawValue)")
    
    // update label texts faster 
    // see http://stackoverflow.com/questions/29222833/label-not-updating-swift
    dispatch_async(dispatch_get_main_queue(), {
      self.rollLabel.text  = String(self.rollValue)
      self.pitchLabel.text = String(self.pitchValue)
      self.yawLabel.text   = String(self.yawValue)
      
      UIView.animateWithDuration(0.1, animations: {
        self.rotateImg.transform = CGAffineTransformMakeRotation(CGFloat(data.attitude.yaw))
      })
    });
    
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  



}

