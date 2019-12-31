//
//  SplashViewController.m
//  EatWords
//
//  Created by Daniel Rencricca on 2/13/11.
//  Copyright 2011 self. All rights reserved.
//

#import "SwitchViewController.h"
#import "SplashViewController.h"
#import "DrawViewController.h"
#import "AnimateViewController.h"
#import "ExampleViewController.h"
#import "IntroViewController.h"

@implementation SwitchViewController

@synthesize splashViewController;
@synthesize drawViewController;
@synthesize animateViewController;
@synthesize exampleViewController;
@synthesize introViewController;


#pragma mark -
#pragma mark SplashView methods

- (void) loadSplashView
{
	NSLog(@"loadSplashView");
	
	assert (self.splashViewController.view.superview == nil);
	assert (self.splashViewController == nil);

	SplashViewController* splashController = 
	[[SplashViewController alloc] initWithNibName:@"SplashView" bundle:nil];
	self.splashViewController = splashController;
	
	animateViewController.switchViewDelegate = self; // set delegate
	
	[splashController release];
	
	[self.view insertSubview:splashViewController.view atIndex:0];	
}


- (void) removeSplashView
{
	NSLog(@"removeSplashView");
	[splashViewController.view removeFromSuperview];
	self.splashViewController = nil;
}

#pragma mark -
#pragma mark AnimateView methods


- (void) loadAnimateView
{
	NSLog(@"loadAnimateView");
	
	assert(self.animateViewController.view.superview == nil);
	assert(self.animateViewController == nil);
	
	// switch to the animation recorder
	AnimateViewController* animateController = 
	[[AnimateViewController alloc] initWithNibName:@"AnimateView" bundle:nil];
	self.animateViewController = animateController;
	
	animateViewController.switchViewDelegate = self; // set delegate

	[animateController release];

	[self.view insertSubview:animateViewController.view atIndex:0];
}

- (void) removeAnimateView
{
	NSLog(@"removeAnimateView");
	
	if (self.animateViewController) 
	{
		[animateViewController.view removeFromSuperview];
		self.animateViewController = nil;
	}
}
 
- (void) goAnimateView {
	
	NSLog(@"In goAnimateView");
		
	// convert the drawn image to a UIImageView.
	bool haveImg = self.drawViewController.convertImg;
	
	if (!haveImg)
	{		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
                              message:@"Sorry, but you have to draw something first"
							  delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		
		return;
	}
	
	// remove prior view
	[self removeDrawView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: 1.00];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	assert(self.animateViewController.view.superview == nil);
	assert(self.animateViewController == nil);
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight 
							   forView:self.view cache:YES];
	[self loadAnimateView];

	[UIView commitAnimations];
	
	NSLog(@"Exiting goAnimateView");
}

#pragma mark -
#pragma mark DrawView methods

- (void) loadDrawView
{
	NSLog(@"loadDrawView");
	
	assert (self.drawViewController.view.superview == nil);
	assert (self.drawViewController == nil);
	
	DrawViewController* drawController = 
	[[DrawViewController alloc] initWithNibName:@"DrawView" bundle:nil];
	self.drawViewController = drawController;
	drawViewController.switchViewDelegate = self; // set the delegate for drawViewController
	[drawController release];

	[self.view insertSubview:drawViewController.view atIndex:0];
}


- (void) removeDrawView
{
	NSLog(@"removeDrawView");
	
	if (self.drawViewController)
	{
		[drawViewController.view removeFromSuperview];
		self.drawViewController = nil;
	}
}


- (void) goDrawView {
	
	NSLog(@"In goDrawView");
	
	// remove prior view depending if user moving forward or backward
	[self removeExampleView];
	
	[self removeAnimateView];
	
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: 1.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight 
				forView:self.view cache:YES];
	
	[self loadDrawView];
	
	[UIView commitAnimations];
	
	NSLog(@"Exiting goDrawView");
}

#pragma mark -
#pragma mark ExampleView methods

- (void) loadExampleView
{
	NSLog(@"loadExampleView");
	
	assert(self.exampleViewController.view.superview == nil);
	assert (self.exampleViewController == nil);

	ExampleViewController* exampleController = 
	[[ExampleViewController alloc] initWithNibName:@"ExampleView" bundle:nil];
	self.exampleViewController = exampleController;
	exampleViewController.switchViewDelegate = self;
	[exampleController release];
 
	[self.view insertSubview:exampleViewController.view atIndex:0];
}


- (void) removeExampleView
{
	NSLog(@"removeExampleView");
	
	if (self.exampleViewController)
	{
		[exampleViewController.view removeFromSuperview];
		self.exampleViewController = nil;
	}
}

- (void) goExampleView {

	// remove the prior view depending if user moving forward or backward
	[self removeIntroView];
	
	[self removeDrawView];
		
	NSLog(@"In goExampleView");
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: 1.00];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight 
						   forView:self.view cache:YES];
	[self loadExampleView];
	
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark IntroView methods

- (void) loadIntroView
{
	NSLog(@"loadIntroView");
	
	assert (self.introViewController.view.superview == nil);
	assert (self.introViewController == nil);
	
	IntroViewController* introController = 
	[[IntroViewController alloc] initWithNibName:@"IntroView" bundle:nil];
	self.introViewController = introController;
	introViewController.switchViewDelegate = self;
	[introController release];
	
	[self.view insertSubview:introViewController.view atIndex:0];
}


- (void) removeIntroView
{
	NSLog(@"removeIntroView");
	
	if (self.introViewController)
	{
		[introViewController.view removeFromSuperview];
		self.introViewController = nil;
	}
}

- (void) goIntroView {
	
	// remove the prior view depending if user moving forward or backward
	// do not remove splashView as it will be done after delay in viewDidLoad
	
	[self removeExampleView];
	
	NSLog(@"In goIntroView");
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration: 1.00];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	
	[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight 
						   forView:self.view cache:YES];
	
	[self loadIntroView];
		
	[UIView commitAnimations];
}


#pragma mark -
#pragma mark Outlets

- (IBAction) startOver
{
	if (appDelegate.gUserImg  != nil)
	{
		[appDelegate.gUserImg release];
		appDelegate.gUserImg  = nil;
	}
	
	if (appDelegate.gAnimImg != nil)
	{
		[appDelegate.gAnimImg release];
		appDelegate.gAnimImg  = nil;
	}
	
	[self removeExampleView];
	[self removeAnimateView];
	[self removeDrawView];
		
	[self goIntroView];
}


- (IBAction) getSavedAnimation
{
	NSLog(@"getSavedAnimation");

	// Create file path to documents directory where user animation file has been saved
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDir = [paths objectAtIndex:0];
	
	// create the default directory for saving animations
	NSString *appDataDir = [documentsDir stringByAppendingPathComponent:APP_DIR];
	
	// if app directory does not exist then create it	
	BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath: appDataDir
					withIntermediateDirectories: YES attributes: nil error: nil];
	if (!success)
	{
		NSLog(@"appDataDir: %@", appDataDir);
		return;
	}
	
	// Create the modal view controller
	FileSelectViewController *viewController = [[FileSelectViewController alloc]
											initWithNibName:@"FileSelectView" bundle:nil];
	
	// We are the delegate responsible for dismissing the modal view 
	viewController.fileSelectDelegate = self;
	
	// Create a Navigation controller
	UINavigationController *navController = [[UINavigationController alloc]
											 initWithRootViewController:viewController];
	
	// set current path to application data directory
	[viewController setCurrentPath: appDataDir];
	
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
			
	// show the navigation controller modally
	[self presentModalViewController:navController animated:YES];
	
	// clean up resources
	[navController  release];
	[viewController release];
}

// called when user exits the File Select window
- (void) didDismissFileSelectView {
	
	appDelegate = [[UIApplication sharedApplication] delegate];

    // dismiss the modal view controller
    [self dismissModalViewControllerAnimated:YES];
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:appDelegate.gFilePath])
	{
		NSLog(@"File does not exist: %@", appDelegate.gFilePath);
		return;
	}

	[self removeIntroView];
	
	[self removeExampleView];
	
	[self removeAnimateView];
	
	// set global variables to nil
	if (appDelegate.gAnimImg != nil)
	{
		[appDelegate.gAnimImg release];
		appDelegate.gAnimImg  = nil;
	}
	
	if (appDelegate.gUserImg != nil)
	{
		[appDelegate.gUserImg release];
		appDelegate.gUserImg   = nil;
	}
		
	assert (self.animateViewController.view.superview == nil);
	assert (self.animateViewController == nil);
	
	// switch to the animation recorder
	AnimateViewController* animateController = 
	[[AnimateViewController alloc] initWithNibName:@"AnimateView" bundle:nil];
	self.animateViewController = animateController;
	
	animateViewController.switchViewDelegate = self; // set delegate
	
	[animateController release];
	
	// load in the animation files
	[animateViewController getAnimationFile];
	
	[self.view insertSubview:animateViewController.view atIndex:0];
}

// get the path and name of the animation files
- (void) getAnimationFileName: (NSMutableArray*) animArray {
	
	NSLog(@"getAnimationFileName");
		
	// create the modal view controller
	FileSaveViewController *viewController = [[FileSaveViewController alloc]
												initWithNibName:@"FileSaveView" bundle:nil];
	
	// We are the delegate responsible for dismissing the modal view 
	viewController.fileSaveDelegate = self;
	
	[viewController setAnimArray: animArray];
	
	// Create a Navigation controller
	UINavigationController *navController = [[UINavigationController alloc]
											 initWithRootViewController:viewController];
		
	navController.modalPresentationStyle = UIModalPresentationFormSheet;
	
	// show the navigation controller modally
	[self presentModalViewController:navController animated:YES];
	
	// clean up resources
	[navController  release];
	[viewController release];
}

// called when user closes the file save window
- (void) didDismissFileSaveView:(BOOL)saveFile {
	
    // dismiss the modal view controller
    [self dismissModalViewControllerAnimated:YES];
}


-(void) createAppDirectory {
	
	BOOL wasErr = NO;
	
	NSFileManager *filemgr = [NSFileManager defaultManager];
	
	// search for the app's documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *documentsDir = [paths objectAtIndex:0];
	
	NSString *appDataDir = [documentsDir stringByAppendingPathComponent:APP_DIR];
	
	// save application data directory
	appDelegate.gAppDataDir = [appDataDir copy];
	
	// if file already exists then do not create it
	if ([filemgr fileExistsAtPath: appDataDir])
		return;
		
	// create the default directory for saving animation	
	NSLog (@"Creating default application data directory: %@", appDataDir);
	
	wasErr = ![filemgr createDirectoryAtPath: appDataDir withIntermediateDirectories: YES 
                                  attributes: nil error: nil];
	if (wasErr)
	{		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
                              message:@"Could not create app directory." 
                              delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}	


#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) viewDidLoad 
{	
	NSLog(@"SwitchViewController: viewDidLoad");

	appDelegate = [[UIApplication sharedApplication] delegate];

	// initialize gScenTxtArray with example texts for IntroViewController
	appDelegate.gScenTxtArray = [[NSArray alloc] initWithObjects: 
								 SCENARIO_01,
								 SCENARIO_02,
								 //SCENARIO_03,
								 //SCENARIO_04,
								 //SCENARIO_05,
								 nil];
	
	// initialize gScenImgArray with example images for ExamplesViewController
	appDelegate.gScenImgArray = [[NSArray alloc] initWithObjects:	
								 EXAMPLE_01,
								 EXAMPLE_02,
								 //EXAMPLE_03,
								 //EXAMPLE_04,
								 //EXAMPLE_05,
								 nil];
	
	// initialize gScenImgArray with example images for AnimateViewController
	appDelegate.gBackImgArray = [[NSArray alloc] initWithObjects:	
								 BACKGROUND_01,
								 BACKGROUND_02,
								 //BACKGROUND_03,
								 //BACKGROUND_04,
								 //BACKGROUND_05,
								 nil];
	
	
	assert ([appDelegate.gScenImgArray count] == [appDelegate.gScenTxtArray count]);
	assert ([appDelegate.gScenImgArray count] == [appDelegate.gBackImgArray count]);
	
	NSLog (@"Initializing Globals to NIL - should only see this once");
	appDelegate.gFilePath	= nil;
	appDelegate.gAnimImg	= nil;
	appDelegate.gUserImg	= nil;
	appDelegate.gAppDataDir	= nil;
	
	// create application data directory if it does not exist
	[self createAppDirectory];
	
	[self loadSplashView];	
	
	// hold the splash screen for 2 seconds
	[self performSelector: @selector(removeSplashView) withObject:nil afterDelay:SPLASH_DELAY];
	
	[self goIntroView];		

	[super viewDidLoad];
}

#pragma mark -
#pragma mark Memory management

- (void) didReceiveMemoryWarning 
{
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload 
{
	self.splashViewController  = nil;
	self.drawViewController    = nil;
	self.animateViewController = nil;
	self.exampleViewController = nil;
	self.introViewController   = nil;

	[super viewDidUnload];
}


- (void)dealloc 
{
	[splashViewController	release];
	[drawViewController		release];
	[animateViewController	release];
	[exampleViewController	release];
	[introViewController	release];

	[super dealloc];
}

@end