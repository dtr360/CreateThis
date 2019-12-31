//
//  SwitchViewDelegate.h
//  Creativity
//
//  Created by Daniel Rencricca on 6/18/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SwitchViewDelegate

- (void) startOver;
- (void) goDrawView;
- (void) goAnimateView;
- (void) goExampleView;
- (void) goIntroView;
- (void) getSavedAnimation;
- (void) getAnimationFileName: (NSMutableArray*) animArray;

@end