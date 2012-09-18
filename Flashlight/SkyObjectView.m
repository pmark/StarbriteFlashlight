//
//

#define ANGLE 359
#define SCALE 0.75f
#define DURATION 0.33

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SkyObjectView.h"
#import "AppDelegate.h"


@implementation SkyObjectView

@synthesize icon;

- (void)dealloc 
{
	[icon release];
    [imageName release];
    
	[super dealloc];
}

- (id)initWithPoint:(SM3DARPoint*)point imageName:(NSString *)_imageName
{    
	if (self = [super initWithFrame:CGRectZero]) 
    {
        self.point = point;
        point.view = self;
        
        if ([_imageName length] > 0)
        {
            imageName = [_imageName retain];
        }
        else
        {
            imageName = nil;
        }
        
        UIImage *img = [UIImage imageNamed:[self imageName]];
        
        UIImageView *iv = [[UIImageView alloc] initWithImage:img];
        self.icon = iv;
        
        self.frame = CGRectMake(0, 0, img.size.width, img.size.height);
        [self addSubview:icon];
        [iv release];
	}

	return self;
}

- (NSString *)imageName
{
    NSString *name = imageName;
    
    if ([name length] == 0)
    {
        name = @"bubble.png";
    }
    
    return name;
}


- (void) setImageName:(NSString *)newImageName
{
    [imageName release];
    imageName = [newImageName retain];
    
    UIImage *img = [UIImage imageNamed:imageName];
    
    if (img)
    {
        self.icon.image = img;
    }
}

- (NSString *) focusedImageName
{
    NSString *name = self.imageName;
    
    if ([name length] > 0)
    {
        // Strip prefix
        NSArray *parts = [name componentsSeparatedByString:@"."];

        if (parts)
        {
            NSString *prefix = [parts objectAtIndex:0];
            
            if (prefix)
            {
                name = [prefix stringByAppendingFormat:@"_focused.%@", [parts objectAtIndex:1]];
            }
        }
    }
        
    return name;
}

// 
// Calculate this view's size scale based on distance from user's current location.
//
- (CGFloat) rangeScale 
{
    CGFloat scale = 1.0;
    
    if (self.point)
    {
        CGFloat poiDistance = sqrtf(self.point.worldPoint.x * self.point.worldPoint.x + 
                                    self.point.worldPoint.y * self.point.worldPoint.y);
        CGFloat minRange = 0.0;
        CGFloat maxRange = 10000.0;
        CGFloat minScaleFactor = 0.1;
        
        if (poiDistance > maxRange || poiDistance < minRange) 
        {
            scale = minScaleFactor;		
        } 
        else 
        {
            CGFloat scaleFactor = 1.0;		
            CGFloat rangeU = (poiDistance - minRange) / (maxRange - minRange);		
            scale = scaleFactor * (1.0 - ((1.0 - minScaleFactor) * rangeU));
        }	
        
    }    
    
    return scale * 0.66;
}

// 
// A point view's pointTransform is automatically applied for each visible point.
//
- (CGAffineTransform) pointTransform 
{
    CGFloat scale = [self rangeScale];
    return CGAffineTransformMakeScale(scale, scale);
}

- (void) startAnimation
{
//    CABasicAnimation *rotation;
//	rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
//	rotation.toValue = [NSNumber numberWithFloat:((ANGLE*M_PI)/180)];
//	rotation.removedOnCompletion = NO;
//	rotation.autoreverses = NO;
//	rotation.fillMode = kCAFillModeForwards;
//	rotation.duration = DURATION;
    
	CABasicAnimation *scaling;
	scaling = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaling.fromValue = [NSNumber numberWithFloat:[self rangeScale]];
	scaling.toValue = [NSNumber numberWithFloat:SCALE];
	scaling.removedOnCompletion = NO;
	scaling.autoreverses = NO;
	scaling.fillMode = kCAFillModeForwards;
	scaling.duration = DURATION;
    
	CAAnimationGroup *animation = [CAAnimationGroup animation];
	animation.removedOnCompletion = NO;
	animation.autoreverses = NO;
	animation.fillMode = kCAFillModeForwards;
	animation.duration = DURATION;
	animation.animations = [NSArray arrayWithObjects:scaling, nil];
    
	[self.layer addAnimation:animation forKey:@"animateLayerForward"];
}

- (void) stopAnimation
{
//    [self.layer removeAnimationForKey:@"animateLayer"];
    
    CABasicAnimation *scaling;
	scaling = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaling.fromValue = [NSNumber numberWithFloat:SCALE];
	scaling.toValue = [NSNumber numberWithFloat:[self rangeScale]];
	scaling.removedOnCompletion = NO;
	scaling.autoreverses = NO;
	scaling.fillMode = kCAFillModeForwards;
	scaling.duration = DURATION / 3.0;

	[self.layer addAnimation:scaling forKey:@"animateLayerBack"];
}

- (void) didReceiveFocus
{
    //NSLog(@"focusing %@", [self.point title]);

    UIImage *img = [UIImage imageNamed:[self focusedImageName]];
    
    if (img)
    {
        self.icon.image = img;
    }    
    
    [self startAnimation];
    
    [self attachToHUD];
}

- (void) didLoseFocus
{
    UIImage *img = [UIImage imageNamed:self.imageName];
    
    if (img)
    {
        self.icon.image = img;
    }
    
    [self stopAnimation];
    
    [self detachFromHUD];
}

/**
 The square box on the HUD could be a whole nuther thing.
 Use it to display a detail view for a focused or selected object.
 Consider an m34 xfm with Core Animation for a simple effect without GL coding.
 Or use a 3D object like the LexusW app did. 
 
 This method moves with heading, sticks to side.
 */
- (void) moveToPositionAlongScreenMeridian 
{
    
}

- (void) attachToHUD
{
    // This should be done by 3dar, 
    // maybe as a marker view property.
}

- (void) detachFromHUD
{
    // This should be done by 3dar, 
    // maybe as a marker view property.
}

- (void) didAttachToHUD
{
    // somehow be added to the sm3dar.hudView...
    
    // Add a tap gesture recognizer to dismiss the star. 
    // Listen for breath.
    // Add an AVInputDevice, or use libSeaBubble.
    // Play the aeolian sound with volume proportional to sample's power.
    
    
    
}

- (void) didDetachFromHUD
{
    // 
    
}

@end
