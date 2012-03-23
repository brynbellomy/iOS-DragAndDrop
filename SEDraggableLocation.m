//
//  SEDraggableLocation.m
//  SEDraggable
//
//  Created by bryn austin bellomy on 10/24/11.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import "SEDraggableLocation.h"
#import "SEDraggable.h"

@implementation SEDraggableLocation

@synthesize responsiveBounds = _responsiveBounds;
@synthesize objectGutterBounds = _objectGutterBounds;
@synthesize shouldAcceptDroppedObjects = _shouldAcceptDroppedObjects;
@synthesize delegate = _delegate;
@synthesize containedObjects = _containedObjects;
@synthesize objectWidth = _objectWidth;
@synthesize objectHeight = _objectHeight;
@synthesize marginLeft = _marginLeft;
@synthesize marginRight = _marginRight;
@synthesize marginTop = _marginTop;
@synthesize marginBottom = _marginBottom;
@synthesize marginBetweenX = _marginBetweenX;
@synthesize marginBetweenY = _marginBetweenY;
@synthesize fillHorizontallyFirst = _fillHorizontallyFirst;
@synthesize allowRows = _allowRows;
@synthesize allowColumns = _allowColumns;
@synthesize tag = _tag;

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

- (CGPoint) calculateCenterOfDraggableObject:(SEDraggable *)object inPosition:(int)position {
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

- (CGPoint) getAcceptableLocationForDraggableObject:(SEDraggable *)object {
  return [self calculateCenterOfDraggableObject:object inPosition:self.containedObjects.count - 1];
}

- (void) draggableObjectWasDroppedInside:(SEDraggable *)draggable {
  if (self.shouldAcceptDroppedObjects) [self acceptDraggableObject:draggable];
  else                                 [self refuseDraggableObject:draggable];
}

- (void) acceptDraggableObject:(SEDraggable *)object {
  [self.containedObjects addObject:object];
  object.currentLocation = self;
  
  CGPoint point = [self calculateCenterOfDraggableObject:object inPosition:self.containedObjects.count - 1];
  [object snapCenterToPoint:point withAnimationID:@"snapToDraggableLocation" andContext:NULL];
  
  [self.delegate draggableLocation:self didAcceptDroppedObject:object];
}

- (void) refuseDraggableObject:(SEDraggable *)object {
  [object draggableLocationDidRefuseDrop:self];
  [self.delegate draggableLocation:self didRefuseDroppedObject:object];
}

- (void) removeDraggableObject:(SEDraggable *)draggable {
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
  for (SEDraggable *object in self.containedObjects) {
    [object setCenter:[self calculateCenterOfDraggableObject:object inPosition:index++]];
  }
}

- (BOOL) pointIsInsideLocation:(CGPoint)point {
  if (point.x > self.responsiveBounds.origin.x && point.x < (self.responsiveBounds.origin.x + self.responsiveBounds.size.width)
      && point.y > self.responsiveBounds.origin.y && point.y < (self.responsiveBounds.origin.y + self.responsiveBounds.size.height))
    return YES;
  else return NO;
}

#pragma mark- NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeCGRect:self.responsiveBounds forKey:kRESPONSIVE_BOUNDS_KEY];
  [encoder encodeCGRect:self.objectGutterBounds forKey:kOBJECT_GUTTER_BOUNDS_KEY];
  [encoder encodeBool:self.shouldAcceptDroppedObjects forKey:kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY];
  [encoder encodeBool:self.fillHorizontallyFirst forKey:kFILL_HORIZONTALLY_FIRST_KEY];
  [encoder encodeBool:self.allowRows forKey:kALLOW_ROWS_KEY];
  [encoder encodeBool:self.allowColumns forKey:kALLOW_COLUMNS_KEY];
  [encoder encodeObject:self.delegate forKey:kDELEGATE_KEY];
  [encoder encodeFloat:self.objectHeight forKey:kOBJECT_HEIGHT_KEY];
  [encoder encodeFloat:self.objectWidth forKey:kOBJECT_WIDTH_KEY];
  [encoder encodeFloat:self.marginLeft forKey:kMARGIN_LEFT_KEY];
  [encoder encodeFloat:self.marginRight forKey:kMARGIN_RIGHT_KEY];
  [encoder encodeFloat:self.marginTop forKey:kMARGIN_TOP_KEY];
  [encoder encodeFloat:self.marginBottom forKey:kMARGIN_BOTTOM_KEY];
  [encoder encodeFloat:self.marginBetweenX forKey:kMARGIN_BETWEEN_X_KEY];
  [encoder encodeFloat:self.marginBetweenY forKey:kMARGIN_BETWEEN_Y_KEY];
  [encoder encodeObject:self.containedObjects forKey:kCONTAINED_OBJECTS_KEY];
  [encoder encodeInt:self.tag forKey:kTAG_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if (self = [super init]) {
    self.responsiveBounds = [decoder decodeCGRectForKey:kRESPONSIVE_BOUNDS_KEY];
    self.objectGutterBounds = [decoder decodeCGRectForKey:kOBJECT_GUTTER_BOUNDS_KEY];
    self.shouldAcceptDroppedObjects = [decoder decodeBoolForKey:kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY];
    self.fillHorizontallyFirst = [decoder decodeBoolForKey:kFILL_HORIZONTALLY_FIRST_KEY];
    self.allowRows = [decoder decodeBoolForKey:kALLOW_ROWS_KEY];
    self.allowColumns = [decoder decodeBoolForKey:kALLOW_COLUMNS_KEY];
    self.delegate = [decoder decodeObjectForKey:kDELEGATE_KEY];
    self.objectHeight = [decoder decodeFloatForKey:kOBJECT_HEIGHT_KEY];
    self.objectWidth = [decoder decodeFloatForKey:kOBJECT_WIDTH_KEY];
    self.marginLeft = [decoder decodeFloatForKey:kMARGIN_LEFT_KEY];
    self.marginRight = [decoder decodeFloatForKey:kMARGIN_RIGHT_KEY];
    self.marginTop = [decoder decodeFloatForKey:kMARGIN_TOP_KEY];
    self.marginBottom = [decoder decodeFloatForKey:kMARGIN_BOTTOM_KEY];
    self.marginBetweenX = [decoder decodeFloatForKey:kMARGIN_BETWEEN_X_KEY];
    self.marginBetweenY = [decoder decodeFloatForKey:kMARGIN_BETWEEN_Y_KEY];
    self.containedObjects = [decoder decodeObjectForKey:kCONTAINED_OBJECTS_KEY];
    self.tag = [decoder decodeIntForKey:kTAG_KEY];
  }
  return self;
}

@end
