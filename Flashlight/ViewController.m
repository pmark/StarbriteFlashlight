//
//  ViewController.m
//  Flashlight
//
//  Created by P. Mark Anderson on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "SkyObjectView.h"
#import "AppDelegate.h"
#import "PlanetView.h"
#import "EarthView.h"
#import "NSDictionary+BSJSONAdditions.h"
#include <stdlib.h>


CGFloat degreesToRadians(CGFloat degrees);

@interface ViewController ()
{
    RunMode runMode;
    AVCaptureSession *captureSession;
    AVCaptureDevice *captureDevice;
    IBOutlet UIView *menuContainer;
    IBOutlet UIView *hudView;
    IBOutlet UILabel *starMessageLabel;
    SoundEnvironment *soundEnvironment;
    IBOutlet UIImageView *m_quotationImage;
    IBOutlet UIImageView *m_starInstructions;
    IBOutlet UIView *m_dimmer;
    IBOutlet UIButton *m_torchButton;
    NSInteger m_lastStarFocusedAt;
    CGFloat _dimmerHandleOriginalY;
    BOOL animatingStar;
}
- (void)setupTorch;

@property (nonatomic, strong) SM3DARPoint *infoPoint;

@end


@implementation ViewController

@synthesize captureSession;
@synthesize captureDevice;
@synthesize lightContainer = _lightContainer;
@synthesize dimmerHandle = _dimmerHandle;
@synthesize dimmerTouchpad = _dimmerTouchpad;

- (void)dealloc 
{
    [captureDevice release];
    [captureSession release];
    [menuContainer release];
    menuContainer = nil;
    [hudView release];
    [starMessageLabel release];
    [m_quotationImage release];
    [m_starInstructions release];
    [m_dimmer release];
    [m_torchButton release];
    self.lightContainer = nil;
    self.dimmerHandle = nil;
    self.dimmerTouchpad = nil;
    self.infoPoint = nil;
    [_starWorldButton release];
    [_tapTapWhiteButton release];
    [_webView release];
    [_splash release];
    [_dimmerControls release];
    [_sunContainerLight release];
    [_sunContainerDark release];
    [_sunButtonWhite release];
    [_sunButtonBlack release];
    [_handy release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)inMode:(RunMode)mode
{
    return (runMode & mode);
}

- (RunMode)enableMode:(RunMode)mode
{
    return (runMode |= mode);
}

- (RunMode)disableMode:(RunMode)mode
{
    return (runMode &= !mode);
}

- (AVCaptureSession *) captureSession
{
    if (!captureSession)
    {
        self.captureSession = [[AVCaptureSession alloc] init];
    }
    
    return captureSession;
}

- (AVCaptureDevice *) captureDevice
{
    if (!captureDevice)
    {
        self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (BOOL) deviceHasTorch
{
    return [self.captureDevice hasTorch] && [self.captureDevice hasFlash];
}

- (void)setupTorch 
{
	[self.captureSession beginConfiguration];	
	
	if ([self deviceHasTorch]) 
    {
		AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:nil];
		
		if (deviceInput) 
        {
			[captureSession addInput:deviceInput];
		}
		
		AVCaptureVideoDataOutput *dataOut = [[AVCaptureVideoDataOutput alloc] init];
		
		[captureSession addOutput:dataOut];
		[dataOut release];
        
		[captureSession commitConfiguration];
//		[captureSession startRunning];
	}
    
    [self enableMode:RunModeTorchOn];
}

- (void)goDim
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:2.0];
    
    m_dimmer.alpha = 0.5;
    
    [UIView commitAnimations];
}

- (void)toggleTorchState
{
    [self toggleTorch:![self inMode:RunModeTorchOn]];
}

- (void)toggleTorch:(BOOL)torchOn 
{
    if ([captureDevice hasTorch] && [captureDevice hasFlash]) 
    {
        [captureDevice lockForConfiguration:nil];
	
        [captureDevice setTorchMode:torchOn];
        [captureDevice setFlashMode:torchOn];	

        [captureDevice unlockForConfiguration];
        
        if (torchOn)
        {
            [self enableMode:RunModeTorchOn];
            
            if (![self inMode:RunModeSkyModeOn])
            {
                // Dim the screen if torch is on on home screen.
                //[self goDim];
            }
        }
        else
        {
            [self disableMode:RunModeTorchOn];
            m_dimmer.alpha = 0.0;
        }
    }
    else
    {
        [self disableMode:RunModeTorchOn];
    }
}

- (void)hideQuote
{
    NSTimeInterval since = [NSDate timeIntervalSinceReferenceDate] - m_lastStarFocusedAt;

    if (since > 3.0)
    {
        m_quotationImage.hidden = YES;
    }
}

#pragma mark -
#pragma mark 3DAR

- (void)sm3darViewDidLoad:(SM3DARController *)_sm3dar
{
    _sm3dar.hudView = hudView;
    
    _sm3dar.view.hidden = YES;
    [self.view insertSubview:_sm3dar.view atIndex:0];
    [self.view bringSubviewToFront:self.dimmerTouchpad];
}

- (void) sm3dar:(SM3DARController *)sm3dar didChangeFocusToPOI:(SM3DARPoint*)newPOI fromPOI:(SM3DARPoint*)oldPOI
{
    m_lastStarFocusedAt = [NSDate timeIntervalSinceReferenceDate];
    m_starInstructions.hidden = YES;
    starMessageLabel.hidden = YES;
    m_quotationImage.hidden = NO;
    
    if (newPOI)
    {
//        [self performSelector:@selector(hideQuote) withObject:nil afterDelay:3.0];
        
        NSString *imageName = [NSString stringWithFormat:@"quotation%@.png", newPOI.title];
        [m_quotationImage setImage:[UIImage imageNamed:imageName]];
        
        if ([newPOI isEqual:self.infoPoint])
        {
            // show web view
            self.webView.alpha = 1.0;

        }
        else
        {
            // hide web view
            self.webView.alpha = 0.0;
        }
    }
    else
    {
        // hide web view
        self.webView.alpha = 0.0;
    }
}

- (void) sm3dar:(SM3DARController *)sm3dar didChangeSelectionToPOI:(SM3DARPoint*)newPOI fromPOI:(SM3DARPoint*)oldPOI
{
    
}

//- (void) sm3dar:(SM3DARController *)sm3dar didChangeOrientationYaw:(CGFloat)yaw pitch:(CGFloat)pitch roll:(CGFloat)roll
//{
//    
//}

- (void) sm3darLogoWasTapped:(SM3DARController *)sm3dar
{
    
}

- (void) sm3darDidShowMap:(SM3DARController *)sm3dar
{
    
}

- (void) sm3darDidHideMap:(SM3DARController *)sm3dar
{
    
}


#pragma mark - View lifecycle

- (void)becomeActive:(NSNotification*)notif
{
    [self toggleTorch:[self inMode:RunModeTorchOn]];
}

- (void)setup3dar
{
    if (!APP_DELEGATE.sm3dar)
    {
        [[SM3DARController alloc] initWithDelegate:self];
        starMessageLabel.hidden = YES;
        hudView.hidden = YES;
    }
}

- (CGFloat)screenHeight
{
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return bounds.size.height;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    hudView.hidden = YES;
    self.webView.hidden = YES;

    [self setupTorch];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(becomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];    
    
    m_starInstructions.hidden = YES;
    m_starInstructions.animationImages = [NSArray arrayWithObjects:
                                          [UIImage imageNamed:@"DudeDown150.png"], 
                                          [UIImage imageNamed:@"DudeUp150.png"], 
                                          nil];
    m_starInstructions.animationDuration = 2.0;
    [m_starInstructions startAnimating];
    
    m_torchButton.hidden = ![self deviceHasTorch];
    
    self.dimmerHandle.transform = CGAffineTransformMakeRotation(degreesToRadians(45.0));
    _dimmerHandleOriginalY = self.dimmerHandle.center.y;
    
    [self adaptToScreenSize];
    [self setDimmerFromTouchX:320];
    
    
    self.splash.hidden = NO;
    self.starWorldButton.alpha = 1.0;

    CGFloat scale = 0.8;
    self.starWorldButton.transform = CGAffineTransformMakeScale(scale, scale);

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:INT_MAX];
    [UIView setAnimationDuration:1.33];
    
    scale = 1.15;
    self.starWorldButton.transform = CGAffineTransformMakeScale(scale, scale);
    self.starWorldButton.alpha = 1.0;
    self.starWorldButton.center = CGPointMake(self.starWorldButton.center.x,
                                              self.starWorldButton.center.y-15);
    
    scale = 0.98;
    self.sunButtonWhite.alpha = 0.1;
    self.sunButtonWhite.transform = CGAffineTransformMakeScale(scale, scale);

    [UIView commitAnimations];

}


- (void)viewDidUnload
{
    [menuContainer release];
    menuContainer = nil;
    [hudView release];
    hudView = nil;
    [starMessageLabel release];
    starMessageLabel = nil;
    [m_quotationImage release];
    m_quotationImage = nil;
    [m_starInstructions release];
    m_starInstructions = nil;
    [m_dimmer release];
    m_dimmer = nil;
    [m_torchButton release];
    m_torchButton = nil;
    [self setStarWorldButton:nil];
    [self setTapTapWhiteButton:nil];
    [self setWebView:nil];
    [self setSplash:nil];
    [self setDimmerControls:nil];
    [self setSunContainerLight:nil];
    [self setSunContainerDark:nil];
    [self setSunButtonWhite:nil];
    [self setSunButtonBlack:nil];
    [self setHandy:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (BOOL) inHomeMode
{
    return !menuContainer.hidden;
}

- (void)hideSplash
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(splashWasHidden)];
    self.splash.alpha = 0.0;
    [UIView commitAnimations];

    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationRepeatAutoreverses:YES];
    [UIView setAnimationRepeatCount:INT_MAX];
    [UIView setAnimationDuration:1.66];
    
    CGFloat scale = 0.98;
    self.sunButtonBlack.transform = CGAffineTransformMakeScale(scale, scale);
    
    [UIView commitAnimations];

}

- (void)splashWasHidden
{
    self.splash.hidden = YES;
    [self.view sendSubviewToBack:self.splash];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self toggleTorch:[self inMode:RunModeTorchOn]];
    
    [self setup3dar];
    
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:2.0];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

-(BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationMaskPortrait;
}

- (SM3DARPoint*) addOneStar:(NSString*)starTitle coord:(Coord3D)coord
{
    NSString *starName = [NSString stringWithFormat:@"Star%i.png", ((arc4random() % 6) + 1)];
    
    SM3DARFixture *point = [[SM3DARFixture alloc] init];
    SkyObjectView *v = [[SkyObjectView alloc] initWithPoint:point imageName:starName];
    
    point.title = starTitle;
    point.worldPoint = coord;
    point.canReceiveFocus = YES;
    [APP_DELEGATE.sm3dar addPoint:point];
    
    [v release];    
    [point release];
    
    return point;
}

CGFloat degreesToRadians(CGFloat degrees)
{
    return degrees * (M_PI / 180);
}

- (void) addStars
{
    Coord3D origin = {
        0, 
        0, 
        -2000
    };    
    
    Coord3D north, south, east, west;    
    north = south = east = west = origin;    
    CGFloat minDistance = 5000.0;    
    
    CGFloat degrees = 0;
    NSInteger starCount = 13;
    NSInteger starSpacingAngle = 360 / starCount;
    
    for (int i=0; i < starCount; i++)
    {
        CGFloat distance = minDistance + (arc4random() % 8000);
        
        Coord3D coord = origin;
        coord.x = distance * cosf(degreesToRadians(degrees));
        coord.y = distance * sinf(degreesToRadians(degrees));
        coord.z += arc4random() % 5000;
        
        [self addOneStar:[NSString stringWithFormat:@"%i", (i+1)] coord:coord];
        
        degrees += starSpacingAngle;
    }
    
}

- (void) addPlanetAt:(Coord3D)coord texture:(NSString*)texture size:(CGFloat)size
{
    SM3DARFixture *p = [[[SM3DARFixture alloc] init] autorelease];
    PlanetView *v = [[[PlanetView alloc] initWithTextureNamed:texture] autorelease];
    p.view = v;
    p.worldPoint = coord;    
    v.sizeScalar = size;    
    [APP_DELEGATE.sm3dar addPoint:p];
}

- (NSInteger) rdmSign
{
    return (arc4random() % 2) == 0 ? 1 : -1;
}

- (NSInteger) rdm:(NSInteger)upto sign:(BOOL)doRandomSign
{
    NSInteger randomNumber = arc4random() % upto;
    
    if (doRandomSign)
        randomNumber *= [self rdmSign];
    
    return randomNumber;
}

- (NSInteger) rdmDistance:(NSInteger)min range:(NSInteger)range
{
    return min + [self rdm:range sign:YES];
}

- (void) addEarth
{
    CGFloat earthSize = 17.0;

    Coord3D coord;
    coord.x = 0;
    coord.y = 0;
    coord.z = -38;

    SM3DARFixture *p = [[[SM3DARFixture alloc] init] autorelease];
    EarthView *v = [[[EarthView alloc] initWithTextureNamed:@"SkyImage1024x512.jpg"] autorelease];
    p.view = v;
    p.worldPoint = coord;
    p.canReceiveFocus = YES;
    v.sizeScalar = earthSize;
    [APP_DELEGATE.sm3dar addPoint:p];

}

- (void) addPlanetoids
{
    Coord3D coord;
    
    for (int i=0; i < 2; i++)
    {
        coord.x = [self rdmDistance:3000 range:8000];
        coord.y = [self rdmDistance:3000 range:8000];
        coord.z = [self rdmDistance:1000 range:2000];
        
        NSString *planetName = [NSString stringWithFormat:@"planet%i.png", (i%3)+1]; // ([self rdm:3 sign:NO] + 1)];
        [self addPlanetAt:coord texture:planetName size:(140 + arc4random() % 680)];
    }

    [self addEarth];    
}

- (void) addSkyPano
{
    SM3DARFixture *sky = [[[SM3DARFixture alloc] init] autorelease];
    sky.view = [[SphereBackgroundView2 alloc] initWithTextureNamed:@"3dar_pano_bg.jpg"];
    
    Coord3D coord = {0, 0, 0};
    sky.worldPoint = coord;
    
    NSLog(@"\n adding sky\n");
    [APP_DELEGATE.sm3dar addPoint:sky];
    
    APP_DELEGATE.sm3dar.backgroundPoint = sky;
}

- (void) sm3darLoadPoints:(SM3DARController *)_sm3dar
{
    APP_DELEGATE.sm3dar = _sm3dar;
    APP_DELEGATE.sm3dar.focusView = nil;
    APP_DELEGATE.sm3dar.glViewEnabled = NO;

    NSLog(@"Adding 3DAR points.");
    [self addSkyPano];
   // [self addInfoPoint];
    [self addPlanetoids];
    
    if ([CLLocationManager headingAvailable])
    {
        [self addNorthStar];
    }

    [self addStars];
}

- (void) startAmbientSounds
{
    soundEnvironment = [[SoundEnvironment alloc] init];    
    [soundEnvironment addSound:@"space1.m4a" ambient:YES];    
    [soundEnvironment startPlayingAmbientSounds];
}

- (IBAction)beginMentalIllumination:(id)sender 
{
    [APP_DELEGATE playChimeSound];
    
    APP_DELEGATE.sm3dar.glViewEnabled = YES;
    
    [self startAmbientSounds];
    
    NSLog(@"Going to sky mode...");

    [APP_DELEGATE.sm3dar resume];
    APP_DELEGATE.sm3dar.view.hidden = NO;
    
    menuContainer.hidden = YES;
    m_starInstructions.hidden = YES;
    starMessageLabel.hidden = NO;    
    hudView.hidden = NO;
    self.sunContainerDark.hidden = YES;
    self.sunContainerLight.hidden = YES;
    self.dimmerControls.hidden = YES;
    
    [self.view bringSubviewToFront:APP_DELEGATE.sm3dar.view];
    [self.view bringSubviewToFront:hudView];
    
//    APP_DELEGATE.sm3dar.view.backgroundColor = [UIColor yellowColor];
    
//    [self.view bringSubviewToFront:m_starInstructions];
}

- (void) exitStarMode
{
    hudView.hidden = YES;
    starMessageLabel.hidden = YES;
    m_starInstructions.hidden = YES;
    menuContainer.hidden = NO;
    
    APP_DELEGATE.sm3dar.view.hidden = YES;
    [APP_DELEGATE.sm3dar suspend];
    APP_DELEGATE.sm3dar.glViewEnabled = NO;
    [soundEnvironment stopPlaybackForCurrentPlayer];

    self.sunContainerDark.hidden = NO;
    self.sunContainerLight.hidden = NO;
    self.dimmerControls.hidden = NO;

    [self.view bringSubviewToFront:menuContainer];
}

- (IBAction)closeButtonTapped:(id)sender 
{
//    [APP_DELEGATE playClickSound];
    [self exitStarMode];
}

/*

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}
*/

NSInteger iLastPassedStarU = 0.0;
CGFloat previousTouchX;

- (void)setDimmerFromTouchX:(CGFloat)touchX
{
//    NSLog(@"touchX: %.0f", touchX);
    
    CGFloat barWidth = 247.0;
    CGFloat barPadding = 36.0;
    CGFloat leftBorder = barPadding;
    CGFloat rightBorder = (self.view.frame.size.width-barPadding);
    CGFloat handleX;
    
    if (touchX < leftBorder)
    {
        handleX = 0;
    }
    else if (touchX > rightBorder)
    {
        handleX = barWidth;
    }
    else
    {
        handleX = touchX - barPadding;
    }
    
    // Set alpha.
    
    CGFloat handleU = (handleX / barWidth);
    CGFloat newDimmerAlpha = handleU;
    
    self.lightContainer.alpha = newDimmerAlpha;
    self.handy.alpha = newDimmerAlpha;
    

    
    // Move rabbit handle.
    
    CGPoint p = self.dimmerHandle.center;

    // 0: 0 
    // 50: -40
    // 100: 0
    //CGFloat offsetHandleY = (sinf(degreesToRadians(handleU * 180.0)) * 40.0);  // Circular
    
    // 1: 40
    // 0: 0
    // -1: 40
    CGFloat maxOffsetHandleY = 40.0;
    CGFloat parabolaU = ((2.0 * handleU) - 1.0);
    CGFloat parabolaU2 = (parabolaU * parabolaU);
    CGFloat offsetHandleY = -((parabolaU2 * maxOffsetHandleY));
    
    p.y = _dimmerHandleOriginalY - offsetHandleY - maxOffsetHandleY;
    p.x = handleX + barPadding + 8;
    self.dimmerHandle.center = p;

    // 0: -45 degrees
    // 50: 0
    // 100: 45
    CGFloat rabbitRotationDegrees = (handleU * 90.0) - 45.0;
    self.dimmerHandle.transform = CGAffineTransformMakeRotation(degreesToRadians(rabbitRotationDegrees));    
    
    
    if (handleU < 0.20)
    {
        // StarWorld button mode.
        
        self.lightContainer.hidden = YES;
        [self setStarWorldButtonHidden:NO];
    }
    else
    {
        self.lightContainer.hidden = NO;
        [self setStarWorldButtonHidden:YES];
    }
    
    
    // Must be heading left.
    BOOL headingLeft = ((previousTouchX - touchX) > 0.0);
    
    if (!animatingStar)
    {
        NSInteger iHandleU = handleU * 1000.0;

        if (abs(iLastPassedStarU - iHandleU) >= 100.0)
        {
//            NSLog(@"%i", iHandleU);
            iLastPassedStarU = iHandleU;
            
            NSMutableArray *passedStars = [NSMutableArray arrayWithCapacity:4];
            
            // htf do i know if a star has been passed?
            // 
            
            UIImageView *star;

            if (iHandleU <= 850)
            {
                star = (UIImageView *)[self.view viewWithTag:8001];
                
                if (headingLeft && !star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }
            else if (!headingLeft)
            {
                star = (UIImageView *)[self.view viewWithTag:8001];
                if (star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }

            if (iHandleU <= 650)
            {
                star = (UIImageView *)[self.view viewWithTag:8002];
                
                if (headingLeft && !star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }
            else if (!headingLeft)
            {
                star = (UIImageView *)[self.view viewWithTag:8002];
                if (star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }

            if (iHandleU <= 450)
            {
                star = (UIImageView *)[self.view viewWithTag:8003];
                
                if (headingLeft && !star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }
            else if (!headingLeft)
            {
                star = (UIImageView *)[self.view viewWithTag:8003];
                if (star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }
            
            if (iHandleU <= 260)
            {
                star = (UIImageView *)[self.view viewWithTag:8004];
                
                if (headingLeft && !star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }
            else if (!headingLeft)
            {
                star = (UIImageView *)[self.view viewWithTag:8004];
                if (star.highlighted)
                {
                    [passedStars addObject:star];
                }
            }

            if ([passedStars count] > 0)
            {
                animatingStar = YES;
                
                [UIView animateWithDuration:0.5
                                      delay:0.0
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     
                                     for (UIImageView *star in passedStars)
                                     {
                                         if (headingLeft)
                                         {
//                                             [APP_DELEGATE playSwooshSound];

                                             star.alpha = 0.0;
                                             star.highlighted = YES;

                                             CGFloat scale = 15.0;
                                             CGFloat x = 160 - star.center.x;
                                             CGFloat y = -240;
                                             
                                             CGAffineTransform xfmScale = CGAffineTransformScale(star.transform, scale, scale);
                                             CGAffineTransform xfmRotate = CGAffineTransformRotate(star.transform, -M_PI_2);
                                             CGAffineTransform xfmTranslate = CGAffineTransformTranslate(star.transform,
                                                                                                         x,
                                                                                                         y);
                                             
                                             star.transform = CGAffineTransformConcat(
                                                                CGAffineTransformConcat(xfmRotate, xfmScale),
                                                                xfmTranslate);
                                             
                                         }
                                     }
                                     
                                 } completion:^(BOOL finished) {
                                     
                                     if (!headingLeft)
                                     {
//                                         [APP_DELEGATE playSwooshSound];
                                         
                                         for (UIImageView *star in passedStars)
                                         {
                                             star.transform = CGAffineTransformIdentity;
                                             star.alpha = 1.0;
                                             star.highlighted = NO;
                                         }
                                     }
                                     
                                     animatingStar = NO;
                                     
                                 }];
            }
        }
    }
    
    previousTouchX = touchX;
}

- (void)setStarWorldButtonHidden:(BOOL)hidden
{
    if (self.starWorldButton.hidden != hidden)
    {
        if (self.starWorldButton.hidden)
        {
            // Only sound when showing.
            [APP_DELEGATE playDoorSound];
        }
        

        self.starWorldButton.hidden = hidden;
        
        CGFloat alpha = (hidden ? 0.0 : 1.0);
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.25];
        //    self.starWorldButton.alpha = alpha;
        self.tapTapWhiteButton.alpha = (1.0 - alpha);
        [UIView commitAnimations];
    }

}

- (IBAction)onDimmerPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:m_dimmer];
    CGFloat touchX = (m_firstTouch.x + translation.x);
    [self setDimmerFromTouchX:touchX];
}

- (IBAction)webViewWasTapped:(id)sender
{
    BOOL webViewParentIsMainView = [self.webView.superview isEqual:self.view];
    
    if (webViewParentIsMainView)
    {
        // Move back to HUD.
        
        [APP_DELEGATE.sm3dar.hudView addSubview:self.webView];
        NSLog(@"Moved webview to HUD.");
    }
    else
    {
        // Move to main view.
        
        [self.view addSubview:self.webView];
        NSLog(@"Moved webview to main view.");
    }
}

CGPoint m_firstTouch;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    NSInteger tapCount = [[touches anyObject] tapCount];
    
    if (tapCount > 1)
    {
        [APP_DELEGATE playClickSound];
        [self toggleTorchState];
    }
    else
    {
        if ([self isTouchingRabbit:touch])
        {
            m_firstTouch = [touch locationInView:self.view];

            if (m_firstTouch.y >= self.dimmerTouchpad.frame.origin.y)
            {
                [self setDimmerFromTouchX:m_firstTouch.x];
            }
        }
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    if ([self isTouchingRabbit:touch])
    {
        m_firstTouch = [touch locationInView:self.dimmerTouchpad];
        [self setDimmerFromTouchX:m_firstTouch.x];
    }
}

- (BOOL)isTouchingRabbit:(UITouch*)touch
{
    CGPoint rabbitTouchPoint = [touch locationInView:self.dimmerHandle];
    //NSLog(@"rabbit touch point: %.0f, %.0f", rabbitTouchPoint.x, rabbitTouchPoint.y);
    
    CGSize rabbitSize = self.dimmerHandle.frame.size;
    
    return (rabbitTouchPoint.x > 0 && rabbitTouchPoint.x < rabbitSize.width);
                        //  rabbitTouchPoint.y > 0 && rabbitTouchPoint.y < rabbitSize.height);
}

- (void)addNorthStar
{
    SM3DARPoint *point = [[[SM3DARFixture alloc] init] autorelease];
    
    Coord3D northCoord;
    northCoord.x = 0;
    northCoord.y = 13001;
    northCoord.z = 5000;
    point.worldPoint = northCoord;
    
    point.canReceiveFocus = NO;
    point.view = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"polaris.png"]] autorelease];
    
    [APP_DELEGATE.sm3dar addPoint:point];
}

- (void)addInfoPoint
{
    NSString *url = @"http://seanoteworthy.tumblr.com/";
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    self.infoPoint = [[[SM3DARFixture alloc] init] autorelease];
    
    Coord3D upCoord;
    upCoord.x = 0;
    upCoord.y = -15000;
    upCoord.z = 8000;
    self.infoPoint.worldPoint = upCoord;
    self.infoPoint.canReceiveFocus = YES;
    self.infoPoint.view = self.webView;
    
    [APP_DELEGATE.sm3dar addPoint:self.infoPoint];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.webView.hidden = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webView.hidden = NO;
}

- (BOOL)is4inchRetinaScreen
{
    return ([self screenHeight] > 480.0);
}

- (void)printScreenResolution
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if ([UIScreen mainScreen].scale == 2.0f)
        {
            CGSize result = [[UIScreen mainScreen] bounds].size;
            CGFloat scale = [UIScreen mainScreen].scale;
            result = CGSizeMake(result.width * scale, result.height * scale);
            
            if(result.height == 960)
            {
                NSLog(@"iPhone 4, 4s Retina Resolution");
            }
            
            if (result.height == 1136)
            {
                NSLog(@"iPhone 5 Resolution");
            }
        }
        else
        {
            NSLog(@"iPhone Standard Resolution");
        }
    }
    else
    {
        if ([UIScreen mainScreen].scale == 2.0f)
        {
            NSLog(@"iPad Retina Resolution");
        }
        else
        {
            NSLog(@"iPad Standard Resolution");
        }
    }
}

- (void)snapDimmerControlToBottom
{
    CGRect f = self.dimmerControls.frame;
    f.origin.y = [self screenHeight] - f.size.height;
    self.dimmerControls.frame = f;
}

- (void)repositionSunContainers
{
    CGFloat offset = 0.0;
    
    CGRect f = self.sunContainerDark.frame;
    f.origin.y += offset;
    self.sunContainerDark.frame = f;
    
    f = self.sunContainerLight.frame;
    f.origin.y += offset;
    self.sunContainerLight.frame = f;
    
}

- (void)adaptToScreenSize
{
    BOOL hasTallScreen = [self is4inchRetinaScreen];
    
    if (hasTallScreen)
    {
        self.splash.image = [UIImage imageNamed:@"Default-568h@2x.png"];
        self.splash.frame = [[UIScreen mainScreen] bounds];
        
        [self repositionSunContainers];
    }

    [self snapDimmerControlToBottom];
}

- (SM3DARCalloutView*) sm3dar:(SM3DARController*)sm3dar calloutViewForPoint:(SM3DARPoint*)point
{
    return nil;
}

@end
