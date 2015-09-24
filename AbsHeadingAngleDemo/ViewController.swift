//
//  ViewController.swift
//  DRWithoutEKF
//
//  Created by Cyrus Huang on 9/20/15.
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
  var lastPoint    = CGPoint.zero
  var currentPoint = CGPoint.zero
  var red: CGFloat        = 0.0
  var green: CGFloat      = 0.0
  var blue: CGFloat       = 255.0
  var brushWidth: CGFloat = 5.0
  var opacity: CGFloat    = 1.0
  
  // device variables
  let screenWidth: CGFloat  = 320
  let screenHeight: CGFloat = 568
  
  // DR variables
  var accX:       Double = 0.0
  var accY:       Double = 0.0
  var velX:       Double = 0.0
  var velY:       Double = 0.0
  var posX:       Double = 0.0
  var posY:       Double = 0.0
  var posdX:      Double = 0.0
  var posdY:      Double = 0.0
  var accPreX:    Double = 0.0
  var accPreY:    Double = 0.0
  var velPreX:    Double = 0.0
  var velPreY:    Double = 0.0
  var posPreX:    Double = 0.0
  var posPreY:    Double = 0.0
  var accRawX:    Double = 0.0
  var accRawY:    Double = 0.0
  var accRawPreX: Double = 0.0
  var accRawPreY: Double = 0.0
  var rollRad:    Double = 0.0
  var pitchRad:   Double = 0.0
  var yawRad:     Double = 0.0
  
  let tUpdateInterval: Double = 0.01
  let accXThresholdL:  Double = 0.002
  let accYThresholdL:  Double = 0.002
  let accXThresholdH:  Double = 0.1
  let accYThresholdH:  Double = 0.1
  let accXOffset:      Double = 0.0158
  let accYOffset:      Double = 0.0184
  let noMovement:      Int    = 2
  let scaleFactor:     Double = 2000
  var noAccXCount:     Int    = 0
  var noAccYCount:     Int    = 0
  
  // LPF variables
  let kFilteringFactor: Double = 0.1
  
  // IBOutlets
  @IBOutlet weak var rollLabel:  UILabel!
  @IBOutlet weak var pitchLabel: UILabel!
  @IBOutlet weak var yawLabel:   UILabel!
  
  @IBOutlet weak var accXLabel: UILabel!
  @IBOutlet weak var accYLabel: UILabel!
  @IBOutlet weak var velXLabel: UILabel!
  @IBOutlet weak var velYLabel: UILabel!
  @IBOutlet weak var posXLabel: UILabel!
  @IBOutlet weak var posYLabel: UILabel!
  
  @IBOutlet weak var rotateImg:     UIImageView!
  @IBOutlet weak var pathImageView: UIImageView!
  
  var motionManager = CMMotionManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    motionManager.deviceMotionUpdateInterval  = tUpdateInterval
    motionManager.accelerometerUpdateInterval = tUpdateInterval
    motionManager.startDeviceMotionUpdates()
    motionManager.startAccelerometerUpdates()
    
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
    
    accRawX = data.userAcceleration.x
    accRawY = data.userAcceleration.y
    
    var accRawYOld = accRawY
    var accRawXOld = accRawX
    
    // remove data that is too high
    if (abs(accRawX) > accXThresholdH)
    {
      self.accRawX = 0
    }
    
    if (abs(accRawY) > accYThresholdH)
    {
      self.accRawY = 0
    }
    
    // low pass filter the data
    accRawX = (accRawX * kFilteringFactor) + (accRawPreX * (1 - kFilteringFactor))
    accRawY = (accRawY * kFilteringFactor) + (accRawPreY * (1 - kFilteringFactor))
    
    accRawPreX = accRawX
    accRawPreY = accRawY
    
    // convert acc data units from g to m/s^2
    //accX *= 9.81
    //accY *= 9.81
    
    // raw acceleration data calibration
    //self.accRawX -= accXOffset
    //self.accRawY -= accYOffset
    
    if (abs(accRawX) < accXThresholdL)
    {
      self.accRawX = 0
    }
    
    if (abs(accRawY) < accYThresholdL)
    {
      self.accRawY = 0
    }
    
    // first transform acc to global frame
    rollRad      = data.attitude.roll
    pitchRad     = data.attitude.pitch
    yawRad       = data.attitude.yaw
    
    self.accX = self.accRawX * cos(yawRad) - self.accRawY * sin(yawRad)
    self.accY = self.accRawX * sin(yawRad) + self.accRawY * cos(yawRad)
    
    // check for the end of movement
    if (self.accRawX == 0) {
      noAccXCount++
    } else {
      noAccXCount = 0
    }
    
    if (noAccXCount >= noMovement)
    {
      self.accX    = 0
      self.accPreX = 0
      self.velPreX = 0
      noAccXCount  = 0
    }
    
    if (self.accRawY == 0) {
      noAccYCount++
    } else {
      noAccYCount = 0
    }
    
    if (noAccYCount >= noMovement)
    {
      self.accY    = 0
      self.accPreY = 0
      self.velPreY = 0
      noAccYCount = 0
    }
    
    //print("\(self.accY)")
    
    //print("Acc     X: \(accX), Acc     Y: \(accY)")
    
    // dead reckoning
    // leapfrog integration
    self.velX = self.velPreX + (self.accX + self.accPreX) / 2.0 * tUpdateInterval
    self.velY = self.velPreY + (self.accY + self.accPreY) / 2.0 * tUpdateInterval
    
    self.posX = self.posPreX + self.velPreX * tUpdateInterval + self.accPreX * tUpdateInterval * tUpdateInterval / 2.0
    self.posY = self.posPreY + self.velPreY * tUpdateInterval + self.accPreY * tUpdateInterval * tUpdateInterval / 2.0
    
    print("\(accRawXOld), \(accRawX), \(accX), \(velX), \(posX)")
    
    // debug
    /*
    print("Roll  = \(rollValue)")
    print("Pitch = \(pitchValue)")
    print("Yaw   = \(yawValue)")
    */
    
    // update label texts faster 
    // see http://stackoverflow.com/questions/29222833/label-not-updating-swift
    dispatch_async(dispatch_get_main_queue(), {
      self.rollLabel.text  = String(self.rollRad  )
      self.pitchLabel.text = String(self.pitchRad)
      self.yawLabel.text   = String(self.yawRad)
      
      self.accXLabel.text  = String(self.accX)
      self.accYLabel.text  = String(self.accY)
      
      self.velXLabel.text  = String(self.velX)
      self.velYLabel.text  = String(self.velY)

      self.posXLabel.text  = String(self.posX * 1000)
      self.posYLabel.text  = String(self.posY * 1000)
      
      UIView.animateWithDuration(0.1, animations: {
        let rotation    = CGAffineTransformMakeRotation(-CGFloat(data.attitude.yaw))
        let translation = CGAffineTransformMakeTranslation(CGFloat(-self.posX * self.scaleFactor), CGFloat(self.posY * self.scaleFactor))
        self.rotateImg.transform = CGAffineTransformConcat(rotation, translation)
      })
      
      // draw path
      self.currentPoint.x = CGFloat(-self.posX * self.scaleFactor) + self.screenWidth / 2
      self.currentPoint.y = CGFloat(self.posY * self.scaleFactor) + self.screenHeight / 2
      
      self.drawLineFrom(self.lastPoint, toPoint: self.currentPoint)
      
      self.lastPoint = self.currentPoint
      
    });
    
    // set up for next update
    self.accPreX = self.accX
    self.accPreY = self.accY
    self.velPreX = self.velX
    self.velPreY = self.velY
    self.posPreX = self.posX
    self.posPreY = self.posY
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  



}

