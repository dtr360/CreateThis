//
//  SplashViewController.h
//  SwitchViewController
//
//  Created by Daniel Rencricca on 6/6/11.
//  Copyright 2011. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewDelegate.h"
#import "CreateThisAppDelegate.h"
#import "FileSelectViewController.h"
#import "FileSaveViewController.h"
#import "IntroViewController.h"


@class SplashViewController;
@class DrawViewController;
@class AnimateViewController;
@class ExampleViewController;
@class IntroViewController;


@interface SwitchViewController : UIViewController <SwitchViewDelegate, FileSelectViewDelegate, FileSaveViewDelegate> 
{
	SplashViewController		*splashViewController;
	DrawViewController			*drawViewController;
	AnimateViewController		*animateViewController;
	ExampleViewController		*exampleViewController;
	IntroViewController			*introViewController;
	int							scenarioNum;
	
	CreateThisAppDelegate		*appDelegate;
}

@property (retain, nonatomic) SplashViewController	*splashViewController;
@property (retain, nonatomic) DrawViewController	*drawViewController;
@property (retain, nonatomic) AnimateViewController	*animateViewController;
@property (retain, nonatomic) ExampleViewController	*exampleViewController;
@property (retain, nonatomic) IntroViewController	*introViewController;

-(void) loadSplashView;
-(void) removeSplashView;

-(void) loadDrawView;
-(void) removeDrawView;
-(void) goDrawView;

-(void) loadAnimateView;
-(void) removeAnimateView;
-(void) goAnimateView;

-(void) loadExampleView;
-(void) removeExampleView;
-(void) goExampleView;

-(void) loadIntroView;
-(void) removeIntroView;
-(void) goIntroView;

-(void) startOver;
-(void) getSavedAnimation;
-(void) getAnimationFileName: (NSMutableArray*) animArray;

-(void) createAppDirectory;

@end

