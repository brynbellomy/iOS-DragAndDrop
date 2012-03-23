//
//  SEDraggableLocation.h
//  audigram
//
//  Created by bryn austin bellomy on 10/24/11.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import <Foundation/Foundation.h>

@class SEDraggable, SEDraggableLocation;

@protocol SEDraggableLocationEventResponder
  @optional
    - (void) draggableLocation:(SEDraggableLocation *)location didAcceptDroppedObject:(SEDraggable *)object;
    - (void) draggableLocation:(SEDraggableLocation *)location didRefuseDroppedObject:(SEDraggable *)object;
    - (void) draggableObject:(SEDraggable *)object wasRemovedFromLocation:(SEDraggableLocation *)location;
@end

#define kRESPONSIVE_BOUNDS_KEY 						@"responsiveBounds"
#define kOBJECT_GUTTER_BOUNDS_KEY 						@"objectGutterBounds"
#define kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY 						@"shouldAcceptDroppedObjects"
#define kFILL_HORIZONTALLY_FIRST_KEY 						@"fillHorizontallyFirst"
#define kALLOW_ROWS_KEY 						@"allowRows"
#define kALLOW_COLUMNS_KEY 						@"allowColumns"
#define kDELEGATE_KEY 						@"delegate"
#define kOBJECT_HEIGHT_KEY 						@"objectHeight"
#define kOBJECT_WIDTH_KEY 						@"objectWidth"
#define kMARGIN_LEFT_KEY 						@"marginLeft"
#define kMARGIN_RIGHT_KEY 						@"marginRight"
#define kMARGIN_TOP_KEY 						@"marginTop"
#define kMARGIN_BOTTOM_KEY 						@"marginBottom"
#define kMARGIN_BETWEEN_X_KEY 						@"marginBetweenX"
#define kMARGIN_BETWEEN_Y_KEY 						@"marginBetweenY"
#define kCONTAINED_OBJECTS_KEY 						@"containedObjects"
#define kTAG_KEY 						@"tag"

@interface SEDraggableLocation : NSObject <NSCoding> {
  @private
    CGRect _responsiveBounds;
    CGRect _objectGutterBounds;
    BOOL _shouldAcceptDroppedObjects;
    BOOL _fillHorizontallyFirst;
    BOOL _allowRows;
    BOOL _allowColumns;
    id <SEDraggableLocationEventResponder> __unsafe_unretained _delegate;
    float _objectHeight;
    float _objectWidth;
    float _marginLeft;
    float _marginRight;
    float _marginTop;
    float _marginBottom;
    float _marginBetweenX;
    float _marginBetweenY;
    NSMutableArray *_containedObjects;
    int _tag;
}

@property (nonatomic, readwrite) float objectWidth;
@property (nonatomic, readwrite) float objectHeight;
@property (nonatomic, readwrite) float marginLeft;
@property (nonatomic, readwrite) float marginRight;
@property (nonatomic, readwrite) float marginTop;
@property (nonatomic, readwrite) float marginBottom;
@property (nonatomic, readwrite) float marginBetweenX;
@property (nonatomic, readwrite) float marginBetweenY;
@property (nonatomic, readwrite) CGRect responsiveBounds;
@property (nonatomic, readwrite) CGRect objectGutterBounds;
@property (nonatomic, readwrite) BOOL shouldAcceptDroppedObjects;
@property (nonatomic, readwrite) BOOL fillHorizontallyFirst;
@property (nonatomic, readwrite) BOOL allowRows;
@property (nonatomic, readwrite) BOOL allowColumns;
@property (nonatomic, readwrite, unsafe_unretained) id <SEDraggableLocationEventResponder> delegate;
@property (nonatomic, readwrite, strong) NSMutableArray *containedObjects;
@property (nonatomic, readwrite) int tag;

- (id)      initWithBounds:(CGRect)bounds;
- (void)    draggableObjectWasDroppedInside:(SEDraggable *)draggable;
- (void)    acceptDraggableObject:(SEDraggable *)draggable;
- (void)    refuseDraggableObject:(SEDraggable *)draggable;
- (void)    removeDraggableObject:(SEDraggable *)draggable;
- (CGPoint) calculateCenterOfDraggableObject:(SEDraggable *)object inPosition:(int)position;
- (CGPoint) getAcceptableLocationForDraggableObject:(SEDraggable *)object;
- (void)    recalculateAllObjectPositions;
- (BOOL)    pointIsInsideLocation:(CGPoint)point;


@end
