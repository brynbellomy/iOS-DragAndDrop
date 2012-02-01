//
//  DraggableLocation.mm
//  audigram
//
//  Created by bryn austin bellomy on 10/24/11.
//  Copyright 2011 signalenvelope LLC. All rights reserved.
//

#import "DraggableLocation.h"
#import "Draggable.h"

@implementation DraggableLocation

@synthesize responsiveBounds = _responsiveBounds,
            objectGutterBounds = _objectGutterBounds,
            shouldAcceptDroppedObjects = _shouldAcceptDroppedObjects,
            delegate = _delegate,
            containedObjects = _containedObjects,
            objectWidth = _objectWidth,
            objectHeight = _objectHeight,
            marginLeft = _marginLeft,
            marginRight = _marginRight,
            marginTop = _marginTop,
            marginBottom = _marginBottom,
            marginBetweenX = _marginBetweenX,
            marginBetweenY = _marginBetweenY,
            fillHorizontallyFirst = _fillHorizontallyFirst,
            allowRows = _allowRows,
            allowColumns = _allowColumns,
            tag = _tag;

- (id)initWithBounds:(CGRect)bounds {
  self = [super init];
  if (self) {
    self.objectGutterBounds = bounds;
    self.responsiveBounds = bounds;
    self.containedObjects = [[NSMutableArray alloc] init];
    self.shouldAcceptDroppedObjects = YES;
    self.delegate = nil;
    self.objectWidth = 0;
    self.objectHeight = 0;
    self.marginLeft = 0;
    self.marginRight = 0;
    self.marginTop = 0;
    self.marginBottom = 0;
    self.marginBetweenX = 0;
    self.marginBetweenY = 0;
    self.fillHorizontallyFirst = YES;
    self.allowRows = YES;
    self.allowColumns = YES;
  }
  
  return self;
}

- (void) dealloc {
  self.containedObjects;
  
}

- (CGPoint) calculateCenterOfDraggableObject:(Draggable *)object inPosition:(int)position {
  CGPoint point;
  int objectsPerRow = floor(((self.objectGutterBounds.size.width - self.marginLeft - self.marginRight - (2 * self.marginBetweenX)) / self.objectWidth));
  int objectsPerCol = floor(((self.objectGutterBounds.size.height - self.marginTop - self.marginBottom - (2 * self.marginBetweenY)) / self.objectHeight));
  int row, col;
  
  if (self.fillHorizontallyFirst) {
    col = position % objectsPerRow;
    row = (position - col) / objectsPerRow;
  }
  else {
    row = position % objectsPerCol;
    col = (position - row) / objectsPerCol;
  }
    
  point.x = self.objectGutterBounds.origin.x + self.marginLeft + (col * (self.marginBetweenX + self.objectWidth)) + (self.objectWidth / 2);
  point.y = self.objectGutterBounds.origin.y + self.marginTop  + (row * (self.marginBetweenY + self.objectHeight)) + (self.objectHeight / 2);
  
  return point;
}

- (CGPoint) getAcceptableLocationForDraggableObject:(Draggable *)object {
  return [self calculateCenterOfDraggableObject:object inPosition:self.containedObjects.count - 1];
}

- (void) draggableObjectWasDroppedInside:(Draggable *)draggable {
  if (self.shouldAcceptDroppedObjects) [self acceptDraggableObject:draggable];
  else                                 [self refuseDraggableObject:draggable];
}

- (void) acceptDraggableObject:(Draggable *)object {
  [self.containedObjects addObject:object];
  object.currentLocation = self;
  
  CGPoint point = [self calculateCenterOfDraggableObject:object inPosition:self.containedObjects.count - 1];
  [object snapCenterToPoint:point withAnimationID:@"snapToDraggableLocation" andContext:NULL];
  
  [self.delegate draggableLocation:self didAcceptDroppedObject:object];
}

- (void) refuseDraggableObject:(Draggable *)object {
  [object draggableLocationDidRefuseDrop:self];
  [self.delegate draggableLocation:self didRefuseDroppedObject:object];
}

- (void) removeDraggableObject:(Draggable *)draggable {
  if (draggable.currentLocation == self) {
    draggable.previousLocation = draggable.currentLocation;
    draggable.currentLocation = nil;
  }
  
  [self.containedObjects removeObject:draggable];
  [self.delegate draggableObject:draggable wasRemovedFromLocation:self];
}

- (void) recalculateAllObjectPositions {
  // recalculate positions for all icons
  int index = 0;
  for (Draggable *object in self.containedObjects) {
    [object.holderView setCenter:[self calculateCenterOfDraggableObject:object inPosition:index++]];
  }
}

- (BOOL) pointIsInsideLocation:(CGPoint)point {
  if (point.x > self.responsiveBounds.origin.x && point.x < (self.responsiveBounds.origin.x + self.responsiveBounds.size.width)
      && point.y > self.responsiveBounds.origin.y && point.y < (self.responsiveBounds.origin.y + self.responsiveBounds.size.height))
    return YES;
  else return NO;
}

@end
