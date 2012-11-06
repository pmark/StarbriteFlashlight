//
//  AppDelegate.h
//  Flashlight
//
//  Created by P. Mark Anderson on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SM3DAR.h"

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) SM3DARController *sm3dar;

- (void)playClickSound;
- (void)playChimeSound;
- (void)playDoorSound;
- (void)playSwooshSound;

@end

#define APP_DELEGATE ((AppDelegate*)[UIApplication sharedApplication].delegate)