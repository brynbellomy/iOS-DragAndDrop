//
//  DraggableLocation.h
//  audigram
//
//  Created by bryn austin bellomy on 10/24/11.
//  Copyright 2011 signalenvelope LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Draggable, DraggableLocation;

@protocol DraggableLocationEventResponder

- (void) draggableLocation:(DraggableLocation *)location didAcceptDroppedObject:(Draggable *)object;
- (void) draggableLocation:(DraggableLocation *)location didRefuseDroppedObject:(Draggable *)object;
- (void) draggableObject:(Draggable *)object wasRemovedFromLocation:(DraggableLocation *)location;

@end



@interface DraggableLocation : NSObject {
  @private
    CGRect _responsiveBounds;
    CGRect _objectGutterBounds;
    BOOL _shouldAcceptDroppedObjects;
  BOOL _fillHorizontallyFirst;
  BOOL _allowRows;
  BOOL _allowColumns;
    id <DraggableLocationEventResponder> _delegate;
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
@property (nonatomic, readwrite, strong) id <DraggableLocationEventResponder> delegate;
@property (nonatomic, readwrite, strong) NSMutableArray *containedObjects;
@property (nonatomic, readwrite) int tag;

- (id)      initWithBounds:(CGRect)bounds;
- (void)    draggableObjectWasDroppedInside:(Draggable *)draggable;
- (void)    acceptDraggableObject:(Draggable *)draggable;
- (void)    refuseDraggableObject:(Draggable *)draggable;
- (void)    removeDraggableObject:(Draggable *)draggable;
- (CGPoint) calculateCenterOfDraggableObject:(Draggable *)object inPosition:(int)position;
- (CGPoint) getAcceptableLocationForDraggableObject:(Draggable *)object;
- (void)    recalculateAllObjectPositions;
- (BOOL)    pointIsInsideLocation:(CGPoint)point;


@end
