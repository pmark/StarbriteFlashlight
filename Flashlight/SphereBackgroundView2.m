//
//  SphereBackgroundView.m
//
//

#import <OpenGLES/ES1/gl.h>
#import "SphereBackgroundView2.h"

@implementation SphereBackgroundView2

- (void) buildView {
    self.hidden = NO;
    self.sizeScalar = 100000.0f;
    self.zrot = 0.0;
	self.frame = CGRectZero;
}

- (void) drawInGLContext
{
    if (!self.color)
    {
        self.color = [UIColor lightGrayColor];
    }
    
    glScalef(-self.sizeScalar, self.sizeScalar, self.sizeScalar);
    glRotatef(180, 1, 0, 0);

    if (self.texture)
    {
//        glDepthMask(0);
        
        [Geometry displaySphereWithTexture:self.texture];
        
//        glDepthMask(1);
    }
	else
    {
        if (self.geometry)
        {
            [self.geometry displayShaded:self.color];
            //[self.geometry displayWireframe];
        }
    }    
}


@end
