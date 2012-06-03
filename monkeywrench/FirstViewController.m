//
//  FirstViewController.m
//  monkeywrench
//
//  Created by Nicolas Kline on 6/2/12.
//  Copyright (c) 2012 Apptruism. All rights reserved.
//

#import "FirstViewController.h"
#import "PTPusher.h"
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import "NSStringMD5.h"
#import "HashSHA256.h"
#import "AssetsLibrary/AssetsLibrary.h"

@implementation FirstViewController
@synthesize btnCaptureImage, tfName, ivItem, ivBorder;
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

- (DBRestClient *)restClient {
    if (!restClient) {
        restClient =
        [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        restClient.delegate = self;
    }
    return restClient;
}

- (IBAction)didPressLink {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
    }
    
    [self sendRequests];
}

- (IBAction)submit {
        

//    [[self restClient] uploadFile:@"monkeywrench.png" toPath:@"/" withParentRev:nil fromPath:file];
    
    NSString *filename = [NSString stringWithFormat:@"%@.png", tfName.text];
    NSString *destDir = @"/Public/monkeywrench/";
    [[self restClient] uploadFile:filename toPath:destDir
                    withParentRev:nil fromPath:localPath];
    
    
    NSString* publicImageUrl = [NSString stringWithFormat:@"https://dl.dropbox.com/u/6477897/monkeywrench/%@", filename];
    
    NSArray *keys = [NSArray arrayWithObjects:@"name", @"imageURL", nil];
    NSArray *objects = [NSArray arrayWithObjects:tfName.text, publicImageUrl, nil];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    NSString* requestPath = @"/shareable-items";
    
    [ [RKClient sharedClient] post:requestPath params:params delegate:self];
//    
    // client.reconnectDelay = 30; // defaults to 5 seconds
    
    
    // NSString* helloWorld = @"{\"message\":\"hello world\"}"; 
    // [client sendEventNamed:@"client-my_event" data:helloWorld channel:@"test_channel"];
    // PTPusherChannel* pusherChannel = 
   //  [client connect];
    
    // [[WUConnection alloc] getWeatherJSON:self];
    // [self sendRequests];

}

- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath
              from:(NSString*)srcPath metadata:(DBMetadata*)metadata {
    NSLog(@"Root: %@", metadata.root);
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
}

- (void)restClient:(DBRestClient*)client uploadFileFailedWithError:(NSError*)error {
    NSLog(@"File upload failed with error - %@", error);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
}


- (void)sendRequests {
    // Perform a simple HTTP GET and call me back with the results
    // [ [RKClient sharedClient] get:@"/api/0.10.0/Classes/RKParams.html" delegate:self];
    
    // Send a POST to a remote resource. The dictionary will be transparently
    // converted into a URL encoded representation and sent along as the request body
    // NSArray *keys = [NSArray arrayWithObjects:@"name", @"body_md5", @"auth_key", @"auth_timestamp", @"auth_signature", @"auth_version", nil];
    // NSArray *objects = [NSArray arrayWithObjects:@"my_event", bodyHash, @"21641", epocTime, signatureHash, @"1.0", nil];
    // NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
    //                                                        forKeys:keys];
    
    NSString* body = @"";
    
    NSDate * past = [NSDate date];
    NSTimeInterval oldTime = [past timeIntervalSince1970];
    NSString* epocTime = [NSString stringWithFormat:@"%f", oldTime];
    NSString* bodyHash = [body MD5String];
    
    NSDictionary *params = [NSDictionary dictionaryWithKeysAndObjects:  
                            @"message", @"hello, world",
                            nil];  
    
//    NSString* bodyHash = [[params description] MD5String];
    
    NSString* authSignature = [NSString stringWithFormat:@"POST\n/apps/21641/channels/test_channel/events\nauth_key=0fa225ce2a56dfbbcd17&auth_timestamp=%@&auth_version=1.0&body_md5=%@&name=my_event", epocTime, bodyHash];
    
    NSData* signatureHash = [self encodePassword:authSignature];
    
    NSArray *keys = [NSArray arrayWithObjects:@"auth_key", @"auth_timestamp", @"auth_signature", @"auth_version", @"body_md5", @"name", nil];
    NSArray *objects = [NSArray arrayWithObjects:@"0fa225ce2a56dfbbcd17", epocTime, signatureHash, @"1.0", bodyHash, @"my_event", nil];

    // NSDictionary *params = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
 
//    NSDictionary *params = [NSDictionary dictionaryWithKeysAndObjects:  
//                @"name", @"my_event",
//                @"auth_key", @"0fa225ce2a56dfbbcd17",  
//                @"auth_timestamp", epocTime,  
//                @"auth_signature", signatureHash,  
//                @"auth_version", @"1.0",
//                @"body_md5", bodyHash,
//                @"name", @"my_event",
//                nil];  
    


    NSString* requestPath = [NSString stringWithFormat:@"/apps/21641/channels/test_channel/events?name=my_event&auth_key=0fa225ce2a56dfbbcd17&auth_timestamp=%@&auth_signature=%@&auth_version=1.0&body_md5=%@", epocTime, signatureHash, bodyHash];
    
    [ [RKClient sharedClient] post:requestPath params:nil delegate:self];

    // DELETE a remote resource from the server
    // [ [RKClient sharedClient] delete:@"/missing_resource.txt" delegate:self];
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    if ([request isGET]) {
        // Handling GET /foo.xml
        
        if ([response isOK]) {
            // Success! Let's take a look at the data
            NSLog(@"Retrieved XML: %@", [response bodyAsString]);
        }
        
    } else if ([request isPOST]) {
        
        // Handling POST /other.json        
        if ([response isJSON]) {
            NSLog(@"Got a JSON response back from our POST!");
        }
        else {
            NSLog(@"RESPONSE BODY:");
            NSLog([response bodyAsString]);
        }
        
    } else if ([request isDELETE]) {
        
        // Handling DELETE /missing_resource.txt
        if ([response isNotFound]) {
            NSLog(@"The resource path '%@' was not found.", [request resourcePath]);
        }
    }
}

- (void)jsonFinishedLoading:(id)response
{
    NSDictionary *feed = (NSDictionary *)response;
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

- (UIImage*)imageWithImage:(UIImage*)image 
              scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
        
    CGSize smaller = CGSizeMake(120.0, 160.0);
    
        if (editedImage) {
            imageToSave = [self imageWithImage:editedImage scaledToSize:smaller];
        } else {
            imageToSave = [self imageWithImage:originalImage scaledToSize:smaller];
        }
        
        // Save the new image (original or edited) to the Camera Roll
        // UIImageWriteToSavedPhotosAlbum (imageToSave, nil, nil , nil);
    
    uploadableImage = [UIImage imageWithCGImage:imageToSave.CGImage scale:0.25 orientation:imageToSave.imageOrientation];
    ivBorder.image = [UIImage imageWithCGImage:ivBorder.image.CGImage scale:0.25 orientation:ivBorder.image.imageOrientation -.1];
    ivItem.image = uploadableImage;
    ivBorder.hidden = FALSE;
    
    //NSURL *imagePath = [info objectForKey: UIImagePickerControllerReferenceURL];
    // localPath = [NSMutableString alloc];
    // [localPath appendString:[imagePath path]];
    //localPath = [[NSBundle mainBundle] pathForResource:[imagePath path] ofType:@"JPG"];
    
    NSData *data = UIImagePNGRepresentation(uploadableImage);
     NSString *filename = [NSString stringWithFormat:@"%@.png", tfName.text];
//    NSString *filename = @"thing.png";
    localPath = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
    
    [data writeToFile:localPath atomically:YES];
    
    btnCaptureImage.hidden = TRUE;

//    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];  
    // Request to save the image to camera roll  
//    [library writeImageToSavedPhotosAlbum:[imageToSave CGImage] orientation:(ALAssetOrientation)[imageToSave imageOrientation] completionBlock:^(NSURL *assetURL, NSError *error){  
//        if (error) {  
//            NSLog(@"error");  
//        } else {  
//            NSLog(@"url %@", assetURL); 
//            NSLog(@"absolute URL %@,", [assetURL absoluteString]);
//            localPath = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] pathForResource:[assetURL absoluteString] ofType:@"JPG"]];
//        }  
//    }]; 
    


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

 

- (NSString *) encodePassword: (NSString *) myPassword {
    HashSHA256 * hashSHA256 = [[HashSHA256 alloc] init];   
    NSString * result = [hashSHA256 hashedValue:@"d66cf4a90b44225f4fcf" andData:myPassword];       
    return result;       
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
    
    // [client subscribeToPrivateChannelNamed:@"test_channel"];
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
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

@end
