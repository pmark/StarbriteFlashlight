//
//  ViewController.m
//  Flashlight
//
//  Created by P. Mark Anderson on 11/6/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "SkyObjectView.h"
#import "AppDelegate.h"
#import "PlanetView.h"
#include <stdlib.h>


CGFloat degreesToRadians(CGFloat degrees);

@interface ViewController ()
- (void)setupTorch;
@end


@implementation ViewController

@synthesize captureSession;
@synthesize captureDevice;


- (void)dealloc 
{
    [captureDevice release];
    [captureSession release];
    [menuContainer release];
    menuContainer = nil;
    [sm3dar release];
    [hudView release];
    [starMessageLabel release];
    [m_quotationImage release];
    [m_starInstructions release];
    [m_dimmer release];
    [m_torchButton release];
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
    sm3dar = _sm3dar;
    sm3dar.hudView = hudView;
    
    [SM3DAR_BSJSON class];
    NSDictionary *d = [NSDictionary dictionary];
    
    NSLog(@"\n\nDict: %@", [d sm3dar_jsonStringValue]);

    _sm3dar.view.hidden = YES;
    [self.view insertSubview:_sm3dar.view atIndex:0];
}

- (void) sm3dar:(SM3DARController *)sm3dar didChangeFocusToPOI:(SM3DARPoint*)newPOI fromPOI:(SM3DARPoint*)oldPOI
{
    m_lastStarFocusedAt = [NSDate timeIntervalSinceReferenceDate];
    m_starInstructions.hidden = YES;
    starMessageLabel.hidden = YES;
    m_quotationImage.hidden = NO;
    
    if (newPOI)
    {
        [self performSelector:@selector(hideQuote) withObject:nil afterDelay:3.0];
        
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
    if (!sm3dar)
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (SM3DARPoint*) addOneStar:(NSString*)starTitle coord:(Coord3D)coord
{
    NSString *starName = [NSString stringWithFormat:@"Star%i.png", ((arc4random() % 6) + 1)];
    
    SM3DARFixture *point = [[SM3DARFixture alloc] init];
    SkyObjectView *v = [[SkyObjectView alloc] initWithPoint:point imageName:starName];
    
    point.title = starTitle;
    point.worldPoint = coord;
    point.canReceiveFocus = YES;
    [sm3dar addPoint:point];
    
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
    NSInteger starCount = 12;
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
    [sm3dar addPoint:p];
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

- (void) addPlanetoids
{
    Coord3D coord;
    
    for (int i=0; i < 12; i++)
    {
        coord.x = [self rdmDistance:0 range:8000];
        coord.y = [self rdmDistance:0 range:8000];
        coord.z = [self rdmDistance:-2000 range:3000];
        
        NSString *planetName = [NSString stringWithFormat:@"planet%i.png", (i%3)+1]; // ([self rdm:3 sign:NO] + 1)];
        [self addPlanetAt:coord texture:planetName size:(140 + arc4random() % 680)];
    }
    
    CGFloat earthSize = 20;
    coord.x = -earthSize / 2;
    coord.y = -earthSize / 2;
    coord.z = -earthSize * 2;
    [self addPlanetAt:coord texture:@"WorldAtNight.jpg" size:earthSize];

}

- (void) addSkyPano
{
    SM3DARFixture *sky = [[[SM3DARFixture alloc] init] autorelease];
    sky.view = [[SphereBackgroundView alloc] initWithTextureNamed:@"3dar_pano_bg.jpg"];
    
    Coord3D coord = {0, 0, 0};
    sky.worldPoint = coord;
    
    NSLog(@"\n adding sky\n");
    [sm3dar addPoint:sky];
    
    sm3dar.backgroundPoint = sky;
}

- (void) setupScene
{
    NSLog(@"Loading sky");
    [self addSkyPano];

    NSLog(@"Loading stars");
    [self addStars];
    
    [self addPlanetoids];
}

- (void) sm3darLoadPoints:(SM3DARController *)_sm3dar
{
    [self setupScene];
}

- (void) startAmbientSounds
{
    soundEnvironment = [[SoundEnvironment alloc] init];    
    [soundEnvironment addSound:@"space1.m4a" ambient:YES];    
    [soundEnvironment startPlayingAmbientSounds];
}

- (IBAction)beginMentalIllumination:(id)sender 
{
    [APP_DELEGATE playClickSound];
    
    [self startAmbientSounds];
    
    NSLog(@"Going to sky mode...");

    [sm3dar resume];
    sm3dar.view.hidden = NO;
    
    menuContainer.hidden = YES;
    m_starInstructions.hidden = NO;
    starMessageLabel.hidden = NO;    
    hudView.hidden = NO;
    
    [self.view bringSubviewToFront:sm3dar.view];
    [self.view bringSubviewToFront:hudView];
    [self.view bringSubviewToFront:m_starInstructions];
}

- (void) exitStarMode
{
    hudView.hidden = YES;
    starMessageLabel.hidden = YES;
    m_starInstructions.hidden = YES;
    menuContainer.hidden = NO;
    
    sm3dar.view.hidden = YES;
    [sm3dar suspend];
    [soundEnvironment stopPlaybackForCurrentPlayer];

    [self.view bringSubviewToFront:menuContainer];
}

- (IBAction)closeButtonTapped:(id)sender 
{
    [APP_DELEGATE playClickSound];
    [self exitStarMode];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [APP_DELEGATE playClickSound];
    [self toggleTorchState];
}

@end
