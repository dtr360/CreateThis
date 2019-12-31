//
//  IntroViewController.h
//  Creativity
//
//  Created by Daniel Rencricca on 6/14/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewDelegate.h"
#import "CreateThisAppDelegate.h"

@interface IntroViewController: UIViewController {

	IBOutlet UILabel			*scenarioLabel;
	IBOutlet UISegmentedControl	*scenarioCtl;
	
	CreateThisAppDelegate	*appDelegate;
	
	id <SwitchViewDelegate> switchViewDelegate;
}

@property (nonatomic, retain) UILabel				*scenarioLabel;
@property (nonatomic, retain) UISegmentedControl	*scenarioCtl;
@property (nonatomic, assign) id <SwitchViewDelegate> switchViewDelegate;

- (IBAction) goNext;
- (IBAction) getSavedAnimation;
- (IBAction) setScenario;

@end
