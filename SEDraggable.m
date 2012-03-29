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
- (void) askToEnterLocation:(SEDraggableLocation *)location entryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;
@end

@implementation SEDraggable

@synthesize shouldSnapBackToHomeLocation = _shouldSnapBackToHomeLocation,
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

#pragma mark -- Designated initializer

- (id) initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    // pan gesture handling
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    self.panGestureRecognizer.minimumNumberOfTouches = 1;
    self.panGestureRecognizer.maximumNumberOfTouches = 1;
    self.panGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.panGestureRecognizer];
    
    self.shouldSnapBackToHomeLocation = NO;
    
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



#pragma mark- UI events

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
    if ([self.delegate respondsToSelector:@selector(draggableObjectDidMove:)])
      [self.delegate draggableObjectDidMove:self];
    
    if (self.droppableLocations.count > 0) {
      for (SEDraggableLocation *location in self.droppableLocations) {
      
        CGPoint myLocalCoordinates = [self.superview convertPoint:myCoordinates toView:location];
        if ([location pointIsInsideResponsiveBounds:myLocalCoordinates]) {
          if ([self.delegate respondsToSelector:@selector(draggableObject:didMoveWithinLocation:)]) {
            [location draggableObjectDidMoveWithinBounds:self];
            [self.delegate draggableObject:self didMoveWithinLocation:location];
          }
        }
        else {
          [location draggableObjectDidMoveOutsideBounds:self];
        }
      }
    }
  }
  
  // movement has just ended
  if (self.panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    BOOL didStopMovingWithinLocation = NO;
    SEDraggableLocation *dropLocation = nil;
    
    for (SEDraggableLocation *location in self.droppableLocations) {
      CGPoint myLocalCoordinates = [self.superview convertPoint:myCoordinates toView:location];
      if ([location pointIsInsideResponsiveBounds:myLocalCoordinates]) {
        didStopMovingWithinLocation = YES;
        dropLocation = location;
        break;
      }
    }
    
    //self.previousLocation = self.currentLocation; // retain self.currentLocation
    //[self.currentLocation removeDraggableObject:self]; // release self.currentLocation
    
    if (didStopMovingWithinLocation) {
      if ([self.delegate respondsToSelector:@selector(draggableObjectDidStopMoving:)])
        [self.delegate draggableObjectDidStopMoving:self];
      
      // @@TODO: should not hard-code "yes" here
      [dropLocation draggableObjectWasDroppedInside:self animated:YES];
      
      if ([self.delegate respondsToSelector:@selector(draggableObject:didStopMovingWithinLocation:)])
        [self.delegate draggableObject:self didStopMovingWithinLocation:dropLocation];
    }
    else {
      if (self.shouldSnapBackToHomeLocation) {
        // @@TODO: should not hard-code "yes" here
        [self askToSnapBackToLocation:self.homeLocation animated:YES];
      }
    }
    
  }
}



#pragma mark- SEDraggableLocationClient (notifications about the location's decision)

- (void) draggableLocation:(SEDraggableLocation *)location
            didAllowEntry:(SEDraggableLocationEntryMethod)entryMethod
                  animated:(BOOL)animated {
  
}

- (void) draggableLocation:(SEDraggableLocation *)location
            didRefuseEntry:(SEDraggableLocationEntryMethod)entryMethod
                  animated:(BOOL)animated {
  
  if (entryMethod == SEDraggableLocationEntryMethodWasDropped && self.shouldSnapBackToHomeLocation) {
    [self askToEnterLocation:self.homeLocation entryMethod:entryMethod animated:animated];
    // @@TODO: maybe also should handle snapping back to self.previousLocation rather than ONLY self.homeLocation
    
    // @@TODO: completion monitor / delegate notification
  }
  else if (entryMethod == SEDraggableLocationEntryMethodWantsToSnapBack) {
    // what's a girl to do? :(
  }
}

- (void) snapCenterToPoint:(CGPoint)point animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock {
  if (animated) {
    __block SEDraggable *myself = self;
    [UIView animateWithDuration:0.35f delay:0 options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       [myself setCenter:point];
                     }
                     completion:completionBlock];
  }
  else {
    self.center = point;
    if (completionBlock != nil)
      completionBlock(YES);
  }
}

#pragma mark - Requesting entry

#pragma mark -- Main method

- (void) askToEnterLocation:(SEDraggableLocation *)location entryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated {
  
  if ([self.delegate respondsToSelector:@selector(draggableObject:askedToSnapBackToLocation:)])
    [self.delegate draggableObject:self askedToSnapBackToLocation:self.homeLocation];
  
  [location draggableObject:self wantsToEnterLocationWithEntryMethod:entryMethod animated:animated];
}

#pragma mark -- Convenience methods

- (void) askToDropIntoLocation:(SEDraggableLocation *)location animated:(BOOL)animated {
  [self askToEnterLocation:location entryMethod:SEDraggableLocationEntryMethodWasDropped animated:animated];
}

- (void) askToSnapBackToLocation:(SEDraggableLocation *)location animated:(BOOL)animated {
  [self askToEnterLocation:location entryMethod:SEDraggableLocationEntryMethodWantsToSnapBack animated:animated];  
}




#pragma mark- NSCoding

- (void) encodeWithCoder:(NSCoder *)encoder {
  [super encodeWithCoder:encoder];
  [encoder encodeConditionalObject:self.panGestureRecognizer forKey:kPAN_GESTURE_RECOGNIZER_KEY];
  [encoder encodeObject:self.currentLocation forKey:kCURRENT_LOCATION_KEY];
  [encoder encodeObject:self.homeLocation forKey:kHOME_LOCATION_KEY];
  [encoder encodeObject:self.previousLocation forKey:kPREVIOUS_LOCATION_KEY];
  [encoder encodeObject:self.droppableLocations forKey:kDROPPABLE_LOCATIONS_KEY];
  [encoder encodeBool:self.shouldSnapBackToHomeLocation forKey:kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY];
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
    self.shouldSnapBackToHomeLocation = [decoder decodeBoolForKey:kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY];
    firstX = [decoder decodeFloatForKey:kFIRST_X_KEY];
    firstY = [decoder decodeFloatForKey:kFIRST_Y_KEY];
  }
  return self;
}

@end
