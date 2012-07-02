//
//  ViewController.m
//  SEDraggableDemo
//
//  Created by bryn austin bellomy on 7/2/12.
//  Copyright (c) 2012 robot bubble bath LLC. All rights reserved.
//

#import "ViewController.h"
#import "SEDraggable.h"
#import "SEDraggableLocation.h"

#define OBJECT_WIDTH 50.0f
#define OBJECT_HEIGHT 50.0f
#define MARGIN_VERTICAL 10.0f
#define MARGIN_HORIZONTAL 10.0f
#define DRAGGABLE_LOCATION_WIDTH  ((OBJECT_WIDTH  * 3) + (MARGIN_HORIZONTAL * 5)) 
#define DRAGGABLE_LOCATION_HEIGHT ((OBJECT_HEIGHT * 3) + (MARGIN_VERTICAL   * 5)) 



@interface ViewController ()
  @property (nonatomic, unsafe_unretained, readwrite) SEDraggableLocation *draggableLocationTop;
  @property (nonatomic, unsafe_unretained, readwrite) SEDraggableLocation *draggableLocationBottom;
@end



@implementation ViewController

@synthesize draggableLocationTop = _draggableLocationTop;
@synthesize draggableLocationBottom = _draggableLocationBottom;



- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  [self setupDraggableLocations];
  [self setupDraggableObjects];
}



- (void) setupDraggableLocations {
  // set up the SEDraggableLocations
  CGFloat locationXCoord = CGRectGetMidX(self.view.frame) - (DRAGGABLE_LOCATION_WIDTH / 2.0f);
  SEDraggableLocation *draggableLocationTop = [[SEDraggableLocation alloc] initWithFrame:CGRectMake(locationXCoord, 10.0f, DRAGGABLE_LOCATION_WIDTH, DRAGGABLE_LOCATION_HEIGHT)];
  SEDraggableLocation *draggableLocationBottom = [[SEDraggableLocation alloc] initWithFrame:CGRectMake(locationXCoord, DRAGGABLE_LOCATION_HEIGHT + 30.0f, DRAGGABLE_LOCATION_WIDTH, DRAGGABLE_LOCATION_HEIGHT)];
  
  // you always want your SEDraggableLocations to be transparent -- otherwise, SEDraggable
  // objects will sometimes seem to hide behind certain locations while being dragged
  draggableLocationTop.backgroundColor = [UIColor clearColor];
  draggableLocationBottom.backgroundColor = [UIColor clearColor];
  
  // ... however, we can put clear SEDraggableLocations in front of UIViews
  // that have background images or colors to circumvent this obstacle
  UIView *topWrapper    = [[UIView alloc] initWithFrame: draggableLocationTop.frame];
  UIView *bottomWrapper = [[UIView alloc] initWithFrame: draggableLocationBottom.frame];
  topWrapper.backgroundColor    = [UIColor redColor];
  bottomWrapper.backgroundColor = [UIColor blueColor];
  [self.view addSubview: topWrapper];
  [self.view addSubview: bottomWrapper];
  [self.view addSubview: draggableLocationTop];
  [self.view addSubview: draggableLocationBottom];
  
  
  [self configureDraggableLocation: draggableLocationTop];
  [self configureDraggableLocation: draggableLocationBottom];
  
  self.draggableLocationTop = draggableLocationTop;
  self.draggableLocationBottom = draggableLocationBottom;
}



- (void) configureDraggableLocation:(SEDraggableLocation *)draggableLocation {
  // set the width and height of the objects to be contained in this SEDraggableLocation (for spacing/arrangement purposes) 
  draggableLocation.objectWidth = OBJECT_WIDTH;
  draggableLocation.objectHeight = OBJECT_HEIGHT;
  
  // set the bounding margins for this location
  draggableLocation.marginLeft = MARGIN_HORIZONTAL; 
  draggableLocation.marginRight = MARGIN_HORIZONTAL;
  draggableLocation.marginTop = MARGIN_VERTICAL;
  draggableLocation.marginBottom = MARGIN_VERTICAL;
  
  // set the margins that should be preserved between auto-arranged objects in this location
  draggableLocation.marginBetweenX = MARGIN_HORIZONTAL;
  draggableLocation.marginBetweenY = MARGIN_VERTICAL;
  
  // set up highlight-on-drag-over behavior
  draggableLocation.highlightColor = [UIColor greenColor].CGColor;
  draggableLocation.highlightOpacity = 0.4f;
  draggableLocation.shouldHighlightOnDragOver = YES;
  
  // you may want to toggle this on/off when certain events occur in your app
  draggableLocation.shouldAcceptDroppedObjects = YES;
  
  // set up auto-arranging behavior
  draggableLocation.shouldKeepObjectsArranged = YES;
  draggableLocation.fillHorizontallyFirst = YES; // NO makes it fill rows first
  draggableLocation.allowRows = YES;
  draggableLocation.allowColumns = YES;
  draggableLocation.shouldAnimateObjectAdjustments = YES; // if this is set to NO, objects will simply appear instantaneously at their new positions
  draggableLocation.animationDuration = 0.5f;
  draggableLocation.animationDelay = 0.0f;
  draggableLocation.animationOptions = UIViewAnimationOptionLayoutSubviews ; // UIViewAnimationOptionBeginFromCurrentState;
  
  draggableLocation.shouldAcceptObjectsSnappingBack = YES;
}



- (void) setupDraggableObjects {
  // set up the SEDraggables
  NSArray *pngs = [NSArray arrayWithObjects:@"crocodile", @"red-applo", @"bryn-applo", @"cat", @"dog", @"monkey", @"sheep", @"robo-fox", @"blue-applo", nil];
  
  for (NSString *png in pngs) {
    UIImage *draggableImage = UIImageWithBundlePNG(png);
    UIImageView *draggableImageView = [[UIImageView alloc] initWithImage: draggableImage];
    SEDraggable *draggable = [[SEDraggable alloc] initWithImageView: draggableImageView];
    [self configureDraggableObject: draggable];
  }
}



- (void) configureDraggableObject:(SEDraggable *)draggable {
  draggable.homeLocation = self.draggableLocationTop;
  [draggable addAllowedDropLocation: self.draggableLocationTop];
  [draggable addAllowedDropLocation: self.draggableLocationBottom];
  [self.draggableLocationTop addDraggableObject:draggable animated:NO];
}



- (void)viewDidUnload {
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
  } else {
    return YES;
  }
}

@end
