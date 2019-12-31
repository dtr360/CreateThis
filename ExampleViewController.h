//
//  ExampleViewController.h
//  Creativity
//
//  Created by Daniel Rencricca on 6/14/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewDelegate.h"
#import "CreateThisAppDelegate.h"


@interface ExampleViewController : UIViewController {
	
	IBOutlet UIImageView	*exampleImgView;
	
	CreateThisAppDelegate	*appDelegate;

	id <SwitchViewDelegate> switchViewDelegate;	
}

@property (nonatomic, retain) UIImageView *exampleImgView;
@property (nonatomic, assign) id <SwitchViewDelegate> switchViewDelegate;

-(IBAction) goNext;
-(IBAction) goBack;
-(IBAction) getSavedAnimation;

@end
