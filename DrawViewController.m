//
//  DrawViewController.m
//  Creativity
//
//  Created by Dan Rencricca on 6/5/11.
//  Copyright 2011 self. All rights reserved.
//

#import "DrawViewController.h"

@implementation DrawViewController


@synthesize brushSmButton;
@synthesize brushMdButton;
@synthesize brushLgButton;
@synthesize eraserButton;
@synthesize userImgView;
@synthesize colorSelectedImg;
@synthesize colorbarImg;
@synthesize switchViewDelegate;

#pragma mark -
#pragma mark Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
	
    lastPoint = [touch locationInView:self.view];
    lastPoint.y -= 35;
	lastPoint.x -= 15;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];   
    CGPoint currentPoint = [touch locationInView:self.view];
    currentPoint.y -= 35;
    currentPoint.x -= 15;
	
    
    UIGraphicsBeginImageContext (userImgView.frame.size);
	
	[userImgView.image drawInRect:CGRectMake (0, 0, userImgView.frame.size.width, userImgView.frame.size.height)];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSetLineCap (context, kCGLineCapRound);
    
	CGContextSetLineWidth (context, brushWidth);
    
	CGContextSetStrokeColorWithColor (context, drawColor);
	
	CGContextBeginPath (context);
    
	CGContextMoveToPoint (context, lastPoint.x, lastPoint.y);
    
	CGContextAddLineToPoint (context, currentPoint.x, currentPoint.y);
    
	CGContextStrokePath (context);
    
	userImgView.image = UIGraphicsGetImageFromCurrentImageContext();
    
	UIGraphicsEndImageContext();
	
    lastPoint = currentPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
	UITouch *touch = [touches anyObject];
    
	CGPoint touchLocation = [touch locationInView:self.view];
	
	// check if the finger touch point is withing the user image 
	if (CGRectContainsPoint (colorbarImg.frame, touchLocation))
	{		
		float locX = [[touches anyObject] locationInView:colorbarImg].x;
		float locY = [[touches anyObject] locationInView:colorbarImg].y;
		
		CGPoint touchPoint = CGPointMake (locX,locY);
		
		[self setBrushColor: touchPoint];
		
		usingEraser = false; // reset in case use had been erasing
	}
}


#pragma mark -
#pragma mark Outlets

// Responds to user selecting the small brush button.
-(IBAction) setBrushSm {
	brushMdButton.selected = NO;
	brushLgButton.selected = NO;
	brushSmButton.selected = YES;
	brushWidth = BRUSH_SMALL;
}

// Responds to user selecting the medium brush button.
-(IBAction) setBrushMd {
	brushSmButton.selected = NO;
	brushLgButton.selected = NO;
	brushMdButton.selected = YES;
	brushWidth = BRUSH_MEDIUM;
}

// Responds to user selecting the large brush button.
-(IBAction) setBrushLg {
	brushSmButton.selected = NO;
	brushMdButton.selected = NO;
	brushLgButton.selected = YES;
	brushWidth = BRUSH_LARGE;
}


// Responds to user selecting the eraser button
-(IBAction) useEraser {
	
	if (!usingEraser)
	{
		priorDrawColor = drawColor;
		//priorBrushWidth = brushWidth;
		
		// set draw color to white to erase
		drawColor = [UIColor whiteColor].CGColor;

		// set eraser button to selected
		eraserButton.selected = YES;

		//[eraserButton setImage:[UIImage imageNamed:@"eraser-selected.png"] forState:UIControlStateNormal];
		//brushWidth = 12.0;
	}
	else 
	{
		// set draw color back to original color
		drawColor = priorDrawColor;
		
		// set eraseor button back to normal state
		eraserButton.selected = NO;
		//[eraserButton setImage:[UIImage imageNamed:@"eraser-normal.png"] forState:UIControlStateNormal];
		//brushWidth = priorBrushWidth;	
	}
	
	usingEraser = !usingEraser;
}


- (IBAction) goNext {
	
	// note: gUserImg and gAnimImg set in processImage
	
	[switchViewDelegate goAnimateView];
}


- (IBAction) goBack {
		
	// release memory in case user goes back, returns and goes back again
	if (appDelegate.gUserImg != nil)
	{
		[appDelegate.gUserImg release];
		appDelegate.gUserImg = nil;
	}
	
	appDelegate.gUserImg = [[UIImage alloc] initWithCGImage: [userImgView.image CGImage]];
	
	[switchViewDelegate goExampleView];
}


- (IBAction) startOver {
	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
													message:@"If you start over you will lose your drawing. Do you wish to continue?"
												   delegate:self
										  cancelButtonTitle:@"Yes"
										  otherButtonTitles:@"No", nil];
	[alert setTag:1000];
	[alert show];
	[alert release];
}


- (IBAction) eraseImage {	
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NULL
													message:@"Are you sure you want to erase your drawing?"
												   delegate:self
										  cancelButtonTitle:@"Yes"
										  otherButtonTitles:@"No", nil];
	[alert setTag:2000];
	[alert show];
	[alert release];
}


#pragma mark -
#pragma mark Misc


- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
	if ([alertView tag] == 1000) // start over
	{
        if (buttonIndex == 0) 
		{
			[switchViewDelegate startOver];
        }
		else if (buttonIndex == 1)
		{
			// do nothing
		}
    }
	else if ([alertView tag] == 2000) // erase canvas
	{
        if (buttonIndex == 0) 
		{
			[self createCanvas];
        }
		else if (buttonIndex == 1)
		{
			// do nothing
		}
		
    }
}


- (void) setBrushColor: (CGPoint)point {

	// if user was using eraser then turn it off
	if (usingEraser)
	{
        drawColor = priorDrawColor;
		eraserButton.selected = NO;
		usingEraser = FALSE;
	}
	
	// create a reference to the color bar image.
	CGImageRef inImage = colorbarImg.image.CGImage;

	// Create off screen bitmap context to draw the image into. Format ARGB is 4
	// bytes for each pixel: Alpa, Red, Green, Blue.
	CGContextRef cgctx = [self createARGBBitmapContext:inImage];
	
	if (cgctx == NULL)
    {
        NSLog (@"Error in setBrushColor: could not create cgctx");
        return;
	}
    
	size_t w = CGImageGetWidth(inImage);
	size_t h = CGImageGetHeight(inImage);
	CGRect rect = {{0,0},{w,h}}; 
	
	// Draw the image to the bitmap context. Once we draw, the memory
	// allocated for the context for rendering will then contain the
	// raw image data in the specified color space.
	CGContextDrawImage (cgctx, rect, inImage); 
	
	// get a pointer to the image data associated with the bitmap context.
	unsigned char* data = CGBitmapContextGetData (cgctx);
	
	//NSLog(@"point x y: %f %f", point.x, point.y);
	
	if (data != NULL)
	{
		// if there is already a drawColor then release it (or else you will get an error!)
		CGColorRelease (drawColor);
		
		// Offset locates the pixel in the data at point x, y.
		int offset = 4*((w*point.y)+point.x); // 4 bytes of data per pixel
		float red	= data[offset];
		float green = data[offset+1];
		float blue	= data[offset+2];
		//NSLog(@"offset: %i colors: RGB %f %f %f",offset,red,green,blue);
		
		// create a new colorspace
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		
		CGFloat components[] = {red/255.0f, green/255.0f, blue/255.0f, 1.0f };
		
		// create the new color based on color at touch location
		drawColor =  CGColorCreate (colorSpace, components);
		
		// convert drawColor to a UIColor
		UIColor *drawColorUI = [[UIColor alloc] initWithCGColor: drawColor];
		
		// set color
		self.colorSelectedImg.backgroundColor = drawColorUI;
		
		[drawColorUI release];
		
		// release colorspace
		CGColorSpaceRelease (colorSpace);
	}
	
	// release the context
	CGContextRelease(cgctx);
	
	// free image data memory for the context
	if (data != NULL)
		free(data);
	
	return;
}


- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef) inImage :(int) borderW {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image plus a border at all sides.
	size_t pixelsWide = CGImageGetWidth(inImage)  + borderW*2;
	size_t pixelsHigh = CGImageGetHeight(inImage) + borderW*2;
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedFirst
									 );
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// release colorspace before returning
	CGColorSpaceRelease (colorSpace);
	
	return context;
}

- (CGContextRef) createARGBBitmapContext:(CGImageRef) inImage {
	
	CGContextRef    context = NULL;
	CGColorSpaceRef colorSpace;
	void *          bitmapData;
	//NSMutableData*   bitmapData;
	int             bitmapByteCount;
	int             bitmapBytesPerRow;
	
	// Get image width, height. We'll use the entire image.
	size_t pixelsWide = CGImageGetWidth(inImage);
	size_t pixelsHigh = CGImageGetHeight(inImage);
	
	// Declare the number of bytes per row. Each pixel in the bitmap in this
	// example is represented by 4 bytes; 8 bits each of red, green, blue, and
	// alpha.
	bitmapBytesPerRow   = (pixelsWide * 4);
	bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
	
	// Use the generic RGB color space.
	colorSpace = CGColorSpaceCreateDeviceRGB();
	
	if (colorSpace == NULL)
	{
		fprintf(stderr, "Error allocating color space\n");
		return NULL;
	}
	
	// Allocate memory for image data. This is the destination in memory
	// where any drawing to the bitmap context will be rendered.
	bitmapData = malloc( bitmapByteCount );
	
	//bitmapData = [[NSMutableData alloc] initWithLength:bitmapByteCount];
	
	if (bitmapData == NULL)
	{
		fprintf (stderr, "Memory not allocated!");
		CGColorSpaceRelease( colorSpace );
		return NULL;
	}
	
	// Create the bitmap context. We want pre-multiplied ARGB, 8-bits
	// per component. Regardless of what the source image format is
	// (CMYK, Grayscale, and so on) it will be converted over to the format
	// specified here by CGBitmapContextCreate.
	context = CGBitmapContextCreate (bitmapData,
									 pixelsWide,
									 pixelsHigh,
									 8,      // bits per component
									 bitmapBytesPerRow,
									 colorSpace,
									 kCGImageAlphaPremultipliedLast
									 );
	if (context == NULL)
	{
		free (bitmapData);
		fprintf (stderr, "Context not created!");
	}
	
	// release colorspace
	CGColorSpaceRelease (colorSpace);
	
	//[bitmapData release];
	
	return context;
}



// Calculates whether the point at x,y intersects with the edge of a drawn image. It
// assumes the image is drawn on a white background. 
-(bool) contact:(unsigned char*) pixelArray: (int) x: (int) y: (int) w: (int) h 
{
	bool contactMade = false;
	
	int  centerX = round(PIC_BORDER/2);
	int  centerY = round(PIC_BORDER/2);
	
	int  startX = 0; // starting x position in pixelArray
	int  startY = 0; // starting y position in pixelArray
	int  endX   = w; // ending x position in pixelArray
	int  endY   = h; // ending y position in pixelArray
	
	if (x > centerX)
		startX = x - centerX;
	
	if (y > centerY)
		startY = y - centerY;
	
	if ((w - x) > centerX)
		endX = x + centerX;
	
	if ((h - y) > centerY)
		endY = y + centerY;
	
	int offset;
	int red;
	int green;
	int blue;
	
	// check array to see if any non-white pixels
	for (int x = startX; x < endX; x++)
	{
		for (int y = startY; y < endY; y++)
		{						
			offset = 4*((w*y)+x);
			
			red    = pixelArray[offset+1];
			green  = pixelArray[offset+2];
			blue   = pixelArray[offset+3];
			
			if (!(red == 255 && green == 255 && blue == 255)) 
			{	
				contactMade = true;
				break;
			}
		}
		if (contactMade) break;
	}
	return contactMade;	 
}


- (bool) convertImg {
	
	//NSLog(@"1 w: %i / h: %i", CGImageGetWidth(userImgView.image.CGImage), CGImageGetHeight(userImgView.image.CGImage));
	
	// Expand the drawn image by adding border to all four sizes //
	
	// create off screen bitmap context to draw the image with room for border
	CGContextRef expandedImgCtx = [self createARGBBitmapContextFromImage: userImgView.image.CGImage: PIC_BORDER];
	
	size_t w = CGImageGetWidth(userImgView.image.CGImage);
	size_t h = CGImageGetHeight(userImgView.image.CGImage);
	CGRect locationRect = {{PIC_BORDER, PIC_BORDER},{w, h}}; 
	
	// set current fill color in a graphics context
	CGContextSetFillColorWithColor (expandedImgCtx, [UIColor whiteColor].CGColor);
	
	// paint area contained within rectangle using fill color in current graphics context
	CGContextFillRect(expandedImgCtx, CGRectMake(0, 0, w+PIC_BORDER*2, h+PIC_BORDER*2));
    
	// draw image into current context at position defined by rectangle
	CGContextDrawImage (expandedImgCtx, locationRect, userImgView.image.CGImage);
	
	CGImageRef drawImgRef = CGBitmapContextCreateImage (expandedImgCtx);
	
	CGContextRelease (expandedImgCtx); // clean up
	
	//NSLog(@"2 w: %i / h: %i", CGImageGetWidth(drawImgRef), CGImageGetHeight(drawImgRef));
	
	// create off screen bitmap context to draw the image into.
	// the format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
	CGContextRef drawImgCtx = [self createARGBBitmapContextFromImage: drawImgRef: 0];
	
	if (drawImgCtx == NULL)
	{
		NSLog(@"Error creating context: cgctx");
		return false; // error
	}
	
    // get size of new image (with border)
	w = CGImageGetWidth (drawImgRef);
	h = CGImageGetHeight (drawImgRef);
	
	locationRect = CGRectMake (0,0,w,h);
	
	// draw drawImgRef image to bitmap context at location in locationRect
	CGContextDrawImage (drawImgCtx, locationRect, drawImgRef); 
	
	CGImageRelease (drawImgRef);
	
	// get a pointer to the image data associated with the bitmap context
	unsigned char* drawImgData = CGBitmapContextGetData (drawImgCtx);
	
	// check for error
	if (!drawImgData)
	{
		NSLog (@"Data is NULL!");
		return false; // error
	}
	
	// Get the bounds of the drawn image
	int		offset;
	int		alpha;
	int		red;
	int		green;
	int		blue;
	int		x,y;
	int		vMaxX = 0;
	int		vMinX = w;
	int		vMaxY = 0;
	int		vMinY = h;
	
	for (int x=0; x<w; x++) 
	{
		for (int y=0; y<h; y++) 
		{				
			// get offset of the pixel in the data at point x, y
			offset = 4*((w*y)+x); // 4 bytes of data per pixel
			red    = drawImgData[offset+1];
			green  = drawImgData[offset+2];
			blue   = drawImgData[offset+3];
			
			if (red < 255 || green < 255 || blue < 255) 
			{
				if (x > vMaxX)
					vMaxX = x;
				
				if (x < vMinX)
					vMinX = x;
				
				if (y > vMaxY)
					vMaxY = y;
				
				if (y < vMinY) 
					vMinY = y;
			}
		}
	}
	
	// make sure user has drawn something on the canvas
	if (vMaxX==0 && vMaxY==0 && vMinX==w && vMinY==h)
		return false;
	
	vMaxX += PIC_BORDER;
	vMinX -= PIC_BORDER;
	vMaxY += PIC_BORDER;
	vMinY -= PIC_BORDER;		
	
	//NSLog(@"MinX: %i, MinY: %i, MaxX: %i, MaxY: %i", vMinX, vMinY, vMaxX, vMaxY);
	
	
	// Copy pixels from drawn image to a new image file. Only copy pictures that have been
	// drawn by user plus white pixles inside the image. 
	
	// allocate memory for raw image data that will hold the cut-out image
	int numBytes = 4 * w * h;	
    unsigned char* newImgData = (unsigned char*) malloc (numBytes * sizeof(unsigned char));
	
	// check for error
	if (!newImgData)
	{
		NSLog(@"Error: could not allocate newImgData");
		return false; // error
	}
	
	//NSLog(@"newImgData Size: %i", numBytes * sizeof(unsigned char));
	
	// check each pixels to see if it has been painted. First eliminate white
	// pixels from left to right.
	y = vMinY;
	
	while (y < vMaxY-1)
	{
		x=vMinX;
		
		while (x < vMaxX)
		{							
			if ([self contact:drawImgData:x:y:w:h])
			{
				// continue to copy pixel data until we copy entire width of picture. This is so 
				// we get backround of picture.
				while (x < vMaxX)
				{
					offset = 4*((w*y)+x);
					alpha  = drawImgData[offset];
					red    = drawImgData[offset+1];
					green  = drawImgData[offset+2];
					blue   = drawImgData[offset+3];
					
					newImgData[offset]   = red;
					newImgData[offset+1] = green;
					newImgData[offset+2] = blue;
					newImgData[offset+3] = alpha;
					
					x++;
					
				}
				break;
			}
			else // fill with black pixels with 0 alpha
			{
				newImgData[offset]   =  0.0;
				newImgData[offset+1] =  0.0;
				newImgData[offset+2] =  0.0;
				newImgData[offset+3] =  0.0;
				x++;
			}			
		}
		y++;
	}
	
	// eliminate white pixels from top down
	y=vMinY;
	
	while (y<vMaxY) 
	{
		x=vMaxX;
		
		while (x >= vMinX)
		{			
			if ([self contact:drawImgData:x:y:w:h])
				break;
			
			// fill with black pixels with 0 alpha
			offset = 4*((w*y)+x); // 4 bytes of data per pixel
			newImgData[offset]   =  0.0;
			newImgData[offset+1] =  0.0;
			newImgData[offset+2] =  0.0;
			newImgData[offset+3] =  0.0;
			
			x--;
		}
		y++;
	}
	
	// eliminate white pixels from left to right
	x=vMinX;
	
	while (x < vMaxX) 
	{
		y=vMinY;
		
		while (y < vMaxY)
		{			
			if ([self contact:drawImgData:x:y:w:h])
				break;
			
			// fill with black pixels with 0 alpha
			offset = 4*((w*y)+x);
			newImgData[offset]   =  0.0;
			newImgData[offset+1] =  0.0;
			newImgData[offset+2] =  0.0;
			newImgData[offset+3] =  0.0;
			
			y++;
		}
		x++;
	}
	
	// eliminate white pixels from bottom up
	x=vMinX;
	
	while (x < vMaxX) 
	{
		y=vMaxY;
		
		while (y >= vMinY)
		{			
			if ([self contact:drawImgData:x:y:w:h])
				break;
			
			// fill with black pixels with 0 alpha
			offset = 4*((w*y)+x);
			newImgData[offset]   =  0.0;
			newImgData[offset+1] =  0.0;
			newImgData[offset+2] =  0.0;
			newImgData[offset+3] =  0.0;
			
			y--;
		}
		x++;
	}
	
	// release the drawImgCtx
	CGContextRelease (drawImgCtx);
	
	// free image data memory
	if (drawImgData) 
		free (drawImgData);
	
	// create image reference from the newImgData
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	CGDataProviderRef provider   = CGDataProviderCreateWithData (NULL, newImgData, numBytes, NULL);
	
    CGImageRef newImageRef = CGImageCreate (
											w,
											h,
											8,
											8*4,
											4*w,
											colorspace,
											kCGBitmapByteOrderDefault | kCGImageAlphaLast,
											provider,
											NULL,
											false,
											kCGRenderingIntentDefault
											);
	
	// clear and release the drawn image
//	userImgView.image = nil;	
//	[userImgView removeFromSuperview]; // remove the userImgView from the view
//	[userImgView release];
	
	// if image is too large, reduce its size
	int newSizeX = vMaxX-vMinX;
	int newSizeY = vMaxY-vMinY;
	
	if (newSizeX > PIC_MAX_SZ)
	{
		newSizeX = PIC_MAX_SZ;
		float ratio = (float) PIC_MAX_SZ/(vMaxX-vMinX);
		newSizeY = round (ratio * (vMaxY-vMinY));
	}	
	
	if (newSizeY > PIC_MAX_SZ)
	{
		newSizeY = PIC_MAX_SZ;
		float ratio = (float) PIC_MAX_SZ/(vMaxY-vMinY);
		newSizeX = round (ratio * (vMaxX-vMinX));
	}
	
	// get frame of drawn image
	CGRect cropRect = CGRectMake(vMinX,vMinY,vMaxX-vMinX,vMaxY-vMinY);
	
	// copy cropped image from newImageRef
	CGImageRef croppedImgRef = CGImageCreateWithImageInRect (newImageRef, cropRect);

	// DO NOT free newImageData nor release newImageRef here lest you will cause an
	// error on the iPad device that does not occur in the simulator.

	// clean up
	CGColorSpaceRelease (colorspace);
    CGDataProviderRelease (provider);
	
	// reduce size of image to targetSize
	CGSize targetSize = CGSizeMake (newSizeX, newSizeY);
	
	assert (targetSize.width > 0 && targetSize.height > 0);
	
	NSLog(@"targetSizeW: %f, targetSizeH: %f", targetSize.width, targetSize.height);
	
	UIImage *theImage = [UIImage imageWithCGImage:croppedImgRef];
	

	// draw cropped image into new context
	UIGraphicsBeginImageContext (targetSize); // this will crop

	[theImage drawInRect:CGRectMake (0,0,targetSize.width,targetSize.height)];
	
	CGImageRelease (croppedImgRef);

	UIImage *croppedImg = UIGraphicsGetImageFromCurrentImageContext();
	
	// pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	theImage = nil;
	
	// we do not need to release croppedImg
	
	//NSLog(@"newSizeX: %d, newSizeY: %d", newSizeX, newSizeY);
	
	NSLog(@"convertImg: About to release gAnimImg....");
	
	// set pointer to global gDrawImgView so that animation viewer can use it
	if (appDelegate.gAnimImg != nil)  // REMOVE IF MEMORY PROBLEM
	{
        [appDelegate.gAnimImg release];
		appDelegate.gAnimImg = nil;
	}
	NSLog(@"convertImg: About to release gUserImg....");
	
	if (appDelegate.gUserImg != nil) // ERASE IF MEMORY PROBLEM2
	{
		[appDelegate.gUserImg release];
		appDelegate.gUserImg = nil;
	}

	NSLog(@"convertImg: Successfully released images....");
	
	appDelegate.gAnimImg = [[UIImage alloc] initWithCGImage: [croppedImg CGImage]];

	appDelegate.gUserImg = [[UIImage alloc] initWithCGImage: [userImgView.image CGImage]];
		
	// clean up here, but do not do this above
	free (newImgData);
	CGImageRelease (newImageRef);
	
	return true;
}


- (void) createCanvas {
	
	NSLog(@"In createCanvas");
	
	// -- Create a white canvas on which user will drawn --
	
	// create image contect for the userImgView
	UIGraphicsBeginImageContext (userImgView.frame.size);
	
	[[UIColor whiteColor] set]; // set context color to white
	
	CGContextFillRect (UIGraphicsGetCurrentContext(), CGRectMake(0, 0, userImgView.frame.size.width,
		userImgView.frame.size.height));

	userImgView.image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
}

- (void) redrawImage {
	
	NSLog(@"In redrawImage");
	
	assert (appDelegate.gUserImg != nil);
	
	[userImgView setImage: appDelegate.gUserImg];
}

#pragma mark -
#pragma mark View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
 
	appDelegate = [[UIApplication sharedApplication] delegate];

	if (!appDelegate.gUserImg)
		[self createCanvas];
	else {
		[self redrawImage]; // if user already did drawing and returning to view
	}
	
	// set the initial draw color
	
	// convert drawColor to a UIColor
	CGFloat components[] = {52/255.0f, 88/255.0f, 169/255.0f, 1.0f };
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	drawColor =  CGColorCreate (colorSpace, components);
	
	UIColor *drawColorUI = [[UIColor alloc] initWithCGColor: drawColor];
	
	self.colorSelectedImg.backgroundColor = drawColorUI;
	
	[drawColorUI release];
	
	// release colorspace
	CGColorSpaceRelease (colorSpace);	
	
	// set default brush width
	brushMdButton.selected = YES;
	brushWidth = BRUSH_MEDIUM;
	
	usingEraser = false; // init
	
	[super viewDidLoad];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

	self.brushSmButton		= nil;
	self.brushMdButton		= nil;
	self.brushLgButton		= nil;
	self.eraserButton		= nil;
	self.userImgView		= nil;
	self.colorSelectedImg	= nil;
	self.colorbarImg		= nil;
	self.switchViewDelegate = nil;

	[super viewDidUnload];
}

- (void)dealloc {
		
	[brushSmButton		release];
	[brushMdButton		release];
	[brushLgButton		release];
	[userImgView		release];
	[eraserButton		release];
	[colorbarImg		release];
	[colorSelectedImg	release];

	if (usingEraser)
	{
        drawColor = priorDrawColor;
	}    
	CGColorRelease (drawColor);

    [super dealloc];
}

@end
/////////////////////////////