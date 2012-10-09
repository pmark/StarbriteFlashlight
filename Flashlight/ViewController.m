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
- (void)setupTorch;
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
    [_starWorldButton release];
    [_tapTapWhiteButton release];
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
                [self goDim];
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

- (void)viewDidLoad
{
    [super viewDidLoad];

    hudView.hidden = YES;

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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self toggleTorch:[self inMode:RunModeTorchOn]];
    
    [self setup3dar];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    // Return YES for supported orientations
//    return (interfaceOrientation == UIInterfaceOrientationPortrait);
//}

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
    [self addPlanetoids];
    [self addNorthStar];
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
    m_starInstructions.hidden = NO;
    starMessageLabel.hidden = NO;    
    hudView.hidden = NO;
    
    [self.view bringSubviewToFront:APP_DELEGATE.sm3dar.view];
    [self.view bringSubviewToFront:hudView];
    [self.view bringSubviewToFront:m_starInstructions];
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

- (void)setDimmerFromTouchX:(CGFloat)touchX
{
//    NSLog(@"touchX: %.0f", touchX);
    
    CGFloat barWidth = 280.0;
    CGFloat barPadding = 20.0;
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
    
    
    // Move handle.
    
    CGPoint p = self.dimmerHandle.center;
    p.x = handleX + barPadding;
    self.dimmerHandle.center = p;
    
    
    // Set alpha.
    
    CGFloat newDimmerAlpha = (handleX / barWidth);
    //NSLog(@"pos:%.0f      alpha: %.2f", handleX, newDimmerAlpha);
    
    self.lightContainer.alpha = newDimmerAlpha;
    
    if (handleX < 25)
    {
        // StarWorld button mode.
        
        self.lightContainer.hidden = YES;
        self.starWorldButton.hidden = NO;
        self.tapTapWhiteButton.hidden = YES;
    }
    else
    {
        self.lightContainer.hidden = NO;
        self.starWorldButton.hidden = YES;
        self.tapTapWhiteButton.hidden = NO;
    }
    
}

- (IBAction)onDimmerPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:m_dimmer];
    CGFloat touchX = (m_firstTouch.x + translation.x);
    [self setDimmerFromTouchX:touchX];
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
        m_firstTouch = [touch locationInView:self.view];
        
        if (m_firstTouch.y >= self.dimmerTouchpad.frame.origin.y)
        {
            [self setDimmerFromTouchX:m_firstTouch.x];
        }
        
    }
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    m_firstTouch = [touch locationInView:self.dimmerTouchpad];
    [self setDimmerFromTouchX:m_firstTouch.x];
}

- (void)addNorthStar
{
    SM3DARPoint *point = [[SM3DARFixture alloc] init];

    Coord3D northCoord;
    northCoord.x = 0;
    northCoord.y = 13001;
    northCoord.z = 5000;
    point.worldPoint = northCoord;
    
    point.canReceiveFocus = NO;
    point.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"polaris.png"]];

    [APP_DELEGATE.sm3dar addPoint:point];
}

@end
