//
//  FirstViewController.m
//  monkeywrench
//
//  Created by Nicolas Kline on 6/2/12.
//  Copyright (c) 2012 Apptruism. All rights reserved.
//

#import "FirstViewController.h"
#import "PTPusher.h"

@implementation FirstViewController
@synthesize btnCaptureImage, tfName;
@synthesize client;
@synthesize connectionMonitor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"First", @"First");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
    }
    
    return self;
}

- (IBAction)submit {
        
    
    // client.reconnectDelay = 30; // defaults to 5 seconds
    
    
    NSString* helloWorld = @"{\"message\":\"hello world\"}"; 
    [client sendEventNamed:@"client-my_event" data:helloWorld channel:@"test_channel"];
    // PTPusherChannel* pusherChannel = 
   //  [client connect];
    

}

- (void)pusher:(PTPusher *)pusher didSubscribeToChannel:(PTPusherChannel *)channel
{
    NSLog(@"Connected to channel: %@)", channel);
}

- (void)handleEvent {
    NSLog(@"Something happened!");
    tfName.text = @"Something Happened!";
}

- (void)pusher:(PTPusher *)client connectionDidConnect:(PTPusherConnection *)connection
{
    NSLog(@"PUSHER connected!");
}

- (void)pusher:(PTPusher *)client connectionDidDisconnect:(PTPusherConnection *)connection
{
    NSLog(@"PUSHER DISCONNECTED!");
}

- (void)pusher:(PTPusher *)client didFailWithError:(PTPusherConnection *)connection
{
    NSLog(@"PUSHER FAILED!");
}

- (IBAction)captureImage
{
    [self startCameraControllerFromViewController:self usingDelegate:self];
}

- (BOOL) startCameraControllerFromViewController: (UIViewController*) controller
                                   usingDelegate: (id <UIImagePickerControllerDelegate,
                                                   UINavigationControllerDelegate>) delegate {
    
    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;
    
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    imagePicker = cameraUI;
    
    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes =
    [UIImagePickerController availableMediaTypesForSourceType:
     UIImagePickerControllerSourceTypeCamera];
    
    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    
    cameraUI.delegate = delegate;
    
    [controller presentModalViewController: cameraUI animated: YES];
    return YES;
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    
    [self dismissModalViewControllerAnimated: YES];
//    [picker release];
}

// For responding to the user accepting a newly-captured picture or movie
- (void) imagePickerController: (UIImagePickerController *) picker
 didFinishPickingMediaWithInfo: (NSDictionary *) info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;
    
    // Handle a still image capture
//    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
//        == kCFCompareEqualTo) {
        
        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];
        
        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }
        
        // Save the new image (original or edited) to the Camera Roll
        UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
//    }
    
//    // Handle a movie capture
//    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0)
//        == kCFCompareEqualTo) {
//        
//        NSString *moviePath = [[info objectForKey:
//                                UIImagePickerControllerMediaURL] path];
//        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath)) {
//            UISaveVideoAtPathToSavedPhotosAlbum (
//                                                 moviePath, nil, nil, nil);
//        }
//    }
    
    [self dismissModalViewControllerAnimated: YES];
    //    [picker release];
}
							
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib
    client = [PTPusher pusherWithKey:@"0fa225ce2a56dfbbcd17" delegate:self encrypted:TRUE];
    client.reconnectAutomatically = YES;
    [client bindToEventNamed:@"my_event" target:self action:@selector(handleEvent)];
    // client.authorizationURL = [NSURL URLWithString:@"http://api.pusherapp.com/apps/21641/channels/test_channel/events?name=my_event&body_md5=5eb63bbbe01eeed093cb22bb8f5acdc3&auth_version=1.0&auth_key=0fa225ce2a56dfbbcd17&auth_timestamp=1338668003&auth_signature=8d6f18a7eb70cc54e9b528cf952967a10f6a7a65caa745549afadaa4306f56a3"];
    //
    // NSURL* url = [NSURL URLWithString:@"hello"]
    
    [client connect];
    
    [client subscribeToPrivateChannelNamed:@"test_channel"];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
