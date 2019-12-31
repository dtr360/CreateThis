    //
//  FileSaveViewController.m
//  Creativity
//
//  Created by Daniel Rencricca on 7/7/11.
//  Copyright 2011 self. All rights reserved.
//

#import "FileSaveViewController.h"
#import "DropboxSDK.h"


@interface FileSaveViewController () <DBRestClientDelegate>



@property (nonatomic, readonly) DBRestClient* restClient;

- (DBRestClient*) restClient;
- (void)		  restClient: (DBRestClient *) client uploadedFile: (NSString *) srcPath;
- (void)		  restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error;

@end


@implementation FileSaveViewController

@synthesize fileSaveDelegate;
@synthesize fileNameText;
@synthesize saveButton;
@synthesize unlinkButton;
@synthesize saveDropboxButton;
@synthesize waitLabel;
@synthesize	linkedLabel;

#pragma mark -
#pragma mark Outlets

- (IBAction) saveDropbox {
	
	if (![[DBSession sharedSession] isLinked])
	{
		[[[[UIAlertView alloc] 
		   initWithTitle:@"Account Unlinked!" message:@"Press the Link button to connect to Dropbox" 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		  autorelease] show];				
		
		return;
	}
		
	saveToDropbox = true;
	
	[self saveFile];	
}

- (IBAction) saveDevice {
		
	saveToDropbox = false;
	
	[self saveFile];
}

// Done button clicked in Navigation Bar
- (void) dismissView {
	
    // call the delegate to dismiss the modal view
    [fileSaveDelegate didDismissFileSaveView:NO];
}



- (IBAction) updateLinkInfo {

	if ([[DBSession sharedSession] isLinked])
	{
		[linkedLabel setText: @"Linked"];
		[unlinkButton setTitle: @"Unlink" forState: UIControlStateNormal];
		NSLog(@"Dropbox is Linked");
	}
	else
	{
		[linkedLabel setText: @"Unlinked"];
		[unlinkButton setTitle: @"Link" forState: UIControlStateNormal];
		NSLog(@"Dropbox is Unlinked");
	}
}



- (IBAction) unlinkPressed {
	
	if ([[DBSession sharedSession] isLinked]) 
	{
        [[DBSession sharedSession] unlink];
		
		[restClient release];
		restClient = nil;
    
		[[[[UIAlertView alloc] 
			initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked" 
			delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
			autorelease] show];				

		[self updateLinkInfo];
	}
	else 
	{
		DBLoginController* controller = [[DBLoginController new] autorelease];
		controller.delegate = self;
		[controller presentFromController: self];		
	}
}



#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}

- (void) createSession {
	
	// Set these variables before launching the app
    NSString* consumerKey    = CONSUMER_KEY;
	NSString* consumerSecret = CONSUMER_SECRET;
	
	DBSession* session = 
	[[[DBSession alloc] initWithConsumerKey:consumerKey consumerSecret:consumerSecret] autorelease];
	
	[DBSession setSharedSession: session];	
}


- (void) viewDidLoad {
		
	appDelegate = [[UIApplication sharedApplication] delegate];
	
    // Override the right button to show a Done button that is used to dismiss the modal view	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
											   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
											   target:self
											   action:@selector(dismissView)] autorelease];
	
	// select text box upon open
	[fileNameText becomeFirstResponder];
	
	restClient = nil; // init

	// create Dropbox session
	[self createSession];
	
	[self updateLinkInfo];
		
	[super viewDidLoad];
}


#pragma mark -
#pragma mark Save method

- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex {
    
	if ([alertView tag] == 2000) 
	{
        if (buttonIndex == 0) // ok button
		{
			NSString *dropboxFileName = [[DROPBOX_FOLDER stringByAppendingPathComponent:fileNameText.text] 
										 stringByAppendingPathExtension: FILE_EXT_DAT];
			
			NSLog(@"File on Dropbox:%@", dropboxFileName);
			
			[self saveAnimation];
			
			if (!saveToDropbox)
				[fileSaveDelegate didDismissFileSaveView:YES];		
        }
		else if (buttonIndex == 1) // cancel button
		{
			// do nothing
		}
		
    }
}

- (void) saveFile {
	
	// if no file selected then ignore button tap
	if (fileNameText.text == nil)
		return;
	
	// remove begining and trailing spaces from file name entered
	NSString *fileName = [fileNameText.text stringByTrimmingCharactersInSet:
						  [NSCharacterSet whitespaceAndNewlineCharacterSet]];
	
	fileNameText.text = fileName;
	
	// get entire file path
	NSString *baseFilePath = [appDelegate.gAppDataDir stringByAppendingPathComponent:fileName];
	
	baseFilePath = [[baseFilePath stringByDeletingPathExtension] 
					stringByAppendingPathExtension: FILE_EXT_DAT];
	
	NSLog (@"Saving file at: %@", baseFilePath);
	
	// if file exists then warn user of overwrite
	if ([[NSFileManager defaultManager] fileExistsAtPath:baseFilePath])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL 
							   message: @"A file already exists with that name. Do you want to overwrite it?"
							   delegate: self cancelButtonTitle: @"Yes" otherButtonTitles: @"No", nil];
		[alert setTag:2000];
		[alert show];
		[alert release];
	}
	else 
	{
		NSString *dropboxFileName = [[DROPBOX_FOLDER stringByAppendingPathComponent:fileNameText.text] 
									 stringByAppendingPathExtension: FILE_EXT_DAT];
		
		NSLog(@"File on Dropbox:%@", dropboxFileName);
		
		[self saveAnimation];

		if (!saveToDropbox)
			[fileSaveDelegate didDismissFileSaveView:YES];
	}
}

- (void) saveAnimation
{
	BOOL wasErr = false;
		
	// save user file name without any extension user may have added
	NSString *fileName = [[fileNameText.text stringByDeletingPathExtension] copy];
	
	// Create file paths where user animation files will be saved //
	
	NSFileManager *filemgr = [NSFileManager defaultManager];
	
	// create the full audio file path by appending a file name
	NSString *userAudioPath = [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileName]
							   stringByAppendingPathExtension:FILE_EXT_CAF];
	
	NSString *audioPathTmp  = [appDelegate.gAppDataDir stringByAppendingPathComponent: TMP_FILE_AUDIO];
	
	// create the full animation data path by appending a file name
	NSString *userDataPath = [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileName]
							  stringByAppendingPathExtension:FILE_EXT_DAT];
	
	// create the full image file path by appending a file name
	NSString *userImagePath = [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileName]
							   stringByAppendingPathExtension:FILE_EXT_PNG];
	
	if (wasErr) goto ErrorExit;
	
	// check if there is already a file name in gFilePath. This may have gotten there if user
	// opened a saved animation file or if user already saved an animation.
	if (appDelegate.gFilePath != nil)
	{
		// we cannot overwrite a file on the device, so if user attempts this then skip
		if ([appDelegate.gFilePath caseInsensitiveCompare: userDataPath] == NSOrderedSame)
		{
			goto SaveDropbox;
		}
						
		[appDelegate.gFilePath release];		
		appDelegate.gFilePath = [userDataPath copy];
	}
	
	// remove existing files if they exist
	[filemgr removeItemAtPath:userAudioPath error:NULL];
	[filemgr removeItemAtPath:userDataPath  error:NULL];
	[filemgr removeItemAtPath:userImagePath error:NULL];	
	
	// copy audio file to new file name
	NSLog (@"Copying audio from: %@", audioPathTmp);
	NSLog (@"Copying audio to: %@", userAudioPath);
	
	if (![filemgr fileExistsAtPath:audioPathTmp])
		NSLog(@"File does not exist: %@", audioPathTmp);	
	
	wasErr = ([filemgr copyItemAtPath: audioPathTmp toPath: userAudioPath error: NULL] == NO);
	
	if (wasErr) goto ErrorExit;
	
	// convert image to NSData object so it can be saved
	NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation (appDelegate.gAnimImg)];
	
	// write the image data to a file
	NSLog (@"Saving image data to: %@", userImagePath);
	
	wasErr = ![imageData writeToFile:userImagePath atomically:YES];
	
	imageData = nil;
	
	if (![filemgr fileExistsAtPath:userImagePath])
		NSLog(@"File does not exist: %@", userImagePath);	
	
	if (wasErr) goto ErrorExit;
	
	// save animation data to file
	NSLog (@"Saving animation data to: %@", userDataPath);
	
	//	NOTE: do not release path, documentsDir userImagePath nor imageData or else CRASH
	
	// write the file and alert user to any problems
	wasErr = ([animArray writeToFile: userDataPath atomically:YES] == NO);
	
	if (wasErr) goto ErrorExit;
	
	SaveDropbox:
	
	// save files to Dropbox
	if (saveToDropbox)
	{	
		[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
		
		waitLabel.hidden			= false;
		
		unlinkButton.enabled		= false;
		unlinkButton.alpha			= 0.5f;
		
		saveButton.enabled			= false;
		saveButton.alpha			= 0.5f;
		
		saveDropboxButton.enabled	= false;
		saveDropboxButton.alpha		= 0.5f;
		
		// set the count of total files to be saved
		saveCount = 3;
		
		NSString *dropFileName = [fileName stringByAppendingPathExtension:FILE_EXT_DAT];
		[self.restClient uploadFile: dropFileName toPath: DROPBOX_FOLDER fromPath: userDataPath];
		
		dropFileName = [fileName stringByAppendingPathExtension:FILE_EXT_CAF];
		[self.restClient uploadFile: dropFileName toPath: DROPBOX_FOLDER fromPath: userAudioPath];
		
		dropFileName = [fileName stringByAppendingPathExtension:FILE_EXT_PNG];
		[self.restClient uploadFile: dropFileName toPath: DROPBOX_FOLDER fromPath: userImagePath];
		
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;	
	}
	
	ErrorExit:
	
	if (wasErr)
	{		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle :@"Error" message: @"Sorry, could not save your file." 
							  delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
	
	[fileName release];
}


#pragma mark -
#pragma mark DBLoginControllerDelegate methods (Dropbox)

- (void)loginControllerDidLogin:(DBLoginController*)controller {
	
	[self updateLinkInfo];
	
	[self createSession]; // must do this here!
}

- (void)loginControllerDidCancel:(DBLoginController*)controller {
	
	[self.navigationController popToViewController:self animated:YES];
}


#pragma mark -
#pragma mark DBRestClientDelegate methods (Dropbox)

- (DBRestClient*) restClient {
    
	if (restClient == nil) 
	{
    	restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	restClient.delegate = self;
		
		NSLog (@"Initializing RestClient");
    }
	
    return restClient;
}


//- (void)restClient: (DBRestClient*)client uploadProgress: (CGFloat)progress forFile: (NSString *)destPath from:(NSString *)srcPath {
//	
//	NSLog(@"%0.00f",progress);
//}


// called when a file has been successfully updated to Dropbox
- (void) restClient: (DBRestClient *) client uploadedFile: (NSString *) srcPath {
	
    NSString *filename = [[srcPath pathComponents]lastObject];
	
	NSLog (@"Uploaded File:%@",filename);
	
	saveCount--;
	
	if (saveCount == 0)
	{
		[fileSaveDelegate didDismissFileSaveView:YES];
	}
}

// called if error uploading file to Dropbox
- (void) restClient: (DBRestClient *)client loadFileFailedWithError:(NSError *) error {

	UIAlertView *alert = [[UIAlertView alloc] 
						  initWithTitle: @"Error" message: @"Could not save your file to Dropbox." 
						  delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


// Note: the path will return isDeleted if: 1) the file has been deleted, 2) the file has been renamed,
// or 3) the file has been moved. This applies to folders as well as files.
/*
- (void) restClient: (DBRestClient*) aClient loadedMetadata: (DBMetadata*) metadata {
	
	NSLog (@"loadedMetadata");

	if (metadata.isDeleted) 
	{
		// path doesn't exist
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Exists" 
														message:@"Could not save your file to Dropbox. Select a  different file name." 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
} */

//  A 404 error indicates that path has never existed.
- (void) restClient: (DBRestClient*)aClient loadMetadataFailedWithError: (NSError*) error {
	
	NSLog(@"loadMetadataFailedWithError");
	
	if ([error code] == 404) 
	{
		// path doesn't exist
		
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle: NULL message: @"Could not save your file to Dropbox. Select a  different file name." 
							  delegate: nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}


#pragma mark -
#pragma mark Memory management

- (void)viewDidUnload {
	
	self.saveButton			= nil;
	self.unlinkButton		= nil;
	self.saveDropboxButton	= nil;
	self.fileNameText		= nil;
	self.waitLabel			= nil;
	self.linkedLabel		= nil;
	
	[super viewDidUnload];
}


- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	
	[saveButton			release];
	[unlinkButton		release];
	[saveDropboxButton	release];
	[fileNameText		release];
	[waitLabel			release];
	[linkedLabel		release];
	[restClient			release];
    
	[super dealloc];
}

- (void) setAnimArray: (NSMutableArray*) animDataArray {
	
	animArray = animDataArray;
}

@end
