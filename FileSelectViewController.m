//
//  FileSelectViewController.m
//  Creativity
//
//  Created by Daniel Rencricca on 7/5/11.
//  Copyright 2011 self. All rights reserved.
//

#import "FileSelectViewController.h"
#import "DropboxSDK.h"



@interface FileSelectViewController () <DBRestClientDelegate>



@property (nonatomic, readonly) DBRestClient* restClient;

- (DBRestClient*) restClient;
- (void)		  restClient: (DBRestClient *) client loadedFile: (NSString*) destPath;
- (void)		  restClient: (DBRestClient *) client loadFileFailedWithError: (NSError *) error;

@end


@implementation FileSelectViewController

@synthesize fileTableView;
@synthesize fileSelectDelegate;
@synthesize currentPath;
@synthesize fileSelected;
@synthesize fileNameText;
@synthesize selectButton;
@synthesize unlinkButton;
@synthesize loadDropboxButton;
@synthesize data;

#pragma mark -
#pragma mark Table view data source

// Customize the number of sections in the table view. Only one is needed here.
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1; // always only one section
}


// Customize the number of rows in the table view. This will equal the size of the data array
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [data count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if (cell == nil) 
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
									   reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell
	NSString* item = [data objectAtIndex:indexPath.row];
	
	cell.textLabel.text = item;
	
	if (editing) // redraw table with editing images
	{
		cell.accessoryType = (int) UITableViewCellEditingStyleInsert;
	}
	else // redraw table in normal mode
	{
		cell.accessoryType = UITableViewCellAccessoryNone;	
	}
	
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
    return cell;
}

	
// Called when the user selects a row.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
		
	NSString* item = [data objectAtIndex:indexPath.row];

	// set text field to the name of the file selected
	//fileNameText.text = item;
	
	fileSelected = [[[currentPath stringByAppendingPathComponent:item] 
					stringByAppendingPathExtension:FILE_EXT_DAT] copy];
	
	
	selectButton.enabled = YES;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void) tableView: (UITableView *)tableView commitEditingStyle:
	     (UITableViewCellEditingStyle) editingStyle forRowAtIndexPath: (NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		// delete the file
		NSString* item = [data objectAtIndex:indexPath.row];
		
		NSString *pathToDelete = [[currentPath stringByAppendingPathComponent:item] 
								  stringByAppendingPathExtension:FILE_EXT_DAT];
	
		// delete data file
		[[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:NULL];

		NSLog (@"File Deleted %@", pathToDelete);
		
		// delete user image file		
		pathToDelete = [[currentPath stringByAppendingPathComponent:item] 
								  stringByAppendingPathExtension:FILE_EXT_PNG];
				
		[[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:NULL];		

		NSLog (@"File Deleted %@", pathToDelete);

		// delete user audio file		
		pathToDelete = [[currentPath stringByAppendingPathComponent:item] 
								  stringByAppendingPathExtension:FILE_EXT_CAF];
	
		[[NSFileManager defaultManager] removeItemAtPath:pathToDelete error:NULL];
		
		NSLog (@"File Deleted %@", pathToDelete);
				
        // delete the element from the data source.
		[data removeObjectAtIndex:indexPath.row];
		
		// delete row from table
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
						 withRowAnimation:UITableViewRowAnimationFade];

		//fileNameText.text = @"";
	}   
 }


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//	return 38.0f;
//}


// Done button clicked in Navigation Bar
- (void)dismissView:(id)sender {
	
	assert (appDelegate.gFilePath == nil);
	
    // call the delegate to dismiss the modal view
    [fileSelectDelegate didDismissFileSelectView];
}

// Enter table editing mode that allows user to delete files. After user selects a file
// to delete, the method commitEditingStyle is called
- (void) deleteFile {
	
	editing = ! editing; // toggle
	
	selectButton.enabled = NO;
	
	[fileTableView setEditing:editing animated:YES];
}


// setCurrentPath overides the setter for currentPath created by the synthesize directive.
- (void) setCurrentPath: (NSString*)path {
	
	[currentPath release];
	
	currentPath = [path copy];
	
	if (path == nil) 
	{
		return;
	}
	
	// set up temporary array to hold list of files in given directory
	NSMutableArray *contents = [[NSMutableArray alloc] init];
	
	NSFileManager *localFileManager=[[NSFileManager alloc] init];
	
	NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtPath:path];
	
	NSString *file;
	
	// iterate through directory looking for files with a certain extension.
	while (file = [dirEnum nextObject])
	{
		if ([[file pathExtension] isEqualToString: FILE_EXT_DAT]) 
		{
			[contents addObject:[file stringByDeletingPathExtension]];
		}
	}
	
	[localFileManager release];
	
	self.title = [currentPath lastPathComponent];

	data = [contents retain];
	
	[fileTableView reloadData];

	[contents release];
}


#pragma mark -
#pragma mark Alert


- (void) alertView: (UIAlertView *) alertView didDismissWithButtonIndex: (NSInteger) buttonIndex {
    
	if ([alertView tag] == 1000) 
	{
        if (buttonIndex == 0) // ok button
		{
			[self getFilesFromDropBox];
        }
		else if (buttonIndex == 1) // cancel button
		{
			// do nothing
		}
    }
}



#pragma mark -
#pragma mark Outlets

- (IBAction) selectFile {
	
	// if not file selected then ignore button tap
	if (fileSelected == nil)
		return;
	
	// save the selected file to the global variable gFilePath
	[appDelegate.gFilePath release];		
	appDelegate.gFilePath = [fileSelected copy];
	
	// call the delegate to dismiss the modal view
    [fileSelectDelegate didDismissFileSelectView];
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

- (IBAction) loadDropbox {
	
	if (![[DBSession sharedSession] isLinked])
	{
		[[[[UIAlertView alloc] 
		   initWithTitle:@"Account Unlinked!" message:@"Press the Link button to connect to Dropbox" 
		   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
		  autorelease] show];				
		
		return;
	}
	
	// if user entered filename with extension then remove it
	NSString *fileName = [[fileNameText.text stringByDeletingPathExtension] copy];
		
	if (fileName == nil)
	{
		NSLog (@"Filename %@: ", fileName); 
		return;
	}
	
	[fileNameText setText: fileName];
	
	NSString *destPath = [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileName]
						  stringByAppendingPathExtension: FILE_EXT_DAT];
	
	// if file exists then warn user of overwrite
	if ([[NSFileManager defaultManager] fileExistsAtPath: destPath])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
														message:@"A file already exists with that name. Do you want to overwrite it?"
													   delegate:self
											  cancelButtonTitle:@"Yes"
											  otherButtonTitles:@"No", nil];
		[alert setTag:1000];
		[alert show];
		[alert release];
	}
	else 
	{
		[self getFilesFromDropBox];
	}
}

- (void) getFilesFromDropBox {
	
	// show network activity indicator		
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	//waitLabel.hidden			= false;
	
	unlinkButton.enabled		= false;
	unlinkButton.alpha			= 0.5f;
	
	selectButton.alpha			= 0.5f;
	
	loadDropboxButton.enabled	= false;
	loadDropboxButton.alpha		= 0.5f;
	
	// set the count of total files to be saved
	saveCount = 3;
	
	NSFileManager *filemgr = [NSFileManager defaultManager];
	
	NSString *userDataPath	= [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileNameText.text]
							   stringByAppendingPathExtension: FILE_EXT_DAT];

	NSString *userAudioPath = [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileNameText.text]
							   stringByAppendingPathExtension: FILE_EXT_CAF];

	NSString *userImagePath = [[appDelegate.gAppDataDir stringByAppendingPathComponent: fileNameText.text]
							   stringByAppendingPathExtension: FILE_EXT_PNG];
	
	// remove existing files if they exist
	[filemgr removeItemAtPath: userDataPath  error:NULL];
	[filemgr removeItemAtPath: userAudioPath error:NULL];
	[filemgr removeItemAtPath: userImagePath error:NULL];	
	
	NSString *dropFileName = [[DROPBOX_FOLDER stringByAppendingPathComponent: fileNameText.text]
							  stringByAppendingPathExtension:FILE_EXT_DAT];
	
	NSLog (@"Loading %@ to %@", dropFileName, userDataPath); 
	
	[self.restClient loadFile: dropFileName intoPath: userDataPath];
	
	
	dropFileName = [[DROPBOX_FOLDER stringByAppendingPathComponent: fileNameText.text]
					stringByAppendingPathExtension:FILE_EXT_CAF];
	
	NSLog (@"Loading %@ to %@", dropFileName, userAudioPath); 
	
	[self.restClient loadFile: dropFileName intoPath: userAudioPath];
	
	
	dropFileName = [[DROPBOX_FOLDER stringByAppendingPathComponent: fileNameText.text]
					stringByAppendingPathExtension:FILE_EXT_PNG];
	
	NSLog (@"Loading %@ to %@", dropFileName, userImagePath); 
	
	[self.restClient loadFile: dropFileName intoPath: userImagePath];
	
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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


/* The delegate provides allows the user to get the result of the calls made on the DBRestClient. */
- (DBRestClient*) restClient {
    
	if (restClient == nil) 
	{
    	restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    	restClient.delegate = self;
		
		NSLog (@"Initializing restClient");
    }
	
    return restClient;
}

// called when a file has been successfully updated from Dropbox
- (void) restClient: (DBRestClient*) client loadedFile: (NSString*) destPath {
	
	NSLog(@"Loaded File Into Path: %@", destPath);
	
	saveCount -= 1;
	
	if (saveCount == 0)
	{
		unlinkButton.enabled		= true;
		unlinkButton.alpha			= 1.0f;
		
		selectButton.alpha			= 1.0f;
		
		loadDropboxButton.enabled	= true;
		loadDropboxButton.alpha		= 1.0f;
		
		// redraw the file list table
		[self setCurrentPath: [currentPath copy]];
	}
}

- (void) restClient: (DBRestClient *) client loadFileFailedWithError: (NSError *) error {
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
													message:@"Could not download your file from Dropbox." 
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	NSLog(@"File load failed: %@", error);
	
	[alert show];
	[alert release];
}


//  A 404 error indicates that path has never existed.
- (void) restClient: (DBRestClient*)aClient loadMetadataFailedWithError: (NSError*) error {
	
	NSLog(@"loadMetadataFailedWithError");
	
	if ([error code] == 404) 
	{
		// path doesn't exist
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"File Exists" 
														message:@"Could not load your file from Dropbox. Select a  different file name." 
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
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
	
	appDelegate.gFilePath = nil;
	
	editing = NO; // init
	
	selectButton.enabled = NO;
	
	UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[buttonCancel setFrame: CGRectMake (0,0,80,30)];
	[buttonCancel setTitle: @"Cancel" forState:UIControlStateNormal];
	[buttonCancel addTarget: self action: @selector(dismissView:) 
		   forControlEvents:UIControlEventTouchUpInside];
	
	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] 
											   initWithCustomView:buttonCancel] autorelease];
	
	UIButton *buttonDelete = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[buttonDelete setFrame: CGRectMake (0,0,80,30)];
	[buttonDelete setTitle: @"Delete" forState:UIControlStateNormal];
	[buttonDelete addTarget:self action:@selector(deleteFile) 
		   forControlEvents:UIControlEventTouchUpInside];
	
	
	self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] 
											  initWithCustomView:buttonDelete] autorelease];
    
	restClient = nil; // init
	
	// create Dropbox session
	[self createSession];
	
	[self updateLinkInfo];
	
	[super viewDidLoad];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
	
	self.fileTableView		= nil;
	self.selectButton		= nil;
	self.unlinkButton		= nil;
	self.loadDropboxButton	= nil;
	self.fileNameText		= nil;
	self.currentPath		= nil;
	self.fileSelected		= nil;
	self.data				= nil;

	[super viewDidUnload];
}

- (void)dealloc {
	
	[fileTableView		release];
	[selectButton		release];
	[unlinkButton		release];
	[loadDropboxButton	release];
	[fileNameText		release];
	[currentPath		release];
	[fileSelected		release];
	[data				release];
	
    [super dealloc];
}



@end

