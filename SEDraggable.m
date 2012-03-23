//
//  SEDraggable.m
//  SEDraggable
//
//  Created by bryn austin bellomy on 10/23/11.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import "SEDraggable.h"
#import "SEDraggableLocation.h"

@implementation SEDraggable

@synthesize isHidden = _isHidden,
            shouldSnapBackToHomeFrame = _shouldSnapBackToHomeFrame,
            currentLocation = _currentLocation,
            homeLocation = _homeLocation,
            previousLocation = _previousLocation,
            delegate = _delegate,
            droppableLocations = _droppableLocations,
            imageView = _imageView,
            panGestureRecognizer = _panGestureRecognizer;
@synthesize firstX,firstY;

- (id) init {
  if (self = [self initWithImageView:nil andHomeLocation:nil]) {
  }
  return self;
}

- (id) initWithImage:(UIImage *)image andSize:(CGSize)size andHomeLocation:(SEDraggableLocation *)location {
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.frame = CGRectMake(0, 0, size.width, size.height);
  
  if (self = [self initWithImageView:imageView andHomeLocation:location]) {
    /*CGRect frame = CGRect(imageView.frame);
    CGPoint loc = [self.homeLocation getAcceptableLocationForDraggableObject:self];
    frame = CGRectOffset(frame, loc.x - (size.width / 2), loc.y - (size.height / 2));
    self.holderView = [[UIView alloc] initWithFrame:frame];
    [self.holderView addGestureRecognizer:_panGestureRecognizer];
    [self.holderView addSubview:imageView];*/
  }
  return self;
}

- (id) initWithImageView:(UIImageView *)imageView andHomeLocation:(SEDraggableLocation *)location {
  if (imageView != nil) {
    self = [super initWithFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, imageView.frame.size.height)];
  }
  else {
    self = [super init];
  }
  
  if (self) {
    self.imageView = imageView;
  
    // pan gesture handling
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [_panGestureRecognizer setMinimumNumberOfTouches:1];
    [_panGestureRecognizer setMaximumNumberOfTouches:1];
    [_panGestureRecognizer setDelegate:self];
    [self addGestureRecognizer:_panGestureRecognizer];
    
    self.shouldSnapBackToHomeFrame = NO;
    self.isHidden = NO;
    
    self.homeLocation = location;
    self.currentLocation = location;
    self.previousLocation = location;
    
    //CGPoint loc = [self.homeLocation getAcceptableLocationForDraggableObject:self];
    //self.frame = CGRectOffset(imageView.frame, loc.x - (imageView.frame.size.width / 2), loc.y - (imageView.frame.size.height / 2));
    //self.holderView = [[UIView alloc] initWithFrame:frame];
    
    if (imageView != nil) {
      self.frame = imageView.frame;
      [self addSubview:imageView];
      imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    }
    
    //self.backgroundColor = [UIColor redColor];
  }
  
  return self;
}

- (void) dealloc {
  [self.imageView removeFromSuperview];
  [self removeFromSuperview];
  [self removeGestureRecognizer:_panGestureRecognizer];
}

- (void) handleDrag:(id)sender {
  CGPoint translatedPoint = [_panGestureRecognizer translationInView:self.superview];
  CGPoint myCoordinates   = [_panGestureRecognizer locationInView:self.superview];
  
  [self.superview bringSubviewToFront:self];
  
  // movement has just begun
  if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    // keep track of where the movement began
    firstX = [self center].x;
    firstY = [self center].y;
  }
  translatedPoint = CGPointMake(firstX + translatedPoint.x, firstY + translatedPoint.y);
  [self setCenter:translatedPoint];
  
  // movement is currently in process
  if (_panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    [self.delegate draggableObjectDidMove:self];
    
    if (self.droppableLocations.count > 0) {
      for (SEDraggableLocation *location in self.droppableLocations) {
        if ([location pointIsInsideLocation:myCoordinates])
          [self.delegate draggableObject:self didMoveWithinLocation:location];
      }
    }
  }
  
  // movement has just ended
  if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    BOOL didStopMovingWithinLocation = NO;
    SEDraggableLocation *dropLocation = nil;
    
    for (SEDraggableLocation *location in self.droppableLocations) {
      if ([location pointIsInsideLocation:myCoordinates]) {
        didStopMovingWithinLocation = YES;
        dropLocation = location;
        break;
      }
    }
    
    self.previousLocation = self.currentLocation; // retain self.currentLocation
    [self.currentLocation removeDraggableObject:self]; // release self.currentLocation
    
    if (didStopMovingWithinLocation) {
      [self.delegate draggableObjectDidStopMoving:self];
      [dropLocation draggableObjectWasDroppedInside:self];
      [self.delegate draggableObject:self didStopMovingWithinLocation:dropLocation];
    }
    else {
      if (self.shouldSnapBackToHomeFrame)
        [self snapBackToHomeFrame];
    }
    
  }
}

- (void) draggableLocationDidRefuseDrop:(SEDraggableLocation *)location {
  if (self.shouldSnapBackToHomeFrame)
    [self snapBackToHomeFrame];
}

- (void) snapCenterToPoint:(CGPoint)point withAnimationID:(NSString *)animationID andContext:(void *)context {
  if (animationID == nil)
    animationID = @"iconSnap";
  
  /*** begin animation block ***/
  [UIView beginAnimations:animationID context:context];
  
  [self.delegate draggableObject:self didBeginSnapAnimationWithID:animationID andContext:context];
  
  // set icon animation delegate
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(iconSnapAnimationDidStop:finished:context:)];
  [UIView setAnimationDuration:0.35f];
  [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
  [self setCenter:point];
  [UIView commitAnimations];
  /*** end animation block ***/
}

- (void) snapBackToHomeFrame {
  [self.delegate draggableObjectWillSnapBackToHomeFrame:self];
  CGPoint point = [self.homeLocation getAcceptableLocationForDraggableObject:self];
  //point.x = self.homeLocation.bounds.origin.x + (((UIImageView *)[self.holderView.subviews objectAtIndex:0]).image.size.width / 2);
  //point.y = self.homeLocation.bounds.origin.y + (((UIImageView *)[self.holderView.subviews objectAtIndex:0]).image.size.height / 2);
  [self snapCenterToPoint:point withAnimationID:@"snapBackToHomeFrame" andContext:NULL]; //self];
}

- (void) iconSnapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)_context {
  NSLog(@"iconSnapAnimationDidStop (%@) START", animationID);
  if ([animationID isEqualToString:@"snapBackToHomeFrame"]) {
    self.currentLocation = self.homeLocation;
    [self.delegate draggableObjectDidEndSnappingBackToHomeFrame:self];
  }
  else {
    [self.delegate draggableObject:self didEndSnapAnimationWithID:animationID andContext:_context];
  }
  NSLog(@"iconSnapAnimationDidStop (%@) END", animationID);
}


#pragma mark- NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
  [super encodeWithCoder:encoder];
  [encoder encodeConditionalObject:self.panGestureRecognizer forKey:kPAN_GESTURE_RECOGNIZER_KEY];
  [encoder encodeObject:self.imageView forKey:kIMAGE_VIEW_KEY];
  [encoder encodeObject:self.currentLocation forKey:kCURRENT_LOCATION_KEY];
  [encoder encodeObject:self.homeLocation forKey:kHOME_LOCATION_KEY];
  [encoder encodeObject:self.previousLocation forKey:kPREVIOUS_LOCATION_KEY];
  [encoder encodeObject:self.droppableLocations forKey:kDROPPABLE_LOCATIONS_KEY];
  [encoder encodeBool:self.isHidden forKey:kIS_HIDDEN_KEY];
  [encoder encodeBool:self.shouldSnapBackToHomeFrame forKey:kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY];
  [encoder encodeFloat:firstX forKey:kFIRST_X_KEY];
  [encoder encodeFloat:firstY forKey:kFIRST_Y_KEY];
}

- (id) initWithCoder:(NSCoder *)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.panGestureRecognizer = [decoder decodeObjectForKey:kPAN_GESTURE_RECOGNIZER_KEY];
    self.imageView = [decoder decodeObjectForKey:kIMAGE_VIEW_KEY];
    self.currentLocation = [decoder decodeObjectForKey:kCURRENT_LOCATION_KEY];
    self.homeLocation = [decoder decodeObjectForKey:kHOME_LOCATION_KEY];
    self.previousLocation = [decoder decodeObjectForKey:kPREVIOUS_LOCATION_KEY];
    self.droppableLocations = [decoder decodeObjectForKey:kDROPPABLE_LOCATIONS_KEY];
    self.isHidden = [decoder decodeBoolForKey:kIS_HIDDEN_KEY];
    self.shouldSnapBackToHomeFrame = [decoder decodeBoolForKey:kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY];
    firstX = [decoder decodeFloatForKey:kFIRST_X_KEY];
    firstY = [decoder decodeFloatForKey:kFIRST_Y_KEY];
  }
  return self;
}

@end
