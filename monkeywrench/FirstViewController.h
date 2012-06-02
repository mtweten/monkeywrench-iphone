//
//  FirstViewController.h
//  monkeywrench
//
//  Created by Nicolas Kline on 6/2/12.
//  Copyright (c) 2012 Apptruism. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTPusherDelegate.h"
#import "PTPusherConnection.h"

@class PTPusherConnectionMonitor;

@interface FirstViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PTPusherDelegate>
{
    UIImagePickerController* imagePicker;
}

@property (nonatomic, retain) IBOutlet UIButton* btnCaptureImage;
@property (nonatomic, retain) IBOutlet UITextField* tfName;

@property (nonatomic, strong) PTPusher *client;
@property (nonatomic, strong) PTPusherConnectionMonitor* connectionMonitor;
- (IBAction)submit;
- (IBAction)captureImage;
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;

@end
