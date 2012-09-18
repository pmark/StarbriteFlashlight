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

@interface ViewController : UIViewController <SM3DARDelegate>
{
    RunMode runMode;
    AVCaptureSession *captureSession;
    AVCaptureDevice *captureDevice;
    SM3DARController *sm3dar;
    IBOutlet UIView *menuContainer;
    IBOutlet UIView *hudView;
    IBOutlet UILabel *starMessageLabel;
    SoundEnvironment *soundEnvironment;
    IBOutlet UIImageView *m_quotationImage;
    IBOutlet UIImageView *m_starInstructions;
    IBOutlet UIView *m_dimmer;
    IBOutlet UIButton *m_torchButton;
    NSInteger m_lastStarFocusedAt;
}

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) AVCaptureDevice *captureDevice;

- (void)toggleTorchState;
- (void)toggleTorch:(BOOL)torchOn;
- (IBAction)beginMentalIllumination:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@end
