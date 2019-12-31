//
//  ExampleViewController.m
//  Creativity
//
//  Created by Daniel Rencricca on 6/14/11.
//  Copyright 2011 self. All rights reserved.
//

#import "ExampleViewController.h"


@implementation ExampleViewController

@synthesize switchViewDelegate;
@synthesize exampleImgView;


#pragma mark -
#pragma mark Outlets

-(IBAction) goNext {
	
	[switchViewDelegate goDrawView];
}

-(IBAction) goBack {
	
	[switchViewDelegate goIntroView];
}

- (IBAction) getSavedAnimation {
	
	[switchViewDelegate getSavedAnimation];
}

//- (IBAction) startOver {
//	
//	[switchViewDelegate startOver];
//}


#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {

	appDelegate = [[UIApplication sharedApplication] delegate];
	
	// set the example image to display
	[exampleImgView setImage:[appDelegate.gScenImgArray objectAtIndex:appDelegate.gScenarioNum]];
    
	[super viewDidLoad];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
	
	self.exampleImgView = nil;
	
    [super viewDidUnload];
}


- (void)dealloc {
	
	[exampleImgView release];
	
    [super dealloc];
}


@end
