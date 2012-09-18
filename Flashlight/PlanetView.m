//
//  PlanetView.m
//  StarbriteFlashlight
//
//  Created by P. Mark Anderson on 1/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PlanetView.h"
#import <OpenGLES/ES1/gl.h>

@implementation PlanetView

- (void) drawInGLContext
{
    
    glScalef(-1.0, 1.0, 1.0);
    glRotatef(90, 1.0, 0.15, 0.0);
    
    rotationAngle += 0.66;
    glRotatef(rotationAngle, 0, 0, 1.0);
    
    [super drawInGLContext];
    
}

@end
