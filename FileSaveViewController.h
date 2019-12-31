//
//  FileSaveViewController.h
//  Creativity
//
//  Created by Daniel Rencricca on 7/7/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateThisAppDelegate.h"
#import "DropboxSDK.h"

@protocol FileSaveViewDelegate <NSObject>

- (void) didDismissFileSaveView: (BOOL) saveFile;

@end

@class DBRestClient;

@interface FileSaveViewController : UIViewController <UIAlertViewDelegate, DBLoginControllerDelegate> {
	
	IBOutlet UIButton		*saveButton;
	IBOutlet UIButton		*saveDropboxButton;
	IBOutlet UIButton		*unlinkButton;
	IBOutlet UITextField	*fileNameText;  // name of file saved by user
	IBOutlet UILabel		*waitLabel;
	IBOutlet UILabel		*linkedLabel;
	DBRestClient			*restClient;    // to save via Dropbox
	NSMutableArray			*animArray;     // animation array to save
	BOOL					saveToDropbox;  // true if saving files to Dropbox
    int                     saveCount;

 
	id<FileSaveViewDelegate> fileSaveDelegate;
	
	CreateThisAppDelegate	*appDelegate;
}

@property (nonatomic, retain) UITextField	*fileNameText;
@property (nonatomic, retain) UIButton		*saveButton;
@property (nonatomic, retain) UIButton		*unlinkButton;
@property (nonatomic, retain) UIButton		*saveDropboxButton;
@property (nonatomic, retain) UILabel		*waitLabel;
@property (nonatomic, retain) UILabel		*linkedLabel;

@property (nonatomic, assign) id<FileSaveViewDelegate> fileSaveDelegate;

- (IBAction)		saveDevice;
- (IBAction)		saveDropbox;
- (IBAction)		unlinkPressed;
- (void)			saveFile;
- (void)			saveAnimation;
- (void)			createSession;
- (void)			updateLinkInfo;
- (void)			setAnimArray: (NSMutableArray*) animDataArray;
- (DBRestClient*)	restClient; 

@end
