//
//  SoundPlayer.m
//  Yorient
//
//  Created by P. Mark Anderson on 6/27/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import "SoundEnvironment.h"
#include <stdlib.h>


@implementation SoundEnvironment

@synthesize currentPlayer;
@synthesize maxAmbientSoundDelayMilliseconds;

void RouteChangeListener(void *                  inClientData,
                         AudioSessionPropertyID	 inID,

                         UInt32                  inDataSize,
                         const void *            inData);


- (void) dealloc
{
    [ambientSounds release];
    [namedSounds release];
    [currentPlayer release];
    
    [super dealloc];
}

- (id) init
{
    if (self = [super init])
    {
        ambientSounds = [[NSMutableArray alloc] initWithCapacity:1];
        namedSounds = [[NSMutableDictionary alloc] initWithCapacity:1];
        maxAmbientSoundDelayMilliseconds = 6000;
        self.currentPlayer = nil;
        playingAmbientSounds = NO;
        inBackground = NO;
    }
    
    return self;
}

- (void) resetAudioSession
{
    OSStatus result = AudioSessionInitialize(NULL, NULL, NULL, NULL);

	if (result)
    {
		NSLog(@"Error initializing audio session! %ld", result);
    }
	
	[[AVAudioSession sharedInstance] setDelegate:self];

	NSError *setCategoryError = nil;    
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];

	if (setCategoryError)
    {
		NSLog(@"Error setting category! %@", [setCategoryError localizedDescription]);
    }
	
	result = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, RouteChangeListener, self);

	if (result) 
    {
		NSLog(@"Could not add property listener! %ld", result);
    }
}

- (void) addSound:(NSString *)fileName ambient:(BOOL)ambient
{
	NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
    
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];	
    
	if (player)
	{
		player.numberOfLoops = 0;
		player.delegate = self;

        [namedSounds setObject:player forKey:fileName];        
        
        if (ambient)
        {
            [ambientSounds addObject:player];            
        }
        
        [player release];
	}
	
	[fileURL release];
}

#pragma mark AudioSession handlers

void RouteChangeListener(void *                  inClientData,
                         AudioSessionPropertyID	 inID,
                         UInt32                  inDataSize,
                         const void *            inData)
{
	SoundEnvironment *this = (SoundEnvironment*)inClientData;
	
	if (inID == kAudioSessionProperty_AudioRouteChange) 
    {		
		CFDictionaryRef routeDict = (CFDictionaryRef)inData;
		NSNumber *reasonValue = (NSNumber*)CFDictionaryGetValue(routeDict, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		
		int reason = [reasonValue intValue];
        
		if (reason == kAudioSessionRouteChangeReason_OldDeviceUnavailable)
        {
			[this pausePlaybackForCurrentPlayer];
		}
	}
}

#pragma mark AVAudioPlayer delegate methods

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)p successfully:(BOOL)flag
{
	if (flag == NO)
		NSLog(@"Playback finished unsuccessfully");
    
	[p setCurrentTime:0.];
    
    if (playingAmbientSounds)
    {
        NSTimeInterval delay = (arc4random() % maxAmbientSoundDelayMilliseconds) / 1000.0 + 0.5;
        [self performSelector:@selector(playNextAmbientSound) withObject:nil afterDelay:delay];
    }
}

- (void) playerDecodeErrorDidOccur:(AVAudioPlayer *)p error:(NSError *)error
{
	NSLog(@"ERROR IN DECODE: %@\n", error); 
}

// we will only get these notifications if playback was interrupted
- (void) audioPlayerBeginInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption begin. Updating UI for new state");
}

- (void) audioPlayerEndInterruption:(AVAudioPlayer *)p
{
	NSLog(@"Interruption ended. Resuming playback");
	[self startPlaybackForCurrentPlayer];
}

#pragma mark background notifications
- (void) registerForBackgroundNotifications
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(setInBackgroundFlag)
												 name:UIApplicationWillResignActiveNotification
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(clearInBackgroundFlag)
												 name:UIApplicationWillEnterForegroundNotification
											   object:nil];
}

- (void) setInBackgroundFlag
{
	inBackground = true;
}

- (void) clearInBackgroundFlag
{
	inBackground = false;
}

- (void) startPlaybackForCurrentPlayer
{
    if (currentPlayer)
    {
        [currentPlayer stop];
        
        NSLog(@"Playing %@", [currentPlayer url]);
        
        if (![currentPlayer play])
        {
            NSLog(@"Could not play %@\n", currentPlayer.url);
        }
    }
}

- (void) pausePlaybackForCurrentPlayer
{
    if (currentPlayer)
    {
        [currentPlayer pause];
    }
}

- (void) stopPlaybackForCurrentPlayer
{
    if (currentPlayer)
    {
        [currentPlayer pause];
    }
}

- (void) playSound:(NSString *)fileName
{
    self.currentPlayer = [namedSounds objectForKey:fileName];
    
    [self startPlaybackForCurrentPlayer];
}

- (void) startPlayingAmbientSounds
{
    if ([ambientSounds count] < 1)
        return;
    
    playingAmbientSounds = YES;
    
    [self playNextAmbientSound];
}

- (void) stopPlayingAmbientSounds
{
    playingAmbientSounds = NO;
    [self stopPlaybackForCurrentPlayer];
}

- (void) playNextAmbientSound
{
    int i = arc4random() % [ambientSounds count];
    
    AVAudioPlayer *player = [ambientSounds objectAtIndex:i];

    ////////////
    self.currentPlayer = player;    
    [self startPlaybackForCurrentPlayer];
    ////////////
    /*
    if ([player isEqual:self.currentPlayer])
    {
        NSLog(@"dup");
        [self playNextAmbientSound];
    }
    else
    {
        self.currentPlayer = player;

        [self startPlaybackForCurrentPlayer];
    }
     */
}

@end
