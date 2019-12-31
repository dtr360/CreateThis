//
//  AnimateViewController.m
//  Creativity
//
//  Created by Daniel Rencricca on 4/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  DisplayOut
//  ScreenSplitr
//
//

#import "AnimateViewController.h"

@implementation AnimateViewController

@synthesize recordTimer;
@synthesize playTimer;
@synthesize playButton;
@synthesize recButton;
@synthesize anNewButton;
@synthesize saveButton;
@synthesize loadButton;
@synthesize startOverButton;
@synthesize backButton;
@synthesize rewindButton;
@synthesize backgroundImgView;
@synthesize animArray;
@synthesize animProgress;
@synthesize audioPlayer;
@synthesize recorder;
@synthesize switchViewDelegate;

double	rate	  = .016667; // .016667 = frame rate of .016667/second.
int		maxPoints = 60 * 60; //60 * 60 = 1 sec/.016667 = 60 x 60 seconds


#pragma mark -
#pragma mark Touches

- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *)event 
{
	UITouch	*touch = [touches anyObject];
	int		adj = 30;
	
	// do not accept any touches if playing animation
	if (playingAnim)
		return;
    
    if (!savedPos && recordingAnim) // then touchesmoved called more frequently than the timer fired
    {
        NSLog(@"Skipped recording this point.");
        return;
    }
    
    savedPos = false; // don't allow transformations until last move recorded
	
	if ([touches count] == 1 ) // one finger touching screen
	{
		CGPoint touchLocation = [touch locationInView:self.view];
		
		// check if the finger touch point is withing the user image 
		if (CGRectContainsPoint (animImgView.frame, touchLocation))
		{		
			float deltaX = [[touches anyObject] locationInView:self.view].x - 
			[[touches anyObject] previousLocationInView:self.view].x;
			
			float deltaY = [[touches anyObject] locationInView:self.view].y - 
			[[touches anyObject] previousLocationInView:self.view].y;
			
			// if image is out of bounds, then move it back in by adusting detaX and deltaY
			if (animImgView.frame.origin.x + animImgView.frame.size.width + deltaX > backgroundImgView.bounds.size.width+adj)
				deltaX = (backgroundImgView.bounds.size.width - (animImgView.frame.origin.x + animImgView.frame.size.width)+adj);
			else if (animImgView.frame.origin.x + deltaX < backgroundImgView.bounds.origin.x-adj)
				deltaX = (backgroundImgView.bounds.origin.x - animImgView.frame.origin.x-adj);
			
			if (animImgView.frame.origin.y + animImgView.frame.size.height + deltaY > backgroundImgView.bounds.size.height)
				deltaY = (backgroundImgView.bounds.size.height - (animImgView.frame.origin.y + animImgView.frame.size.height));
			else if (animImgView.frame.origin.y + deltaY < backgroundImgView.bounds.origin.y-adj)
				deltaY = (backgroundImgView.bounds.origin.y - animImgView.frame.origin.y-adj);
			
			
			
			//NSLog(@"uI.y: %f | uH: %f | dY: %f | bH: %f", userImg.frame.origin.y,
			//	  userImg.frame.size.height, deltaY,
			//	  backgroundImgView.bounds.size.height);
			
			//CGPoint nP = CGPointMake (userImg.frame.origin.x, userImg.frame.origin.y);
			//NSLog(@"Orig: X/Y: %f / %f", nP.x, nP.y);
			
			//nP = [userImg convertPoint:nP toView:self.view];
			//NSLog(@"Tran: X/Y: %f / %f", nP.x, nP.y);
			
			// Move image into position using the image center.  The center point of the image will
			// be in the same scale as the point on the superview.
			CGPoint newPoint = CGPointMake (animImgView.center.x + deltaX, animImgView.center.y + deltaY);
			[animImgView setCenter: newPoint];
		}
	} 
	else if ([touches count] == 2 ) // two fingers touching screen (e.g. pinching)
	{	
		// get previous points that two fingers touched the screen
		CGPoint prePoint1 = [[[touches allObjects] objectAtIndex:0] previousLocationInView:self.view];
		CGPoint prePoint2 = [[[touches allObjects] objectAtIndex:1] previousLocationInView:self.view];
		
		// get current points that two fingers touched the screen
		CGPoint curPoint1 = [[[touches allObjects] objectAtIndex:0] locationInView:self.view];
		CGPoint curPoint2 = [[[touches allObjects] objectAtIndex:1] locationInView:self.view];
		
		// calc the midpoint between the previous points that two fingers touched screen
		int preMidX = (prePoint1.x + prePoint2.x)/2;
		int preMidY = (prePoint1.y + prePoint2.y)/2;
		
		// calc the midpoint between the current points that two fingers touched screen
		int curMidX = (curPoint1.x + curPoint2.x)/2;
		int curMidY = (curPoint1.y + curPoint2.y)/2;
		
		// calc change in x and y value of center points
		int deltaX = curMidX - preMidX;
		int deltaY = curMidY - preMidY;
		
		// calc width and height of box formed by two fingers
		float touchWid =  (curPoint2.x - curPoint1.x);
		float touchHgt =  (curPoint2.y - curPoint1.y);
		
		CGRect touchRec = CGRectMake(curPoint1.x, curPoint1.y, touchWid, touchHgt);
		
		// check if the user image rectange intersects with rectangle formed by two fingers
		if (CGRectIntersectsRect([animImgView frame], touchRec))
		{			 
			// if image is out of bounds, then move it back in by adusting detaX and deltaY	
			if (animImgView.frame.origin.x + animImgView.frame.size.width + deltaX > backgroundImgView.bounds.size.width+adj)
				deltaX = (backgroundImgView.bounds.size.width - (animImgView.frame.origin.x + animImgView.frame.size.width)+adj);
			else if (animImgView.frame.origin.x + deltaX < backgroundImgView.bounds.origin.x)
				deltaX = (backgroundImgView.bounds.origin.x - animImgView.frame.origin.x);
			if (animImgView.frame.origin.y + animImgView.frame.size.height + deltaY > backgroundImgView.bounds.size.height-adj)
				deltaY = (backgroundImgView.bounds.size.height - (animImgView.frame.origin.y + animImgView.frame.size.height)-adj);
			else if (animImgView.frame.origin.y + deltaY < backgroundImgView.bounds.origin.y-adj)
				deltaY = (backgroundImgView.bounds.origin.y - animImgView.frame.origin.y-adj);
			
			float prevDistance = [self distanceBetweenPoint1:prePoint1 andPoint2:prePoint2];
			float newDistance = [self distanceBetweenPoint1:curPoint1 andPoint2:curPoint2];
			sizeDelta = (newDistance / prevDistance);		
			
			// restrict max size to 1.75x original size
			float sx = animImgView.transform.a/cos(atan2(animImgView.transform.b, animImgView.transform.a));
			if (sx > MAX_SZ)
				sizeDelta = 1-(sx-MAX_SZ)/MAX_SZ;
			
			// restrict min size to .10x original size
			if (sx < MIN_SZ)
				sizeDelta = 1-(sx-MIN_SZ)/MIN_SZ;
			
			// if size has changed then transform the image
			if (!isnan(sizeDelta) && sizeDelta != 0)
				animImgView.transform = CGAffineTransformScale (animImgView.transform, sizeDelta, sizeDelta);
			
			// calculate the angle change for the image
			float prevAngle = [self angleBetweenPoint1:prePoint1 andPoint2:prePoint2];
			float curAngle  = [self angleBetweenPoint1:curPoint1 andPoint2:curPoint2];
			angle = curAngle - prevAngle;
			
			//NSLog(@"Size Delta: %f / SX: %f", sizeDelta, sx);
			
			// move image angle
			animImgView.transform = CGAffineTransformRotate (animImgView.transform, angle);
			
			// Move image into position using the image center.  The center point of the image will
			// be in the same scale as the point on the superview.
			CGPoint newPoint = CGPointMake (animImgView.center.x + deltaX, animImgView.center.y + deltaY);
			[animImgView setCenter: newPoint];
		}
	}
}


#pragma mark -
#pragma mark Record animation

// Record the movements by the user to an array
- (IBAction) recordAnimation
{
	if (!recordingAnim) // start recording animation
	{	
		[self recordAudio]; // start recording audio
		
		animProgress.progress = 0.0;
		pos = 0;
		animSaved = false; // animation has not been saved
        savedPos  = true; // init
		
		// clean out array
		[animArray removeAllObjects];

		// hold on to position, size and angle of image
		origCenter = animImgView.center;
		origAngle  = atan2(animImgView.transform.b, animImgView.transform.a);	
		origScale = sqrt(pow(animImgView.transform.a,2)+pow(animImgView.transform.c,2));
		NSLog (@"SCALE: %f", origScale);
		
		// reset animImg to its original, untransformed state
		animImgView.transform = CGAffineTransformIdentity;
		
		// adjust the image scale
		animImgView.transform = CGAffineTransformScale (animImgView.transform, origScale, origScale);
				
		// adjust the image rotation
		animImgView.transform = CGAffineTransformRotate (animImgView.transform, origAngle);
		
		[self initAnimArray]; // pos will be 2 upon return
		
		//NSLog (@"Added at %d -- x:%f y:%f scale:%f", pos, origFrame.origin.x, origFrame.origin.y, origScale);

		NSLog(@"Started Recording Animation");
		
		// start the timer that handles recording the data points
		recordTimer = [NSTimer scheduledTimerWithTimeInterval:rate target: self selector:@selector(addNewPoint)
					   userInfo:nil repeats:YES];	
	
		[recButton setTitle: STOP_RECORD_TXT forState: UIControlStateNormal];
		[recButton setTitleColor: COLOR_RED forState: UIControlStateNormal]; 
		
		startOverButton.enabled	= false;
		startOverButton.alpha	= 0.5f;
		
		anNewButton.enabled	= false;
		anNewButton.alpha	= 0.5f;
		
		loadButton.enabled	= false;
		loadButton.alpha	= 0.5f;
		
		saveButton.enabled	= false;
		saveButton.alpha	= 0.5f;
		
		backButton.enabled	= false;
		backButton.alpha	= 0.5f;
		
	}
	else // user finished recording animation
	{	
		NSLog(@"Stopped Recording Animation");
		
		[self recordAudio]; // stop recording audio
		
		[recordTimer invalidate];
		recordTimer = nil;

		recButton.alpha   = 1.0f;
		[recButton setTitle: STRT_RECORD_TXT forState: UIControlStateNormal];
		[recButton setTitleColor: COLOR_BLUE forState: UIControlStateNormal]; 

		startOverButton.enabled	= true;
		startOverButton.alpha	= 1.0f;
		
		anNewButton.enabled	= true;
		anNewButton.alpha	= 1.0f;
	
		loadButton.enabled	= true;
		loadButton.alpha	= 1.0f;
		
		saveButton.enabled	= true;
		saveButton.alpha	= 1.0f;
	
		backButton.enabled	= true;
		backButton.alpha	= 1.0f;
		
		recButton.enabled	= false;
		recButton.hidden	= true;
		
		playButton.enabled	= true;
		playButton.hidden	= false;
	}
	
	recordingAnim = !recordingAnim;
}


- (void) recordAudio
{
	if (recordingAnim) // if already recording then stop
	{
		[recorder stop];
	
	}
    else // start recording audio
    {		
		// create the full file path by appending a file name - use temporary name
		NSString *path = [appDelegate.gAppDataDir stringByAppendingPathComponent:TMP_FILE_AUDIO];
		
		NSLog(@"Temp Audio File: %@", path);
		
		NSMutableDictionary *settings = [[NSMutableDictionary alloc] init]; 

		// use record setting suitable for voice
		[settings setValue:[NSNumber numberWithInt:kAudioFormatAppleIMA4] forKey:AVFormatIDKey]; 
        [settings setValue:[NSNumber numberWithFloat:8000.0]	forKey:AVSampleRateKey];
        [settings setValue:[NSNumber numberWithInt:1]			forKey:AVNumberOfChannelsKey]; 
        [settings setValue:[NSNumber numberWithInt:8]			forKey:AVLinearPCMBitDepthKey];
		[settings setValue:[NSNumber numberWithInt:AVAudioQualityMin] forKey:AVEncoderAudioQualityKey];
        [settings setValue:[NSNumber numberWithBool:NO]			forKey:AVLinearPCMIsBigEndianKey]; 
		[settings setValue:[NSNumber numberWithBool:NO]			forKey:AVLinearPCMIsFloatKey]; 
				
        if (self.recorder != nil)
			[recorder release]; 
		
		NSError * err = NULL;
		
        recorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:path]
											   settings:settings error:&err];
		if(err)
			NSLog(@" VAudioRecorder Error: %@", err);
		
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES; 
        [recorder record];
		
		[settings release];
    }
}


// adds a new of the image location to the pointArray.
-(void) addNewPoint
{	
	if ([animArray count] <= maxPoints) // check we have not exceeded max array size
	{		
		// set new position, size and angle for animArray
		NSArray *recArray = [[NSArray alloc] initWithObjects: 
							 [NSNumber numberWithFloat: animImgView.center.x],
							 [NSNumber numberWithFloat: animImgView.center.y], 
							 [NSNumber numberWithFloat: angle],
							 [NSNumber numberWithFloat: sizeDelta], 
							 nil];
		
		[animArray addObject: recArray];
		
		[recArray release];
		
		//	NSLog(@"Wrote at %d -- Angle: %f  Scale: %f", pos, angle, sizeDelta);
		
			NSLog (@"Added sizeDelta: %f at pos: %d", sizeDelta, pos);
		
		//	NSLog (@"Added cp-x: %f  cp-y: %f at pos %d", currentPoint.x, currentPoint.y, pos);
		
		pos++;
		
		// dim the Record button every 40 times this method is called
		if (pos % 60 == 0 || false)
		{
			if (recButton.alpha == 0.5f)
				recButton.alpha   = 1.0f; // display full intensity
			else
				recButton.alpha   = .5f; // display dimmed
		}
		
		animProgress.progress = (float) pos / (float) maxPoints;
        
        savedPos = true;
	}
	else // maximum record time hit, so stop recording
	{
		// stop recording animation
		[self recordAnimation];		
	}
}	


- (void) initAnimArray {
	
	// store info on original position in first element of animArray
	NSArray *recArray1 = [[NSArray alloc] initWithObjects: 
						 [NSNumber numberWithFloat: animImgView.center.x],
						 [NSNumber numberWithFloat: animImgView.center.y], 
						 [NSNumber numberWithFloat: atan2(animImgView.transform.b, animImgView.transform.a)],
						 [NSNumber numberWithFloat: origScale],
						 nil];
	
	[animArray  addObject:recArray1];
	
	[recArray1 release];

	pos++;
	
	// store the background image number
	NSArray *recArray2 = [[NSArray alloc] initWithObjects: 
						 [NSNumber numberWithFloat: appDelegate.gScenarioNum],
						 [NSNumber numberWithFloat: 0], 
						 [NSNumber numberWithFloat: 0],
						 [NSNumber numberWithFloat: 0],
						 nil];
	
	[animArray  addObject:recArray2];
	
	[recArray2 release];	

	pos++;	
}


#pragma mark -
#pragma mark Play animation


// the user pressed the play button to start playing the animation
- (IBAction) playAnimation {
		
	// init the animation record structures
	memset(&animRecordCur, 0, sizeof(AnimRecord));
	memset(&animRecordPre, 0, sizeof(AnimRecord));
	
	assert ([animArray count] > START_ANIM_POS);
	
	if ([animArray count] <= START_ANIM_POS) // then no recording made
		return;
	
	// if user presses play to begin animation from start.
	if (playReset || pos == [animArray count])
	{
		playingAnim = false;
		
		[self initAudioPlayback];
		
		// set up the progress bar
		animProgress.progress = 0.0;

		pos = START_ANIM_POS;
	
		//reset animImg to its original, untransformed state
		animImgView.transform = CGAffineTransformIdentity;
		
		// restore image to position, size and angle of where it was when Record button hit
		[animImgView setCenter: origCenter];
		
		animImgView.transform = CGAffineTransformScale (animImgView.transform, origScale, origScale);

		animImgView.transform = CGAffineTransformRotate (animImgView.transform, origAngle);
		
		//NSLog (@"Read at %d -- x:%f y:%f w:%f  h:%f", pos, origFrame.origin.x, origFrame.origin.y, origFrame.size.width, origFrame.size.height);

		playReset = false;
	}
		
	if (playingAnim) // stop the playing animation
	{
		playingAnim = false;
		
		[audioPlayer pause];
		
		[playButton setTitle:STRT_ANIMAT_TXT forState: UIControlStateNormal];
		[playButton setTitleColor: COLOR_GREEN forState: UIControlStateNormal];
		
		if (playTimer != nil)
		{
			[playTimer invalidate];
			playTimer = nil;
		}

        rewindButton.enabled	= false;
		rewindButton.hidden		= true;
        
		startOverButton.enabled	= true;
		startOverButton.alpha	= 1.0f;
		
		loadButton.enabled		= true;
		loadButton.alpha		= 1.0f;

		saveButton.enabled		= true;
		saveButton.alpha		= 1.0f;	
		
		anNewButton.enabled		= true;
		anNewButton.alpha		= 1.0f;
		
		backButton.enabled		= true;
		backButton.alpha		= 1.0f;
	}
	else // start playing animation
	{
		[audioPlayer play];
		
		playingAnim = true;
		
		// change the button label to display Stop Animation
		[playButton setTitle:STOP_ANIMAT_TXT forState: UIControlStateNormal];
		[playButton setTitleColor: COLOR_RED forState: UIControlStateNormal];
		
		// start the play timer
		playTimer = [NSTimer scheduledTimerWithTimeInterval:rate 
													 target:self
												   selector:@selector (movePicture)
												   userInfo:nil 
													repeats:YES];				
		rewindButton.enabled	= true;
		rewindButton.hidden		= false;
		
		startOverButton.enabled	= false;
		startOverButton.alpha	= 0.5f;
		
		loadButton.enabled		= false;
		loadButton.alpha		= 0.5f;
		
		saveButton.enabled		= false;
		saveButton.alpha		= 0.5f;
		
		anNewButton.enabled		= false;
		anNewButton.alpha		= 0.5f;
		
		backButton.enabled		= false;
		backButton.alpha		= 0.5f;
	}
	
	//NSLog(@"Size of pointArray: %d", [animArray count]);
}

// moves the image to the next point in the pointArray
-(void) movePicture
{
	if (pos >= [animArray count]) // then entire animation played
	{
		NSLog (@"Invalidating playTimer");
		
		if (playTimer != nil)
		{
			[playTimer invalidate];
			playTimer = nil;
		}
		
		playingAnim = false;
		
		[playButton setTitle:STRT_ANIMAT_TXT forState: UIControlStateNormal];
		[playButton setTitleColor: COLOR_GREEN forState: UIControlStateNormal];
		
		// set up the progress bar
		animProgress.progress	= 0.0;

		backButton.enabled		= true;
		backButton.alpha		= 1.0f;
		
		rewindButton.enabled	= false;
		rewindButton.hidden		= true;

		startOverButton.enabled	= true;
		startOverButton.alpha	= 1.0f;
		
		loadButton.enabled		= true;
		loadButton.alpha		= 1.0f;
				
		saveButton.enabled		= true;
		saveButton.alpha		= 1.0f;
		
		anNewButton.enabled		= true;
		anNewButton.alpha		= 1.0f;
		
		return;
	}
	
	// convert point array value at pos to CGPoint value
	
	// set previous animation record to the current record
	animRecordPre = animRecordCur;
	
	animRecordCur.xPos  = [[[animArray objectAtIndex:pos] objectAtIndex:0] floatValue];
	animRecordCur.yPos  = [[[animArray objectAtIndex:pos] objectAtIndex:1] floatValue];
	animRecordCur.angle = [[[animArray objectAtIndex:pos] objectAtIndex:2] floatValue];
	animRecordCur.size  = [[[animArray objectAtIndex:pos] objectAtIndex:3] floatValue];
	
	float angleDif = 0.0;
	
	if (animRecordCur.angle != animRecordPre.angle)
		angleDif = animRecordCur.angle;
	
	float sizeDif = 0.0;
	
	if (animRecordCur.size != animRecordPre.size && pos > START_ANIM_POS)
		sizeDif = animRecordCur.size;
	
	if (sizeDif == 0.0)
		sizeDif = 1.0;
	
	// move the image into place
	[animImgView setCenter: CGPointMake (animRecordCur.xPos, animRecordCur.yPos)];
	
	// adjust the image scale
	animImgView.transform = CGAffineTransformScale (animImgView.transform, sizeDif, sizeDif);
	
	// adjust the image rotation
	animImgView.transform = CGAffineTransformRotate (animImgView.transform, angleDif);
	
	//NSLog(@"Read at %d -- xPos: %f  yPos: %f", pos, xPos, xPos);
	NSLog(@"Read at %d -- Angle: %f  Scale: %f", pos, angleDif, sizeDif);
	
	pos++; // got to next animation point
	
	// update progress bar
	animProgress.progress = (float) pos / (float) [animArray count];
}	


- (void) initAudioPlayback
{	
	//assert (audioFile != nil); // audioFile is entire part to caf file
	
	// create the full file path by appending a file name
	NSString *path = [appDelegate.gAppDataDir stringByAppendingPathComponent: TMP_FILE_AUDIO];

  	NSString *fixedPath = [path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]; 

	NSLog (@"fixedPath: %@", fixedPath);
	
	NSURL *url = [NSURL URLWithString:fixedPath]; 
		
	if (audioPlayer)
		[audioPlayer release];
	
	audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil]; 
	
	// preload audio buffer and prepare the audio for playing
	[audioPlayer prepareToPlay];
	
    audioPlayer.volume = 10.0;
}


#pragma mark -
#pragma mark Alerts


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
	if ([alertView tag] == 1000) // go back
	{
        if (buttonIndex == 0) 
		{
			assert (recordingAnim == false);
			assert (playingAnim == false);
			
			[audioPlayer stop];
						
			[switchViewDelegate goDrawView];
        }
		else if (buttonIndex == 1)
		{
			// do nothing
		}
    }

	else if ([alertView tag] == 2000) // start over 
	{
        if (buttonIndex == 0) 
		{
			assert (recordingAnim == false);
			assert (playingAnim == false);
			
			[audioPlayer stop];
			
			[switchViewDelegate startOver];
        }
		else if (buttonIndex == 1)
		{
			// do nothing
		}
    }
	
	else if ([alertView tag] == 3000) // load new animation 
	{
        if (buttonIndex == 0) 
		{
			assert (recordingAnim == false);
			assert (playingAnim == false);
			
			[audioPlayer stop];
			
			[switchViewDelegate getSavedAnimation];
        }
		else if (buttonIndex == 1)
		{
			// do nothing
		}
    }

	else if ([alertView tag] == 4000) // load new animation 
	{
        if (buttonIndex == 0) 
		{
			animProgress.progress = 0.0;
			
			[audioPlayer stop];
			
			assert (recordingAnim == false);
			assert (playingAnim == false);
			
			playReset = true;
			animSaved = true;
			
			startOverButton.enabled	= true;
			startOverButton.alpha	= 1.0f;
			
			playButton.enabled		= false;
			playButton.hidden		= true;
			
			recButton.enabled		= true;
			recButton.hidden		= false;
        }
		else if (buttonIndex == 1)
		{
			// do nothing
		}
    }
}


#pragma mark -
#pragma mark Utility Methods

- (NSInteger)distanceBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 {
	CGFloat deltaX = fabsf(point1.x - point2.x);
	CGFloat deltaY = fabsf(point1.y - point2.y);
	CGFloat distance = sqrt((deltaY*deltaY)+(deltaX*deltaX));
	
	return distance;
}

- (CGFloat)scaleAmount: (CGFloat)delta {
    CGFloat pix = sqrt(self.view.frame.size.width * self.view.frame.size.height);
    CGFloat scale = 1.0 + (delta / pix);
    return scale;
}

- (CGFloat)angleBetweenPoint1:(CGPoint)point1 andPoint2:(CGPoint)point2 { 
	
	CGFloat deltaY = point1.y - point2.y;
	CGFloat deltaX = point1.x - point2.x;
	CGFloat angleNum = atan2(deltaY, deltaX);
	
	return angleNum;
}

#pragma mark -
#pragma mark Outlets


// Handles saving the animation, including the image file, animation data and audio file.
- (IBAction) saveAnimation
{
	assert ([animArray count]>1);
	
	animSaved = true;
	
	[switchViewDelegate getAnimationFileName:animArray];
}


- (IBAction) getAnimationFile {
	
	NSLog (@"In getAnimationFile");
	
	// Create file path to documents directory where user animation file has been saved
	
	// create the full file path by appending a file name
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	NSString *baseFileName = [appDelegate.gFilePath stringByDeletingPathExtension];

	NSString *userImagePath = [baseFileName stringByAppendingPathExtension: FILE_EXT_PNG];

	NSLog(@"userImgePath: %@", userImagePath);
	
	NSFileManager *filemgr = [NSFileManager defaultManager];
	
	if (![filemgr fileExistsAtPath:userImagePath])
		NSLog(@"image file does not exist");	
	
	// load the image from file
	appDelegate.gAnimImg = [[UIImage alloc] initWithCGImage: [[UIImage imageWithContentsOfFile: userImagePath] CGImage]];
	
	// load audio file
	NSString *srcAudioFile = [baseFileName stringByAppendingPathExtension: FILE_EXT_CAF];
	
	NSString *dstAudioFile = [[baseFileName stringByDeletingLastPathComponent]
								stringByAppendingPathComponent: TMP_FILE_AUDIO];
							   
	// remove the old temporary audio file
	[filemgr removeItemAtPath: dstAudioFile error: NULL];
	
	// copy saved audio file to the temp audio file name
	if ([filemgr isReadableFileAtPath: srcAudioFile])
		[filemgr copyItemAtPath: srcAudioFile toPath: dstAudioFile error: NULL];
	
	//Load the animation array
	NSString *userFileName = appDelegate.gFilePath;

	animArray = [[NSMutableArray alloc] initWithContentsOfFile: userFileName];
	
	NSLog(@"Read animArray from file: %i records", [animArray count]);

	animSaved = true;
}


- (IBAction) rewindAnimation {
	
    //[audioPlayer setCurrentTime:0];  
	
	[self playAnimation]; // stop playing animation
	
	[audioPlayer stop];

	playReset = true;
	
	[self playAnimation]; // start playing animation
}

// Allows user to go back to recording animation screen
- (IBAction) goBack {
	
	if ([animArray count] > 0 && !animSaved)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
														message:@"If you go back to the canvas you will lose your recorded animation. Do you wish to continue?"
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"No", nil];
		[alert setTag: 1000];
		[alert show];
		[alert release];
	}
	else 
	{
		// go back to Draw View
		[switchViewDelegate goDrawView];
	}
}


- (IBAction) startOver {
	
	if ([animArray count] > 0 && !animSaved)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
														message:@"If you start over you will lose your work. Do you wish to continue?"
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"No", nil];
		[alert setTag: 2000];
		[alert show];
		[alert release];		
	}
	else 
	{
		[switchViewDelegate startOver];
	}
}


- (IBAction) loadAnimation {
	
	if ([animArray count] > 0 && !animSaved)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
														message:@"If you load an animation you will lose your recorded animation. Do you wish to continue?"
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"No", nil];
		[alert setTag: 3000];
		[alert show];
		[alert release];
	}
	else 
	{
		[switchViewDelegate getSavedAnimation];
	}
}

- (IBAction) newAnimation {
	
	if ([animArray count] > 0 && !animSaved)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
														message:@"If you start a new recording you will lose your current animation. Do you wish to continue?"
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"No", nil];
		[alert setTag: 4000];
		[alert show];
		[alert release];
	}
	else 
	{	
		animProgress.progress = 0.0;
		
		[audioPlayer stop];
		
		assert (recordingAnim == false);
		assert (playingAnim == false);
		
		playReset = true;
		animSaved = true;
		
		startOverButton.enabled	= true;
		startOverButton.alpha	= 1.0f;
		
		playButton.enabled		= false;
		playButton.hidden		= true;
		
		recButton.enabled		= true;
		recButton.hidden		= false;
	}
}


#pragma mark -	
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	
	NSLog(@"In AnimateViewController: viewDidLoad");

	[[NSNotificationCenter defaultCenter] addObserver: self 
											 selector: @selector(enteredBackground:) 
												 name: @"didEnterBackground" 
											   object: nil];
	
	appDelegate = [[UIApplication sharedApplication] delegate];
	
	recordingAnim = playingAnim = false;
	playReset = true;
	
	animProgress.progress = 0.0;   // reset progress bar to zero
	self.playTimer   = nil;
	self.recordTimer = nil;
	self.recorder	 = nil;
	self.audioPlayer = nil;
		 	 
	// place the drawn image in the view
	animImgView =[[UIImageView alloc] initWithImage: appDelegate.gAnimImg];
	
	[[self view] addSubview:animImgView];
	
	if ([animArray count] > 0) // then animation loaded from file
	{	
		startOverButton.enabled	= true;
		startOverButton.alpha	= 1.0f;
				
		playButton.enabled	= true;
		playButton.hidden	= false;
		
		recButton.enabled	= false;
		recButton.hidden	= true;
		
		backButton.enabled	= false;
		backButton.hidden	= true;
		
		float xPos   = [[[animArray objectAtIndex:0] objectAtIndex:0] floatValue];
		float yPos   = [[[animArray objectAtIndex:0] objectAtIndex:1] floatValue];
		float angleI = [[[animArray objectAtIndex:0] objectAtIndex:2] floatValue];
		float scale  = [[[animArray objectAtIndex:0] objectAtIndex:3] floatValue];
		//float height = [[[animArray objectAtIndex:0] objectAtIndex:4] floatValue];
		
		// set location, rotation and scale of image
		origCenter = CGPointMake (xPos, yPos);
		origAngle  = angleI;
		//origFrame  = CGRectMake(0, 0, width, height);
		origScale  = scale;
				
		//animImgView.frame = origFrame;
		
		// reset animImg to its original, untransformed state
		animImgView.transform = CGAffineTransformIdentity;
		
		// adjust the image scale
		animImgView.transform = CGAffineTransformScale (animImgView.transform, origScale, origScale);
		
		animImgView.transform = CGAffineTransformRotate (animImgView.transform, origAngle);
		
		[animImgView setCenter: origCenter];
		
		// set the background image based on the scenario number
		appDelegate.gScenarioNum = (int) [[[animArray objectAtIndex:1] objectAtIndex:0] floatValue];
	
		NSLog (@"Read Scenario Number: %i", appDelegate.gScenarioNum);
	}
	else // user has not created an animation yet
	{
		// set location of image
		float xPos = (self.view.bounds.size.width/2);
		float yPos = (self.view.bounds.size.height/2);
		
		origCenter = CGPointMake (xPos, yPos);
		
		[animImgView setCenter: origCenter];
		
		saveButton.enabled	= false;
		saveButton.alpha	= 0.5f;
		
		playButton.enabled	= false;
		playButton.hidden	= true;
		
		recButton.enabled	= true;
		recButton.hidden	= false;
		
		backButton.enabled	= true;
		backButton.alpha	= 1.0f;
		
		animArray	= [[NSMutableArray alloc] init];
	}
	
	// set the background image
	[backgroundImgView setImage: [appDelegate.gBackImgArray objectAtIndex:appDelegate.gScenarioNum]];
	
	assert (appDelegate.gAnimImg != nil);
	
	
	// set button colors
	[playButton setTitleColor: COLOR_GREEN forState: UIControlStateNormal];
	[recButton setTitleColor: COLOR_BLUE forState: UIControlStateNormal];

	animSaved = true;
	
	[super viewDidLoad];
}


- (void) enteredBackground: (NSNotification*) notification {
	
	if (recordingAnim)
		[self recordAnimation];
	
	if (playingAnim) 
	{
		[self playAnimation];
		
		[audioPlayer stop];
		playReset = true;
	}
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

	self.playButton			= nil;
	self.recButton			= nil;
	self.anNewButton		= nil;
	self.loadButton			= nil;
	self.saveButton			= nil;
	self.startOverButton	= nil;
	self.backButton			= nil;
	self.animProgress		= nil;
	self.backgroundImgView	= nil;
	self.recordTimer		= nil;
	self.playTimer			= nil;
	self.animArray			= nil;
	
	[super viewDidUnload];
}

- (void)dealloc {
	
	assert (! recordingAnim);
	assert (! playingAnim);
	
	[playButton			release];
	[recButton			release];
	[anNewButton		release];
	[saveButton			release];
	[loadButton			release];
	[startOverButton	release];
	[backButton			release];
	[animProgress		release];
	[backgroundImgView	release];
	[animImgView		release];
	[recordTimer		release];
	[playTimer			release];
	[animArray			release];
	
	if (self.recorder)
		[recorder		release];
	
	if (self.audioPlayer)
		[audioPlayer	release];

	/*if (appDelegate.gFilePath)
	{
		[appDelegate.gFilePath release];
		appDelegate.gFilePath = nil;
	} */
	
    [super dealloc];
}

@end
