//
//  CreateThisAppDelegate.m
//  Creativity
//
//  Created by Daniel Rencricca on 6/9/11.
//  Copyright 2011 self. All rights reserved.
//

#import "CreateThisAppDelegate.h"
#import "SwitchViewController.h"

@implementation CreateThisAppDelegate

@synthesize window;
@synthesize switchViewController;
@synthesize gScenTxtArray;
@synthesize gScenImgArray;
@synthesize gBackImgArray;
@synthesize	gAnimImg;
@synthesize	gUserImg;
@synthesize gFilePath;
@synthesize gAppDataDir;
@synthesize gScenarioNum;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	// init
	NSLog(@"CreateThisAppDelegate: didFinishLaunchingWithOPtions");
    
	self.gUserImg   = nil;
	self.gAnimImg   = nil;
	
    // Override point for customization after application launch.
	[self.window addSubview:switchViewController.view];
    
    [self.window makeKeyAndVisible];
	
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void) applicationDidEnterBackground:(UIApplication *)application 
{   
	[[NSNotificationCenter defaultCenter] postNotificationName: @"didEnterBackground" 
														object: nil 
													  userInfo: nil];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    
	[gAnimImg				release];
	[gUserImg				release];
	[gFilePath				release];
	[gAppDataDir			release];
	[gScenTxtArray			release];
	[gScenImgArray			release];
	[gBackImgArray			release];
	//[gScenarioNum			release]; do not release
    [window					release];
	[switchViewController	release];
	
    [super dealloc];
}

@end

