//
//  SoundPlayer.h
//  Yorient
//
//  Created by P. Mark Anderson on 6/27/11.
//  Copyright 2011 Spot Metrix, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface SoundEnvironment : NSObject <AVAudioPlayerDelegate>
{
    NSMutableArray *ambientSounds;
    NSMutableDictionary *namedSounds;
    AVAudioPlayer *currentPlayer;
    NSInteger maxAmbientSoundDelayMilliseconds;
    BOOL inBackground;
    BOOL playingAmbientSounds;
}

@property (nonatomic, retain) AVAudioPlayer *currentPlayer;
@property (nonatomic, assign) NSInteger maxAmbientSoundDelayMilliseconds;

- (void) startPlaybackForCurrentPlayer;
- (void) stopPlaybackForCurrentPlayer;
- (void) pausePlaybackForCurrentPlayer;
- (void) addSound:(NSString *)fileName ambient:(BOOL)ambient;
- (void) playNextAmbientSound;
- (void) startPlayingAmbientSounds;
- (void) playSound:(NSString *)fileName;

@end
