//
//  EarthView.m
//  StarbriteFlashlight
//
//  Created by P. Mark Anderson on 9/17/12.
//
//

#import "EarthView.h"
#import <OpenGLES/ES1/gl.h>

@implementation EarthView

- (void) drawInGLContext
{
    glRotatef(rotationAngle * 0.66, 0.9, 0.05, 0.0);
    [super drawInGLContext];
}

@end
