//
//  AppDelegate.m
//  Flashlight
//
//  Created by P. Mark Anderson on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()
{
    AVAudioPlayer *clickSound;
    AVAudioPlayer *chimeSound;
    AVAudioPlayer *doorSound;
    AVAudioPlayer *swooshSound;
}
@end


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize sm3dar = _sm3dar;

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    if ([application respondsToSelector:@selector(setStatusBarHidden:withAnimation:)])
    {
        [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    else
    {
        [application setStatusBarHidden:YES];
    }
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    self.viewController = [[[ViewController alloc] initWithNibName:@"ViewController" bundle:nil] autorelease];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [self setupAudio];
    
    [application setIdleTimerDisabled:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)setupAudio
{
    NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"Click" ofType:@"wav"]];
    clickSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [clickSound prepareToPlay];
    
    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"CrystalGlass" ofType:@"wav"]];
    chimeSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [chimeSound prepareToPlay];

    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"door_open" ofType:@"wav"]];
    doorSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [doorSound prepareToPlay];

    url = [NSURL URLWithString:[[NSBundle mainBundle] pathForResource:@"swoosh" ofType:@"wav"]];
    swooshSound = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [swooshSound prepareToPlay];
}

- (void)playClickSound
{
    [clickSound play];
}

- (void)playChimeSound
{
    [chimeSound play];
}

- (void)playDoorSound
{
    [doorSound play];
}

- (void)playSwooshSound
{
    [swooshSound play];
}

@end
