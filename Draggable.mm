//
//  Draggable.mm
//  audigram
//
//  Created by bryn austin bellomy on 10/23/11.
//  Copyright 2011 signalenvelope LLC. All rights reserved.
//

#import "Draggable.h"
#import "DraggableLocation.h"

@implementation Draggable

@synthesize isHidden = _isHidden,
            holderView = _holderView,
            shouldSnapBackToHomeFrame = _shouldSnapBackToHomeFrame,
            currentLocation = _currentLocation,
            homeLocation = _homeLocation,
            previousLocation = _previousLocation,
            delegate = _delegate,
            droppableLocations = _droppableLocations,
            tag = _tag,
            imageView = _imageView;

- (id) init {
  self = [super init];
  if (self) {
    // pan gesture handling
    _panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleDrag:)];
    [_panGestureRecognizer setMinimumNumberOfTouches:1];
    [_panGestureRecognizer setMaximumNumberOfTouches:1];
    [_panGestureRecognizer setDelegate:self];
    
    self.shouldSnapBackToHomeFrame = NO;
    self.isHidden = NO;
  }
  return self;
}

- (id) initWithImage:(UIImage *)image andSize:(CGSize)size andHomeLocation:(DraggableLocation *)location {
  self = [self init];
  
  if (self) {
    self.homeLocation = location;
    self.currentLocation = location;
    self.previousLocation = location;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0, 0, size.width, size.height);
    
    CGRect frame = CGRect(imageView.frame);
    CGPoint loc = [self.homeLocation getAcceptableLocationForDraggableObject:self];
    frame = CGRectOffset(frame, loc.x - (size.width / 2), loc.y - (size.height / 2));
    self.holderView = [[UIView alloc] initWithFrame:frame];
    [self.holderView addGestureRecognizer:_panGestureRecognizer];
    [self.holderView addSubview:imageView];
  }
  
  return self;
}

- (id) initWithImageView:(UIImageView *)imageView andHomeLocation:(DraggableLocation *)location {
  self = [self init];
  
  if (self) {
    self.homeLocation = location;
    self.currentLocation = location;
    self.previousLocation = location;
    
    CGRect frame = CGRect(imageView.frame);
    CGPoint loc = [self.homeLocation getAcceptableLocationForDraggableObject:self];
    //frame = CGRectOffset(frame, loc.x - (imageView.frame.size.width / 2), loc.y - (imageView.frame.size.height / 2));
    self.holderView = [[UIView alloc] initWithFrame:frame];
    [self.holderView addGestureRecognizer:_panGestureRecognizer];
    [self.holderView addSubview:imageView];
  }
  
  return self;
}

- (void) dealloc {
  [self.imageView removeFromSuperview];
  [self.holderView removeFromSuperview];
  [self.holderView removeGestureRecognizer:_panGestureRecognizer];
}

- (UIImageView *) imageView {
  return [self.holderView.subviews objectAtIndex:0];
}

- (void) handleDrag:(id)sender {
  CGPoint translatedPoint = [_panGestureRecognizer translationInView:self.holderView.superview];
  CGPoint myCoordinates   = [_panGestureRecognizer locationInView:self.holderView.superview];
	
  [self.holderView.superview bringSubviewToFront:self.holderView];
	
  // movement has just begun
	if (_panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
    // keep track of where the movement began
		firstX = [self.holderView center].x;
		firstY = [self.holderView center].y;
	}
  translatedPoint = CGPointMake(firstX + translatedPoint.x, firstY + translatedPoint.y);
  [self.holderView setCenter:translatedPoint];
  
  // movement is currently in process
  if (_panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
    [self.delegate draggableObjectDidMove:self];
    
    if (self.droppableLocations.count > 0) {
      for (DraggableLocation *location in self.droppableLocations) {
        if ([location pointIsInsideLocation:myCoordinates])
          [self.delegate draggableObject:self didMoveWithinLocation:location];
      }
    }
  }
  
  // movement has just ended
  if (_panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
    BOOL didStopMovingWithinLocation = NO;
    DraggableLocation *dropLocation = nil;
    
    for (DraggableLocation *location in self.droppableLocations) {
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

- (void) draggableLocationDidRefuseDrop:(DraggableLocation *)location {
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
  [self.holderView setCenter:point];
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


@end
