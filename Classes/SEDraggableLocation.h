//
//  SEDraggableLocation.h
//  SEDraggable
//
//  Created by bryn austin bellomy <bryn@signals.io> on 10/24/11.
//  Copyright (c) 2012 robot bubble bath LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  SEDraggableLocationEntryMethodWasDropped = 1, // refusable request from the user
  SEDraggableLocationEntryMethodWantsToSnapBack = 2, // refusable request from the draggable
  SEDraggableLocationEntryMethodWasAdded = 3 // unrefusable
} SEDraggableLocationEntryMethod;

@class SEDraggable, SEDraggableLocation;



@protocol SEDraggableLocationEventResponder <NSObject>
  @optional
    - (void) draggableLocation:(SEDraggableLocation *)location didAcceptObject:(SEDraggable *)object entryMethod:(SEDraggableLocationEntryMethod)method;
    - (void) draggableLocation:(SEDraggableLocation *)location didRefuseObject:(SEDraggable *)object entryMethod:(SEDraggableLocationEntryMethod)method;
    - (void) draggableLocation:(SEDraggableLocation *)location didMoveObject:(SEDraggable *)object;
    - (void) draggableLocationDidRecalculateObjectPositions:(SEDraggableLocation *)location;
    - (void) draggableObject:(SEDraggable *)object wasRemovedFromLocation:(SEDraggableLocation *)location;
    - (void) draggableObject:(SEDraggable *)object wasAddedToLocation:(SEDraggableLocation *)location;
@end



@protocol SEDraggableLocationClient <NSObject>
- (void) draggableLocation:(SEDraggableLocation *)location didAllowEntry:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;
- (void) draggableLocation:(SEDraggableLocation *)location didRefuseEntry:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;
@end


// NSCoding constants
#define kOBJECT_WIDTH_KEY             @"objectWidth"
#define kOBJECT_HEIGHT_KEY 						@"objectHeight"
#define kMARGIN_LEFT_KEY              @"marginLeft"
#define kMARGIN_RIGHT_KEY 						@"marginRight"
#define kMARGIN_TOP_KEY               @"marginTop"
#define kMARGIN_BOTTOM_KEY 						@"marginBottom"
#define kMARGIN_BETWEEN_X_KEY 				@"marginBetweenX"
#define kMARGIN_BETWEEN_Y_KEY 				@"marginBetweenY"
#define kRANDOM_ARRANGEMENT_OFFSET_MULTIPLIER_KEY @"randomArrangementOffsetMultiplier"
#define kRESPONSIVE_BOUNDS_KEY 				@"responsiveBounds"
#define kOBJECT_GUTTER_BOUNDS_KEY 		@"objectGutterBounds"
#define kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY 	@"shouldAcceptDroppedObjects"
#define kSHOULD_ACCEPT_OBJECTS_SNAPPING_BACK_KEY 						@"shouldAcceptObjectsSnappingBack"
#define kSHOULD_KEEP_OBJECTS_ARRANGED_KEY 						@"shouldKeepObjectsArranged"
#define kSHOULD_HIGHLIGHT_ON_DRAG_OVER_KEY 						@"shouldHighlightOnDragOver"
#define kHIGHLIGHT_COLOR_KEY 						@"highlightColor"
#define kHIGHLIGHT_OPACITY_KEY 						@"highlightOpacity"
#define kSHOULD_ANIMATE_OBJECT_ADJUSTMENTS_KEY 	@"shouldAnimateObjectAdjustments"
#define kANIMATION_DURATION_KEY 			@"animationDuration"
#define kANIMATION_DELAY_KEY 					@"animationDelay"
#define kANIMATION_OPTIONS_KEY 				@"animationOptions"
#define kFILL_HORIZONTALLY_FIRST_KEY 	@"fillHorizontallyFirst"
#define kALLOW_ROWS_KEY               @"allowRows"
#define kALLOW_COLUMNS_KEY 						@"allowColumns"
#define kDELEGATE_KEY                 @"delegate"
#define kCONTAINED_OBJECTS_KEY 				@"containedObjects"

@interface SEDraggableLocation : UIView <NSCoding>

@property (nonatomic, readwrite) float objectWidth;
@property (nonatomic, readwrite) float objectHeight;
@property (nonatomic, readwrite) float marginLeft;
@property (nonatomic, readwrite) float marginRight;
@property (nonatomic, readwrite) float marginTop;
@property (nonatomic, readwrite) float marginBottom;
@property (nonatomic, readwrite) float marginBetweenX;
@property (nonatomic, readwrite) float marginBetweenY;
@property (nonatomic, readwrite) float randomArrangementOffsetMultiplier;
@property (nonatomic, readwrite, strong) UIView *responsiveBounds;
@property (nonatomic, readwrite, strong) UIView *objectGutterBounds;
@property (nonatomic, readwrite) BOOL shouldAcceptDroppedObjects;
@property (nonatomic, readwrite) BOOL shouldAcceptObjectsSnappingBack;
@property (nonatomic, readwrite) BOOL shouldKeepObjectsArranged;
@property (nonatomic, readwrite) BOOL shouldAnimateObjectAdjustments;
@property (nonatomic, readwrite) BOOL shouldHighlightOnDragOver;
@property (nonatomic, readwrite) CGColorRef highlightColor;
@property (nonatomic, readwrite) CGFloat highlightOpacity;
@property (nonatomic, readwrite) CGFloat animationDuration;
@property (nonatomic, readwrite) CGFloat animationDelay;
@property (nonatomic, readwrite) UIViewAnimationOptions animationOptions;
@property (nonatomic, readwrite) BOOL fillHorizontallyFirst;
@property (nonatomic, readwrite) BOOL allowRows;
@property (nonatomic, readwrite) BOOL allowColumns;
@property (nonatomic, readwrite, unsafe_unretained) id <SEDraggableLocationEventResponder> delegate;
@property (nonatomic, readwrite, strong) NSMutableArray *containedObjects;


- (void) removeDraggableObject:(SEDraggable *)draggable;
- (void) recalculateAllObjectPositions;
- (BOOL) pointIsInsideResponsiveBounds:(CGPoint)point;

// this method expresses a draggable attempting to enter a location
- (BOOL) draggableObject:(SEDraggable *)draggable wantsToEnterLocationWithEntryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;

// these are convenience methods for purposes of readability; they proxy to the above method
- (BOOL) draggableObjectWantsToSnapBack:(SEDraggable *)draggable animated:(BOOL)animated;
- (BOOL) draggableObjectWasDroppedInside:(SEDraggable *)draggable animated:(BOOL)animated;
- (void) addDraggableObject:(SEDraggable *)draggable animated:(BOOL)animated;

// movement handlers
- (void) draggableObjectDidMoveWithinBounds:(SEDraggable *)draggable;
- (void) draggableObjectDidMoveOutsideBounds:(SEDraggable *)draggable;

@end
