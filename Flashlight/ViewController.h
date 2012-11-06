//
//  ViewController.h
//  Flashlight
//
//  Created by P. Mark Anderson on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SM3DAR.h"
#import "SoundEnvironment.h"

typedef enum 
{
    RunModeInactive = 0, 
    RunModeTorchOn = 1, 
    RunModeSkyModeOn = 2,
    RunModeSoundOn = 4
} RunMode;

@interface ViewController : UIViewController <SM3DARDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate>
{
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureDevice *captureDevice;
@property (nonatomic, retain) IBOutlet UIView *lightContainer;
@property (nonatomic, retain) IBOutlet UIView *darkContainer;
@property (nonatomic, retain) IBOutlet UIImageView *dimmerHandle;
@property (nonatomic, retain) IBOutlet UIView *dimmerTouchpad;
@property (retain, nonatomic) IBOutlet UIView *dimmerControls;
@property (retain, nonatomic) IBOutlet UIImageView *starWorldButton;
@property (retain, nonatomic) IBOutlet UIImageView *tapTapWhiteButton;
@property (retain, nonatomic) IBOutlet UIWebView *webView;
@property (retain, nonatomic) IBOutlet UIImageView *splash;
@property (retain, nonatomic) IBOutlet UIView *sunContainerLight;
@property (retain, nonatomic) IBOutlet UIView *sunContainerDark;
@property (retain, nonatomic) IBOutlet UIButton *sunButtonWhite;
@property (retain, nonatomic) IBOutlet UIImageView *sunButtonBlack;
@property (retain, nonatomic) IBOutlet UIImageView *handy;

- (void)toggleTorchState;
- (void)toggleTorch:(BOOL)torchOn;
- (IBAction)beginMentalIllumination:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)onDimmerPan:(UIPanGestureRecognizer *)recognizer;
- (IBAction)webViewWasTapped:(id)sender;

@end
