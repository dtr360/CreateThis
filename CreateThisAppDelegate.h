//
//  CreateThisAppDelegate.h
//  Creativity
//
//  Created by Daniel Rencricca on 6/5/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FILE_EXT_DAT   @"cdf"	        // movement/transformation data file
#define FILE_EXT_PNG   @"png"	        // image file 
#define FILE_EXT_CAF   @"caf"	        // audio  file
#define TMP_FILE_AUDIO @"audioTemp.caf" // temporary audio file
#define APP_DIR		   @"CreateThat"    // application data directory
#define SPLASH_DELAY   3.0              // seconds to delay splash screen

// Define the scenario texts and example images.  Must total 5 of each.

#define SCENARIO_01 @"Imagine going to another planet somewhere in the galaxy that is very different from earth and finding an animal there."
#define SCENARIO_02 @"Imagine that you are employed by a toy company that is in need of new ideas for toys. Your task is to design a new and different toy for the company. Do not copy a toy that currently exists."
#define SCENARIO_03 @"Imagine that there are no bricks available and that they have to help the third pig. You will build a house for the third little pig so that when the wolf comes to visit, he will not huff and puff and blow the house down."
#define SCENARIO_04 @"Scenario 04"
#define SCENARIO_05 @"Scenario 05"

#define EXAMPLE_01 [UIImage imageNamed: @"1-Example.png"]
#define EXAMPLE_02 [UIImage imageNamed: @"2-Example.png"]
#define EXAMPLE_03 [UIImage imageNamed: @"2-Example.png"]
#define EXAMPLE_04 [UIImage imageNamed: @"2-Example.png"]
#define EXAMPLE_05 [UIImage imageNamed: @"2-Example.png"]

#define BACKGROUND_01 [UIImage imageNamed: @"1-Alien Planet.png"]
#define BACKGROUND_02 [UIImage imageNamed: @"2-Store.png"]
#define BACKGROUND_03 [UIImage imageNamed: @"3-Forest.png"]
#define BACKGROUND_04 [UIImage imageNamed: @"3-Forest.png"]
#define BACKGROUND_05 [UIImage imageNamed: @"3-Forest.png"]

// Define Dropbox data

#define CONSUMER_KEY    @"ulvwisl6j7mwhw8";
#define CONSUMER_SECRET @"capf5yom26ljdls";
#define	DROPBOX_FOLDER  @"/CreateThat"

@class SwitchViewController;

@interface CreateThisAppDelegate : NSObject <UIApplicationDelegate> {
    
	UIWindow	*window;
	UIImage		*gAnimImg;		// pointer to converted image used in animation
	UIImage		*gUserImg;		// pointer to image drawn by user
	NSString	*gFilePath;     // path to animation data file name
	NSString	*gAppDataDir;   // the application's data directory
	NSArray		*gScenTxtArray; // holds scenario texts
	NSArray		*gScenImgArray;	// holds scenario images
	NSArray		*gBackImgArray;	// holds animation background images
	int			gScenarioNum;
    
    SwitchViewController *switchViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SwitchViewController *switchViewController;

@property (nonatomic, retain) UIImage	*gAnimImg;
@property (nonatomic, retain) UIImage	*gUserImg;
@property (nonatomic, copy)   NSString	*gFilePath;
@property (nonatomic, copy)   NSString	*gAppDataDir;
@property (nonatomic, retain) NSArray   *gScenTxtArray;
@property (nonatomic, retain) NSArray   *gScenImgArray;
@property (nonatomic, retain) NSArray   *gBackImgArray;
@property (nonatomic, assign) int		gScenarioNum;

@end


/*
 Two fundamental rules are:
 1) If you allocate it, create it or copy it, you need to release it.
 2) If you retain it, you need to release it.
 
 As far as rule #1 goes, it's easy to see that the "alloc" and "release" are balanced out when you write code like this.
 
 As far as rule #2 goes, the "retain" that's automatically generated inside the setter is balanced out in one of two places:
 a) By the generated "release" if the setter is called again, or
 b) By the "release" that you wrote into your "dealloc" function.
 */

