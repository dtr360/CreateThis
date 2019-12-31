//
//  Animate.h
//  Creativity
//
//  Created by Daniel Rencricca on 4/21/11.
//  Copyright 2011 Dan Rencricca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SwitchViewDelegate.h"
#import "CreateThisAppDelegate.h"


#define STRT_ANIMAT_TXT @"PLAY ANIMATION"
#define STOP_ANIMAT_TXT @"STOP ANIMATION"
#define STRT_RECORD_TXT @"RECORD ANIMATION"
#define STOP_RECORD_TXT @"STOP RECORDING"

#define COLOR_RED [UIColor colorWithRed:255.0/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0]
#define COLOR_BLUE  [UIColor colorWithRed:4.0/255.0f green:71.0/255.0f blue:222.0/255.0f alpha:1.0]
#define COLOR_GREEN [UIColor colorWithRed:0.0/255.0f green:133.0/255.0f blue:0.0/255.0f alpha:1.0]


#define MAX_SZ			1.75
#define MIN_SZ			0.25
#define START_ANIM_POS	2 // 1 for original position and 2 for backgroundNum


#define degreesToRadians(x) (M_PI * (x) / 180.0)

// the structure that holds transformations of user image
typedef struct
{
	float		xPos;
	float		yPos;
	float		angle; // angle of user image
	float		size;  // size of user image
} AnimRecord;


@interface AnimateViewController : UIViewController <UIAlertViewDelegate>
{
	IBOutlet UIButton		*playButton;
	IBOutlet UIButton		*recButton;
	IBOutlet UIButton		*startOverButton;
	IBOutlet UIButton		*anNewButton;
	IBOutlet UIButton		*loadButton;
	IBOutlet UIButton		*saveButton;
	IBOutlet UIButton		*backButton;
	IBOutlet UIButton		*rewindButton;

	IBOutlet UIProgressView	*animProgress;
	IBOutlet UIImageView	*backgroundImgView;
	
	UIImageView				*animImgView;
	CGPoint					origLocation;
	NSTimer					*recordTimer;
	NSTimer					*playTimer;
	Boolean					recordingAnim;
	Boolean					playingAnim;
	Boolean					playReset;
	int						pos;
	float					angle;
	float					sizeDelta;
	CGPoint					touch1, touch2;
	CGPoint					origCenter;
	float					origAngle;
	float					origScale;
	NSMutableArray			*animArray;
	AnimRecord				animRecordCur;
	AnimRecord				animRecordPre;
	AVAudioRecorder			*recorder;
	AVAudioPlayer			*audioPlayer;
	Boolean					animSaved;
    Boolean                 savedPos; // true when last position saved to array

	CreateThisAppDelegate	*appDelegate;
	
	id <SwitchViewDelegate> switchViewDelegate;
}

@property (nonatomic, retain) UIButton			*playButton;
@property (nonatomic, retain) UIButton			*recButton;
@property (nonatomic, retain) UIButton			*startOverButton;
@property (nonatomic, retain) UIButton			*anNewButton;
@property (nonatomic, retain) UIButton			*loadButton;
@property (nonatomic, retain) UIButton			*saveButton;
@property (nonatomic, retain) UIButton			*backButton;
@property (nonatomic, retain) UIButton			*rewindButton;
@property (nonatomic, retain) UIProgressView	*animProgress;
@property (nonatomic, retain) UIImageView		*backgroundImgView;
@property (nonatomic, retain) NSMutableArray	*animArray;
@property (nonatomic, retain) NSTimer			*recordTimer;
@property (nonatomic, retain) NSTimer			*playTimer;
@property (nonatomic, retain) AVAudioPlayer		*audioPlayer;
@property (nonatomic, retain) AVAudioRecorder	*recorder;

@property (nonatomic, assign) id <SwitchViewDelegate> switchViewDelegate;

- (IBAction) recordAnimation;
- (IBAction) playAnimation;
- (IBAction) rewindAnimation;
- (IBAction) startOver;
- (IBAction) newAnimation;
- (IBAction) loadAnimation;
- (IBAction) saveAnimation;
- (IBAction) goBack;
- (IBAction) getAnimationFile;

- (void) addNewPoint;
- (void) movePicture;
- (void) recordAudio;
- (void) initAudioPlayback;
- (void) initAnimArray;
- (void) loadAnimation;
- (void) enteredBackground: (NSNotification*) notification;

- (NSInteger) distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;
- (CGFloat)   angleBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2;
- (CGFloat)   scaleAmount: (CGFloat)delta;

@end

