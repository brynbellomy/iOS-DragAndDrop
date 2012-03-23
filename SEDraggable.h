//
//  SEDraggable.h
//  SEDraggable
//
//  Created by bryn austin bellomy on 10/23/11.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEDraggableLocation.h"

@class SEDraggableLocation, SEDraggable;

@protocol SEDraggableEventResponder <NSObject>
  @optional
      - (void) draggableObjectDidMove:(SEDraggable *)object;
      - (void) draggableObjectDidStopMoving:(SEDraggable *)object;

      - (void) draggableObject:(SEDraggable *)object didMoveWithinLocation:(SEDraggableLocation *)location;
      - (void) draggableObject:(SEDraggable *)object didStopMovingWithinLocation:(SEDraggableLocation *)location;

      - (void) draggableObjectWillSnapBackToHomeFrame:(SEDraggable *)object;
      - (void) draggableObjectDidEndSnappingBackToHomeFrame:(SEDraggable *)object;

      - (void) draggableObject:(SEDraggable *)object didBeginSnapAnimationWithID:(NSString *)animationID andContext:(void *)context;
      - (void) draggableObject:(SEDraggable *)object didEndSnapAnimationWithID:(NSString *)animationID andContext:(void *)context; // it's up to the delegate to set draggable.currentLocation when the delegate initiates the animation and it's appropriate to do so

@end

#define kPAN_GESTURE_RECOGNIZER_KEY 						@"panGestureRecognizer"
#define kCURRENT_LOCATION_KEY                   @"currentLocation"
#define kHOME_LOCATION_KEY                      @"homeLocation"
#define kPREVIOUS_LOCATION_KEY                  @"previousLocation"
#define kDROPPABLE_LOCATIONS_KEY                @"droppableLocations"
#define kSHOULD_SNAP_BACK_TO_HOME_FRAME_KEY 		@"shouldSnapBackToHomeFrame"
#define kFIRST_X_KEY                            @"firstX"
#define kFIRST_Y_KEY                            @"firstY"

@interface SEDraggable : UIView <SEDraggableLocationClient, UIGestureRecognizerDelegate, NSCoding> {

  SEDraggableLocation *_homeLocation;
  SEDraggableLocation *_currentLocation;
  SEDraggableLocation *_previousLocation;
  NSMutableSet *_droppableLocations;
  UIPanGestureRecognizer *_panGestureRecognizer;
  BOOL _shouldSnapBackToHomeFrame;
  CGFloat firstX;
  CGFloat firstY;
  id <SEDraggableEventResponder> __unsafe_unretained _delegate;
}

@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readwrite, strong) SEDraggableLocation *currentLocation;
@property (nonatomic, readwrite, strong) SEDraggableLocation *homeLocation;
@property (nonatomic, readwrite, strong) SEDraggableLocation *previousLocation;
@property (nonatomic, readwrite, strong) NSMutableSet *droppableLocations;
@property (nonatomic, readwrite, unsafe_unretained) id <SEDraggableEventResponder> delegate;
@property (nonatomic, readwrite) BOOL shouldSnapBackToHomeFrame;
@property (nonatomic, readonly) CGFloat firstX;
@property (nonatomic, readonly) CGFloat firstY;

- (id) initWithImage:(UIImage *)image andSize:(CGSize)size;
- (id) initWithImageView:(UIImageView *)imageView;
- (void) addAllowedDropLocation:(SEDraggableLocation *)location;
- (void) snapCenterToPoint:(CGPoint)point withAnimationID:(NSString *)animationID andContext:(void *)context;
- (void) snapBackToHomeFrame;

@end


