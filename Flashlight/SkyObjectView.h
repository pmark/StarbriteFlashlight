//
//

#import "SM3DAR.h"

///////////////////////////////////////////
// TODO: Move this protocol declaration
// into SM3DAR.h if it proves out.
@protocol SM3DARHudDelegate <NSObject>
- (void) didAttachToHUD;
- (void) didDetachFromHUD;
@end
///////////////////////////////////////////

@interface SkyObjectView : SM3DARPointView 
{
	UIImageView *icon;
    NSString *imageName;
}

@property (nonatomic, retain) UIImageView *icon;
@property (nonatomic, retain) NSString *imageName;

- (id) initWithPoint:(SM3DARPoint*)point imageName:(NSString *)imageName;
- (void) attachToHUD;
- (void) detachFromHUD;

@end
