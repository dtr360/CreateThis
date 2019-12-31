//
//  FileSelectViewController.h
//  Creativity
//
//  Created by Daniel Rencricca on 7/5/11.
//  Copyright 2011 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CreateThisAppDelegate.h"
#import "DropboxSDK.h"

@protocol FileSelectViewDelegate <NSObject>

- (void) didDismissFileSelectView;

@end

@class DBRestClient;

@interface FileSelectViewController : UIViewController <UIAlertViewDelegate, DBLoginControllerDelegate> {
	
	IBOutlet UITableView	*fileTableView; // table for file list
	IBOutlet UITextField	*fileNameText;  // name of file selected by user	
	IBOutlet UIButton		*selectButton;  // select highlighted file
	IBOutlet UIButton		*unlinkButton;
	IBOutlet UIButton		*loadDropboxButton;
	//IBOutlet UILabel		*waitLabel;
	IBOutlet UILabel		*linkedLabel;
	NSString				*currentPath;
	NSString				*fileSelected;
	DBRestClient			*restClient;    // to save via Dropbox
	NSMutableArray			*data;
	Boolean					editing;
    int                     saveCount;
    
	
	id<FileSelectViewDelegate> fileSelectDelegate;
	
	CreateThisAppDelegate	*appDelegate;
}

@property (nonatomic, retain) UITableView		*fileTableView;
@property (nonatomic, retain) UITextField		*fileNameText;
@property (nonatomic, retain) UIButton			*selectButton;
@property (nonatomic, retain) UIButton			*unlinkButton;
@property (nonatomic, retain) UIButton			*loadDropboxButton;
@property (nonatomic, copy)   NSString			*currentPath;
@property (nonatomic, copy)	  NSString			*fileSelected;
@property (nonatomic, retain) NSMutableArray	*data;

@property (nonatomic, assign) id<FileSelectViewDelegate> fileSelectDelegate;

- (IBAction)		selectFile;
- (IBAction)		unlinkPressed;
- (IBAction)		loadDropbox;
- (void)			getFilesFromDropBox;
- (void)			deleteFile;
- (void)			updateLinkInfo;
- (void)			createSession;
- (DBRestClient*)	restClient; 

@end
