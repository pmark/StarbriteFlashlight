//
//  AppDelegate.h
//  Flashlight
//
//  Created by P. Mark Anderson on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class ViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    AVAudioPlayer *clickSound;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;

- (void)playClickSound;

@end

#define APP_DELEGATE (AppDelegate*)[UIApplication sharedApplication].delegate