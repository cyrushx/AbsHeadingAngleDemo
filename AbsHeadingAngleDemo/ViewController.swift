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

  // altitude variables
  var rollValue:  Int = 0
  var pitchValue: Int = 0
  var yawValue:   Int = 0
  
  // draw variables
  var lastPoint = CGPoint.zero
  var red: CGFloat = 0.0
  var green: CGFloat = 0.0
  var blue: CGFloat = 255.0
  var brushWidth: CGFloat = 5.0
  var opacity: CGFloat = 1.0
  
  @IBOutlet weak var rollLabel: UILabel!
  @IBOutlet weak var pitchLabel: UILabel!
  @IBOutlet weak var yawLabel: UILabel!
  @IBOutlet weak var rotateImg: UIImageView!
  @IBOutlet weak var pathImageView: UIImageView!
  
  var motionManager = CMMotionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    motionManager.deviceMotionUpdateInterval = 0.1
    motionManager.startDeviceMotionUpdates()
    
    // update altitude data
    if motionManager.deviceMotionAvailable{
      let queue = NSOperationQueue()
      // set frame to XArbitraryCorrectedZVertical
      // shoud lbe calibrated XTrueNorthZVertical
      motionManager.startDeviceMotionUpdatesUsingReferenceFrame(CMAttitudeReferenceFrame.XArbitraryCorrectedZVertical, toQueue: queue, withHandler:
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
    
    lastPoint = pathImageView.center
    
    print("x  = \(lastPoint.x)")
    print("y  = \(lastPoint.y)")
    
    var currentPoint: CGPoint = lastPoint
   
    for i in 1...20 {
      currentPoint.y = lastPoint.y - 5
      currentPoint.x = lastPoint.x
      
      drawLineFrom(lastPoint, toPoint: currentPoint)
      
      lastPoint = currentPoint
      
      print("x  = \(lastPoint.x)")
      print("y  = \(lastPoint.y)")
    }
    
    for i in 1...20 {
      currentPoint.y = lastPoint.y
      currentPoint.x = lastPoint.x - 5
      
      drawLineFrom(lastPoint, toPoint: currentPoint)
      
      lastPoint = currentPoint
      
      print("x  = \(lastPoint.x)")
      print("y  = \(lastPoint.y)")
    }
    
  }
  
  // method modiefied from:
  // http://www.raywenderlich.com/87899/make-simple-drawing-app-uikit-swift
  func drawLineFrom(fromPoint: CGPoint, toPoint: CGPoint) {
    
    // set up pathImageView
    UIGraphicsBeginImageContext(view.frame.size)
    let context = UIGraphicsGetCurrentContext()
    pathImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))
    
    // Draw a line from lastPoint to currentPoint
    CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
    CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
    
    // Set all drawing parameters
    CGContextSetLineCap(context, CGLineCap.Round)
    CGContextSetLineWidth(context, brushWidth)
    CGContextSetRGBStrokeColor(context, red, green, blue, 1.0)
    CGContextSetBlendMode(context, CGBlendMode.Normal)
    
    // Draw the path
    CGContextStrokePath(context)
    
    // Render the pathImageView
    pathImageView.image = UIGraphicsGetImageFromCurrentImageContext()
    pathImageView.alpha = opacity
    UIGraphicsEndImageContext()
    
  }
      
  func outputData(data: CMDeviceMotion) {
    
    // turn Euler angles into degree
    rollValue  = Int(data.attitude.roll / M_PI * 180)
    pitchValue = Int(data.attitude.pitch / M_PI * 180)
    yawValue   = Int(data.attitude.yaw / M_PI * 180)

    // debug
    /*
    print("Roll  = \(rollValue)")
    print("Pitch = \(pitchValue)")
    print("Yaw   = \(yawValue)")
    */
    
    // update label texts faster 
    // see http://stackoverflow.com/questions/29222833/label-not-updating-swift
    dispatch_async(dispatch_get_main_queue(), {
      self.rollLabel.text  = String(self.rollValue)
      self.pitchLabel.text = String(self.pitchValue)
      self.yawLabel.text   = String(self.yawValue)
      
      UIView.animateWithDuration(0.1, animations: {
        self.rotateImg.transform = CGAffineTransformMakeRotation(-CGFloat(data.attitude.yaw))
      })
    });
    
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  



}

