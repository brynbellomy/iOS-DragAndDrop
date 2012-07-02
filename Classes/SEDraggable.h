//
//  SEDraggable.h
//  SEDraggable
//
//  Created by bryn austin bellomy <bryn@signals.io> on 10/23/11.
//  Copyright (c) 2012 robot bubble bath LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SEDraggableLocation.h"

@interface UIView (Helpr)
- (CGPoint) getCenterInWindowCoordinates;
@end

@class SEDraggableLocation, SEDraggable;

@protocol SEDraggableEventResponder <NSObject>
  @optional
      - (void) draggableObjectDidMove:(SEDraggable *)object;
      - (void) draggableObjectDidStopMoving:(SEDraggable *)object;

      - (void) draggableObject:(SEDraggable *)object didMoveWithinLocation:(SEDraggableLocation *)location;
      - (void) draggableObject:(SEDraggable *)object didStopMovingWithinLocation:(SEDraggableLocation *)location;

      - (void) draggableObject:(SEDraggable *)object willAskToEnterLocation:(SEDraggableLocation *)location withEntryMethod:(SEDraggableLocationEntryMethod)entryMethod;
      
      - (void) draggableObject:(SEDraggable *)object finishedEnteringLocation:(SEDraggableLocation *)location withEntryMethod:(SEDraggableLocationEntryMethod)entryMethod;
      - (void) draggableObject:(SEDraggable *)object failedToEnterLocation:(SEDraggableLocation *)location withEntryMethod:(SEDraggableLocationEntryMethod)entryMethod;

      - (BOOL) draggableObject:(SEDraggable *)object shouldAskToEnterLocation:(SEDraggableLocation *)location withEntryMethod:(SEDraggableLocationEntryMethod)entryMethod;
@end

// keyed archiving constants
#define kPAN_GESTURE_RECOGNIZER_KEY 						@"panGestureRecognizer"
#define kCURRENT_LOCATION_KEY                   @"currentLocation"
#define kHOME_LOCATION_KEY                      @"homeLocation"
#define kPREVIOUS_LOCATION_KEY                  @"previousLocation"
#define kDROPPABLE_LOCATIONS_KEY                @"droppableLocations"
#define kDELEGATE_KEY                           @"delegate"
#define kSHOULD_SNAP_BACK_TO_HOME_LOCATION_KEY 	@"shouldSnapBackToHomeLocation"
#define kSHOULD_SNAP_BACK_TO_DRAG_ORIGIN_KEY    @"shouldSnapBackToDragOrigin"
#define kFIRST_X_KEY                            @"firstX"
#define kFIRST_Y_KEY                            @"firstY"

@interface SEDraggable : UIView <SEDraggableLocationClient, UIGestureRecognizerDelegate, NSCoding> {

  SEDraggableLocation *_homeLocation;
  SEDraggableLocation __unsafe_unretained *_currentLocation;
  SEDraggableLocation __unsafe_unretained *_previousLocation;
  NSMutableSet *_droppableLocations;
  UIPanGestureRecognizer *_panGestureRecognizer;
  BOOL _shouldSnapBackToHomeLocation;
  BOOL _shouldSnapBackToDragOrigin;
  CGFloat firstX;
  CGFloat firstY;
  id <SEDraggableEventResponder> __unsafe_unretained _delegate;
}

@property (nonatomic, readwrite, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, readwrite, unsafe_unretained) SEDraggableLocation *currentLocation;
@property (nonatomic, readwrite, strong) SEDraggableLocation *homeLocation; // @@TODO: make sure this isn't causing retain cycles mmMmMMMmMMmm
@property (nonatomic, readwrite, unsafe_unretained) SEDraggableLocation *previousLocation;
@property (nonatomic, readwrite, strong) NSMutableSet *droppableLocations;
@property (nonatomic, readwrite, unsafe_unretained) id <SEDraggableEventResponder> delegate;
@property (nonatomic, readwrite) BOOL shouldSnapBackToHomeLocation;
@property (nonatomic, readwrite) BOOL shouldSnapBackToDragOrigin;
@property (nonatomic, readonly) CGFloat firstX;
@property (nonatomic, readonly) CGFloat firstY;

- (id) initWithImage:(UIImage *)image andSize:(CGSize)size;
- (id) initWithImageView:(UIImageView *)imageView;
- (void) addAllowedDropLocation:(SEDraggableLocation *)location;
- (void) snapCenterToPoint:(CGPoint)point animated:(BOOL)animated completion:(void (^)(BOOL))completionBlock;

- (void) askToDropIntoLocation:(SEDraggableLocation *)location animated:(BOOL)animated;
- (void) askToSnapBackToLocation:(SEDraggableLocation *)location animated:(BOOL)animated;


@end


