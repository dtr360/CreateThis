//
//  IntroViewController.m
//  Creativity
//
//  Created by Daniel Rencricca on 6/14/11.
//  Copyright 2011 self. All rights reserved.
//

#import "IntroViewController.h"

@implementation IntroViewController

@synthesize switchViewDelegate;
@synthesize scenarioLabel;
@synthesize scenarioCtl;


#pragma mark -
#pragma mark Outlets

- (IBAction) goNext {
	
	[switchViewDelegate goExampleView];
}


- (IBAction) getSavedAnimation {
	
	[switchViewDelegate getSavedAnimation];
}


- (IBAction) setScenario {

	NSLog (@"Scenario Selected: %i", scenarioCtl.selectedSegmentIndex);
	
	// make sure segment selected is not more than scenario array (zero based)
	if (scenarioCtl.selectedSegmentIndex >= [appDelegate.gScenTxtArray count])
		return;
	
	appDelegate.gScenarioNum = scenarioCtl.selectedSegmentIndex;

	[scenarioLabel setText:[appDelegate.gScenTxtArray objectAtIndex:appDelegate.gScenarioNum]];
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {

	appDelegate = [[UIApplication sharedApplication] delegate];	
	
	assert (appDelegate.gScenarioNum <= [appDelegate.gScenTxtArray count]);
	
	// set scenario text
	[scenarioLabel setText:[appDelegate.gScenTxtArray objectAtIndex:appDelegate.gScenarioNum]];
	
	scenarioCtl.selectedSegmentIndex = appDelegate.gScenarioNum;

	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	self.scenarioCtl	= nil;
	self.scenarioCtl	= nil;

	[super viewDidUnload];
 }


- (void)dealloc {
	
	[scenarioLabel release];
	[scenarioCtl	release];
    
	[super dealloc];
}


@end
