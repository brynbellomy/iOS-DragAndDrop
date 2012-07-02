//
//  SEDraggable.m
//  SEDraggable
//
//  Created by bryn austin bellomy <bryn@signals.io> on 10/23/11.
//  Copyright (c) 2012 robot bubble bath LLC. All rights reserved.
//

#import "SEDraggable.h"
#import "SEDraggableLocation.h"

@implementation UIView (Helpr)
- (CGPoint) getCenterInWindowCoordinates {
  if (self.superview != nil)
    return [self.superview convertPoint:self.center toView:nil];
  else
    return self.center;
}
@end

@interface SEDraggable ()
- (void) handleDrag:(id)sender;
- (BOOL) askToEnterLocation:(SEDraggableLocation *)location entryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;
@end

@implementation SEDraggable

@synthesize shouldSnapBackToHomeLocation = _shouldSnapBackToHomeLocation;
@synthesize shouldSnapBackToDragOrigin = _shouldSnapBackToDragOrigin;
@synthesize currentLocation = _currentLocation;
@synthesize homeLocation = _homeLocation;
@synthesize previousLocation = _previousLocation;
@synthesize delegate = _delegate;
@synthesize droppableLocations = _droppableLocations;
@synthesize panGestureRecognizer = _panGestureRecognizer;
@synthesize firstX;
@synthesize firstY;



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
    self.shouldSnapBackToDragOrigin = YES;
    
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
        CGPoint myWindowCoordinates = [self.superview convertPoint:myCoordinates toView:nil];
        if ([location pointIsInsideResponsiveBounds:myWindowCoordinates]) {
          [location draggableObjectDidMoveWithinBounds:self];
          if ([self.delegate respondsToSelector:@selector(draggableObject:didMoveWithinLocation:)]) {
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
      CGPoint myWindowCoordinates = [self.superview convertPoint:myCoordinates toView:nil];
      if ([location pointIsInsideResponsiveBounds:myWindowCoordinates]) {
        // the draggable will ask for entry into every draggable location whose bounds it is inside until the first YES, at which point the search stops
        BOOL allowedEntry = [self askToEnterLocation:location entryMethod:SEDraggableLocationEntryMethodWasDropped animated:YES];
        if (allowedEntry) {
          didStopMovingWithinLocation = YES;
          dropLocation = location;
          break;
        }
      }
    }
    
    if (didStopMovingWithinLocation) {
      if ([self.delegate respondsToSelector:@selector(draggableObjectDidStopMoving:)])
        [self.delegate draggableObjectDidStopMoving:self];
      
//      [dropLocation draggableObjectWasDroppedInside:self animated:YES];
      
      if ([self.delegate respondsToSelector:@selector(draggableObject:didStopMovingWithinLocation:)])
        [self.delegate draggableObject:self didStopMovingWithinLocation:dropLocation];
    }
    else {
      if (self.shouldSnapBackToHomeLocation) {
        // @@TODO: should not hard-code "yes" here
        [self askToSnapBackToLocation:self.homeLocation animated:YES];
      }
      else if (self.shouldSnapBackToDragOrigin) {
        [self askToSnapBackToLocation:self.currentLocation animated:YES];
      }
    }
    
  }
}



#pragma mark- SEDraggableLocationClient (notifications about the location's decision)

- (void) draggableLocation:(SEDraggableLocation *)location
            didAllowEntry:(SEDraggableLocationEntryMethod)entryMethod
                  animated:(BOOL)animated {

  if ([self.delegate respondsToSelector:@selector(draggableObject:finishedEnteringLocation:withEntryMethod:)])
    [self.delegate draggableObject:self finishedEnteringLocation:location withEntryMethod:entryMethod];
}

- (void) draggableLocation:(SEDraggableLocation *)location
            didRefuseEntry:(SEDraggableLocationEntryMethod)entryMethod
                  animated:(BOOL)animated {
  
  if ([self.delegate respondsToSelector:@selector(draggableObject:failedToEnterLocation:withEntryMethod:)])
    [self.delegate draggableObject:self failedToEnterLocation:location withEntryMethod:entryMethod];
  
  if (entryMethod == SEDraggableLocationEntryMethodWasDropped && self.shouldSnapBackToHomeLocation) {
    [self askToEnterLocation:self.homeLocation entryMethod:entryMethod animated:animated];
    // @@TODO: maybe also should handle snapping back to self.previousLocation rather than ONLY self.homeLocation
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

- (BOOL) askToEnterLocation:(SEDraggableLocation *)location entryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated {
  
  BOOL shouldAsk = YES;
  if ([self.delegate respondsToSelector:@selector(draggableObject:shouldAskToEnterLocation:withEntryMethod:)]) {
    shouldAsk = [self.delegate draggableObject:self shouldAskToEnterLocation:location withEntryMethod:entryMethod];
  }
  
  if (shouldAsk == YES) {
    if ([self.delegate respondsToSelector:@selector(draggableObject:willAskToEnterLocation:withEntryMethod:)])
      [self.delegate draggableObject:self willAskToEnterLocation:location withEntryMethod:entryMethod];
    
    return [location draggableObject:self wantsToEnterLocationWithEntryMethod:entryMethod animated:animated];
  }
  return NO;
}

#pragma mark -- Convenience methods

- (void) askToDropIntoLocation:(SEDraggableLocation *)location animated:(BOOL)animated {
  [self askToEnterLocation:location entryMethod:SEDraggableLocationEntryMethodWasDropped animated:animated];
}

- (void) askToSnapBackToLocation:(SEDraggableLocation *)location animated:(BOOL)animated {
  [self askToEnterLocation:location entryMethod:SEDraggableLocationEntryMethodWantsToSnapBack animated:animated];  
}




#pragma mark- NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
  [super encodeWithCoder:encoder];
  [encoder encodeConditionalObject:self.panGestureRecognizer forKey:kPAN_GESTURE_RECOGNIZER_KEY];
  [encoder encodeObject:self.currentLocation forKey:kCURRENT_LOCATION_KEY];
  [encoder encodeObject:self.homeLocation forKey:kHOME_LOCATION_KEY];
  [encoder encodeObject:self.previousLocation forKey:kPREVIOUS_LOCATION_KEY];
  [encoder encodeObject:self.droppableLocations forKey:kDROPPABLE_LOCATIONS_KEY];
  [encoder encodeObject:self.delegate forKey:kDELEGATE_KEY];
  [encoder encodeBool:self.shouldSnapBackToHomeLocation forKey:kSHOULD_SNAP_BACK_TO_HOME_LOCATION_KEY];
  [encoder encodeBool:self.shouldSnapBackToDragOrigin forKey:kSHOULD_SNAP_BACK_TO_DRAG_ORIGIN_KEY];
  [encoder encodeFloat:self.firstX forKey:kFIRST_X_KEY];
  [encoder encodeFloat:self.firstY forKey:kFIRST_Y_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if (self) {
    if ([decoder containsValueForKey:kPAN_GESTURE_RECOGNIZER_KEY])
      self.panGestureRecognizer = [decoder decodeObjectForKey:kPAN_GESTURE_RECOGNIZER_KEY];
    if ([decoder containsValueForKey:kCURRENT_LOCATION_KEY])
      self.currentLocation = [decoder decodeObjectForKey:kCURRENT_LOCATION_KEY];
    if ([decoder containsValueForKey:kHOME_LOCATION_KEY])
      self.homeLocation = [decoder decodeObjectForKey:kHOME_LOCATION_KEY];
    if ([decoder containsValueForKey:kPREVIOUS_LOCATION_KEY])
      self.previousLocation = [decoder decodeObjectForKey:kPREVIOUS_LOCATION_KEY];
    if ([decoder containsValueForKey:kDROPPABLE_LOCATIONS_KEY])
      self.droppableLocations = [decoder decodeObjectForKey:kDROPPABLE_LOCATIONS_KEY];
    if ([decoder containsValueForKey:kDELEGATE_KEY])
      self.delegate = [decoder decodeObjectForKey:kDELEGATE_KEY];
    if ([decoder containsValueForKey:kSHOULD_SNAP_BACK_TO_HOME_LOCATION_KEY])
      self.shouldSnapBackToHomeLocation = [decoder decodeBoolForKey:kSHOULD_SNAP_BACK_TO_HOME_LOCATION_KEY];
    if ([decoder containsValueForKey:kSHOULD_SNAP_BACK_TO_DRAG_ORIGIN_KEY])
      self.shouldSnapBackToDragOrigin = [decoder decodeBoolForKey:kSHOULD_SNAP_BACK_TO_DRAG_ORIGIN_KEY];
    if ([decoder containsValueForKey:kFIRST_X_KEY])
      firstX = [decoder decodeFloatForKey:kFIRST_X_KEY];
    if ([decoder containsValueForKey:kFIRST_Y_KEY])
      firstY = [decoder decodeFloatForKey:kFIRST_Y_KEY];
  }
  return self;
}

@end
