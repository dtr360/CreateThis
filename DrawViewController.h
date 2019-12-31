//
//  DrawViewController.h
//  Creativity
//
//  Created by Dan Rencricca on 6/5/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SwitchViewDelegate.h"
#import "CreateThisAppDelegate.h"


#define PIC_BORDER   18
#define PIC_MAX_SZ   200
#define BRUSH_SMALL  7
#define BRUSH_MEDIUM 14
#define BRUSH_LARGE  28

@interface DrawViewController : UIViewController <UIAlertViewDelegate>
{
	
	IBOutlet UIButton			*brushSmButton;
	IBOutlet UIButton			*brushMdButton;
	IBOutlet UIButton			*brushLgButton;
	IBOutlet UIButton			*eraserButton;
	IBOutlet UIImageView		*userImgView;
	IBOutlet UIImageView		*colorSelectedImg;
	IBOutlet UIImageView		*colorbarImg;
	CGColorRef					drawColor;
	CGColorRef					priorDrawColor;
	CGPoint						lastPoint;	
	float						brushWidth;
	bool						usingEraser;
	
	CreateThisAppDelegate		*appDelegate;

	id <SwitchViewDelegate> switchViewDelegate;
}

@property (nonatomic, retain) UIButton		*brushSmButton;
@property (nonatomic, retain) UIButton		*brushMdButton;
@property (nonatomic, retain) UIButton		*brushLgButton;
@property (nonatomic, retain) UIButton		*eraserButton;
@property (nonatomic, retain) UIImageView	*userImgView;
@property (nonatomic, retain) UIImageView	*colorSelectedImg;
@property (nonatomic, retain) UIImageView	*colorbarImg;

@property (nonatomic, assign) id <SwitchViewDelegate> switchViewDelegate;

-(IBAction) setBrushSm;
-(IBAction) setBrushMd;
-(IBAction) setBrushLg;
-(IBAction) useEraser;
-(IBAction) goNext;
-(IBAction) goBack;
-(IBAction) startOver;
-(IBAction) eraseImage;


-(CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage: (int) borderW;
-(CGContextRef) createARGBBitmapContext:(CGImageRef) inImage;
-(bool) convertImg;
-(void) createCanvas;
-(void) redrawImage;
-(bool) contact:(unsigned char*) pixelArray: (int) x: (int) y: (int) w: (int) h;
-(void) setBrushColor: (CGPoint) point;

@end