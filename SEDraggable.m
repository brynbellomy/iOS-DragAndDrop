//
//  SEDraggable.m
//  SEDraggable
//
//  Created by bryn austin bellomy on 10/23/11.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import "SEDraggable.h"
#import "SEDraggableLocation.h"

@interface SEDraggable ()
- (void) handleDrag:(id)sender;
- (void) iconSnapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@implementation SEDraggable

@synthesize shouldSnapBackToHomeFrame = _shouldSnapBackToHomeFrame,
            currentLocation = _currentLocation,
            homeLocation = _homeLocation,
            previousLocation = _previousLocation,
            delegate = _delegate,
            droppableLocations = _droppableLocations,
            panGestureRecognizer = _panGestureRecognizer;
@synthesize firstX,firstY;



#pragma mark- Lifecycle

- (id) init {
  if (self = [self initWithFrame:CGRectNull]) {
  }
  return self;
}

- (id) initWithImage:(UIImage *)image andSize:(CGSize)size {
  UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
  imageView.frame = CGRectMake(0, 0, size.width, size.height);
  
  self = [self initWithImageView:imageView];
  if (self) {
  }
  return self;
}

- (id) initWithImageView:(UIImageView *)imageView {
  self = [self initWithFrame:imageView.frame];
  if (self) {
    imageView.frame = CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height);
    [self addSubview:imageView];
  }
  return self;
}

#pragma mark Designated initializer

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // pan gesture handling
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.shouldSnapBackToHomeFrame = NO;
    
    self.homeLocation = nil;
    self.currentLocation = nil;
    self.previousLocation = nil;
    
    self.droppableLocations = [NSMutableSet set];
  }
  return self;
}

- (void) dealloc {
  _panGestureRecognizer.delegate = nil;
  [self removeGestureRecognizer:_panGestureRecognizer];
}



#pragma mark- Convenience methods

- (void) addAllowedDropLocation:(SEDraggableLocation *)location {
  [self.droppableLocations addObject:location];
}



#pragma mark- Interaction events

- (void) handleDrag:(id)sender {
  CGPoint translatedPoint = [self.panGestureRecognizer translationInView:self.superview];
  CGPoint myCoordinates   = [self.panGestureRecognizer locationInView:self.superview];
  
  [self.superview bringSubviewToFront:self];
  
  // movement has just begun
  if (self.panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    // keep track of where the movement began
    firstX = [self center].x;
    firstY = [self center].y;
  }
  translatedPoint = CGPointMake(firstX + translatedPoint.x, firstY + translatedPoint.y);
  [self setCenter:translatedPoint];
  
  // movement is currently in process
  if (self.panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    [self.delegate draggableObjectDidMove:self];
    
    if (self.droppableLocations.count > 0) {
      for (SEDraggableLocation *location in self.droppableLocations) {
        if ([location pointIsInsideLocation:myCoordinates])
          [self.delegate draggableObject:self didMoveWithinLocation:location];
      }
    }
  }
  
  // movement has just ended
  if (self.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
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
  
  if ([self.delegate respondsToSelector:@selector(draggableObject:didBeginSnapAnimationWithID:andContext:)])
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
  if ([self.delegate respondsToSelector:@selector(draggableObjectWillSnapBackToHomeFrame:)])
    [self.delegate draggableObjectWillSnapBackToHomeFrame:self];
  
  [self.homeLocation snapDraggableIntoBounds:self];
}

- (void) iconSnapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)_context {
  if ([animationID isEqualToString:@"snapBackToHomeFrame"]) {
    self.currentLocation = self.homeLocation;
    
    if ([self.delegate respondsToSelector:@selector(draggableObjectDidEndSnappingBackToHomeFrame:)])
      [self.delegate draggableObjectDidEndSnappingBackToHomeFrame:self];
  }
  else {
    if ([self.delegate respondsToSelector:@selector(draggableObject:didEndSnapAnimationWithID:andContext:)])
      [self.delegate draggableObject:self didEndSnapAnimationWithID:animationID andContext:_context];
  }
}


#pragma mark- NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
  [super encodeWithCoder:encoder];
  [encoder encodeConditionalObject:self.panGestureRecognizer forKey:kPAN_GESTURE_RECOGNIZER_KEY];
  [encoder encodeObject:self.currentLocation forKey:kCURRENT_LOCATION_KEY];
  [encoder encodeObject:self.homeLocation forKey:kHOME_LOCATION_KEY];
  [encoder encodeObject:self.previousLocation forKey:kPREVIOUS_LOCATION_KEY];
  [encoder encodeObject:self.droppableLocations forKey:kDROPPABLE_LOCATIONS_KEY];
  [encoder encodeBool:self.shouldSnapBackToHomeFrame forKey:kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY];
  [encoder encodeFloat:firstX forKey:kFIRST_X_KEY];
  [encoder encodeFloat:firstY forKey:kFIRST_Y_KEY];
}

- (id) initWithCoder:(NSCoder *)decoder {
  if (self = [super initWithCoder:decoder]) {
    self.panGestureRecognizer = [decoder decodeObjectForKey:kPAN_GESTURE_RECOGNIZER_KEY];
    self.currentLocation = [decoder decodeObjectForKey:kCURRENT_LOCATION_KEY];
    self.homeLocation = [decoder decodeObjectForKey:kHOME_LOCATION_KEY];
    self.previousLocation = [decoder decodeObjectForKey:kPREVIOUS_LOCATION_KEY];
    self.droppableLocations = [decoder decodeObjectForKey:kDROPPABLE_LOCATIONS_KEY];
    self.shouldSnapBackToHomeFrame = [decoder decodeBoolForKey:kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY];
    firstX = [decoder decodeFloatForKey:kFIRST_X_KEY];
    firstY = [decoder decodeFloatForKey:kFIRST_Y_KEY];
  }
  return self;
}

@end
