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
#import <RestKit/RestKit.h>
#import <DropboxSDK/DropboxSDK.h>

@class PTPusherConnectionMonitor;

@interface FirstViewController : UIViewController <UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PTPusherDelegate, RKRequestDelegate, DBRestClientDelegate>
{
    UIImagePickerController* imagePicker;
    DBRestClient *restClient;
    NSString *localPath;
    UIImage* uploadableImage;
}

@property (nonatomic, retain) IBOutlet UIButton* btnCaptureImage;
@property (nonatomic, retain) IBOutlet UITextField* tfName;
@property (nonatomic, retain) IBOutlet UIImageView* ivItem;
@property (nonatomic, retain) IBOutlet UIImageView* ivBorder;

@property (nonatomic, strong) PTPusher *client;
@property (nonatomic, strong) PTPusherConnectionMonitor* connectionMonitor;
- (IBAction)didPressLink;
- (IBAction)submit;
- (IBAction)captureImage;
- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate;
- (void)jsonFinishedLoading:(id)response;
- (void)sendRequests;
- (NSString *) encodePassword: (NSString *) myPassword;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize;

@end
