//
//  ViewController.h
//  GPSDeviceTappsi
//
//  Created by Jose Aponte on 8/2/15.
//  Copyright (c) 2015 Jose Aponte. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;

@end

