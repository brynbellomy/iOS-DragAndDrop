//
//  SEDraggableLocation.m
//  SEDraggable
//
//  Created by bryn austin bellomy on 10/24/11.
//  Copyright (c) 2012 signals.io» (signalenvelope LLC). All rights reserved.
//

#import "SEDraggableLocation.h"
#import "SEDraggable.h"
#import "Common.h"

const NSInteger SEDraggableLocationPositionDetermineAutomatically = -1;

@interface SEDraggableLocation ()

@property (nonatomic, readwrite, strong) UIView *highlightView;

- (void)    acceptDraggableObject:(SEDraggable *)draggable entryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;
- (void)    refuseDraggableObject:(SEDraggable *)draggable entryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated;
- (CGPoint) calculateCenterOfDraggableObject:(SEDraggable *)object inPosition:(NSInteger)position;
- (CGPoint) getAcceptableLocationForDraggableObject:(SEDraggable *)object inPosition:(NSInteger)position;
- (CGPoint) calculateNearestPointInGutterBoundsForDraggableObject:(SEDraggable *)draggable;
//- (void)    snapDraggableIntoBounds:(SEDraggable *)object completion:(void (^)())block;

@end

@implementation SEDraggableLocation

@synthesize responsiveBounds = _responsiveBounds;
@synthesize objectGutterBounds = _objectGutterBounds;
@synthesize shouldAcceptDroppedObjects = _shouldAcceptDroppedObjects;
@synthesize shouldAcceptObjectsSnappingBack = _shouldAcceptObjectsSnappingBack;
@synthesize shouldKeepObjectsArranged = _shouldKeepObjectsArranged;
@synthesize shouldAnimateObjectAdjustments = _shouldAnimateObjectAdjustments;
@synthesize animationDuration = _animationDuration;
@synthesize animationDelay = _animationDelay;
@synthesize animationOptions = _animationOptions;
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
@synthesize randomArrangementOffsetMultiplier = _randomArrangementOffsetMultiplier;
@synthesize fillHorizontallyFirst = _fillHorizontallyFirst;
@synthesize allowRows = _allowRows;
@synthesize allowColumns = _allowColumns;
@synthesize shouldHighlightOnDragOver = _shouldHighlightOnDragOver;
@synthesize highlightColor = _highlightColor;
@synthesize highlightOpacity = _highlightOpacity;
@synthesize highlightView = _highlightView;



#pragma mark- Lifecycle

- (id)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self defaultAllOwnProperties];
  }
  return self;
}

- (void) defaultAllOwnProperties {
  CGRect localFrame = self.frame;
  localFrame.origin = CGPointZero;
  self.objectGutterBounds = [[UIView alloc] initWithFrame:localFrame];
  self.objectGutterBounds.contentMode = UIViewContentModeScaleToFill;
  self.objectGutterBounds.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self addSubview:self.objectGutterBounds];
  self.responsiveBounds = [[UIView alloc] initWithFrame:localFrame];
  self.responsiveBounds.contentMode = UIViewContentModeScaleToFill;
  self.responsiveBounds.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  [self addSubview:self.responsiveBounds];
  
  self.shouldHighlightOnDragOver = NO;
  self.highlightOpacity = 1.0f;
  self.highlightView = [[UIView alloc] initWithFrame:localFrame];
  self.highlightView.contentMode = UIViewContentModeScaleToFill;
  self.highlightView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
  self.highlightView.hidden = YES;
  [self addSubview:self.highlightView];
  
  self.containedObjects = [[NSMutableArray alloc] init];
  self.shouldAcceptDroppedObjects = YES;
  self.shouldAcceptObjectsSnappingBack = YES;
  self.shouldKeepObjectsArranged = YES;
  self.shouldAnimateObjectAdjustments = YES;
  self.animationDuration = 0.3f;
  self.animationDelay = 0.0f;
  self.animationOptions = UIViewAnimationOptionBeginFromCurrentState;
  self.delegate = nil;
  self.objectWidth = 0;
  self.objectHeight = 0;
  self.marginLeft = 0;
  self.marginRight = 0;
  self.marginTop = 0;
  self.marginBottom = 0;
  self.marginBetweenX = 0;
  self.marginBetweenY = 0;
  self.randomArrangementOffsetMultiplier = 0.0f;
  self.fillHorizontallyFirst = YES;
  self.allowRows = YES;
  self.allowColumns = YES;
}

- (void) addSubview:(UIView *)view {
  [super addSubview:view];
  [self sendSubviewToBack:self.highlightView];
}



#pragma mark- Permission to enter location

- (void) draggableObject:(SEDraggable *)draggable wantsToEnterLocationWithEntryMethod:(SEDraggableLocationEntryMethod)entryMethod animated:(BOOL)animated {
  
  BOOL allow = YES; // default to allow
  
  switch (entryMethod) {
    case SEDraggableLocationEntryMethodWasDropped:
      allow = self.shouldAcceptDroppedObjects;
      break;
    case SEDraggableLocationEntryMethodWantsToSnapBack:
      allow = self.shouldAcceptObjectsSnappingBack;
      break;
    case SEDraggableLocationEntryMethodWasAdded:
      // always allow when the draggable is force-added
      allow = YES;
      break;
    default:
      break;
  }
  
  if (allow) [self acceptDraggableObject:draggable entryMethod:entryMethod animated:animated];
  else       [self refuseDraggableObject:draggable entryMethod:entryMethod animated:animated];
}

#pragma mark -- Convenience methods

- (void) draggableObjectWantsToSnapBack:(SEDraggable *)draggable animated:(BOOL)animated {
  [self draggableObject:draggable wantsToEnterLocationWithEntryMethod:SEDraggableLocationEntryMethodWantsToSnapBack animated:animated];
}

- (void) draggableObjectWasDroppedInside:(SEDraggable *)draggable animated:(BOOL)animated {
  [self draggableObject:draggable wantsToEnterLocationWithEntryMethod:SEDraggableLocationEntryMethodWasDropped animated:animated];
}

- (void) addDraggableObject:(SEDraggable *)draggable animated:(BOOL)animated {
  [self draggableObject:draggable wantsToEnterLocationWithEntryMethod:SEDraggableLocationEntryMethodWasAdded animated:animated];
}

/*- (void) addDraggableObject:(SEDraggable *)draggable animated:(BOOL)animated {
  [self draggableObjectWasForciblyAdded:draggable animated:animated];
  
  [self addSubview:draggable];
   
   CGPoint endPoint = [self getAcceptableLocationForDraggableObject:draggable
   inPosition:SEDraggableLocationPositionDetermineAutomatically];
   // @@TODO: convert point from one view's coordinate system to another?
   if (animated) {
   [draggable snapCenterToPoint:endPoint completion:nil];
   }
   else {
   draggable.center = endPoint;
   }
   
   draggable.currentLocation = self;
   
   // notify delegate
   if ([self.delegate respondsToSelector:@selector(draggableObject:wasAddedToLocation:)])
   [self.delegate draggableObject:draggable wasAddedToLocation:self];
}*/



#pragma mark- Movement event handlers

- (void) draggableObjectDidMoveWithinBounds:(SEDraggable *)draggable {
  if (self.shouldHighlightOnDragOver && self.highlightColor != nil) {
    self.highlightView.backgroundColor = self.highlightColor;
    self.highlightView.alpha = self.highlightOpacity;
    self.highlightView.hidden = NO;
  }
}

- (void) draggableObjectDidMoveOutsideBounds:(SEDraggable *)draggable {
  if (self.shouldHighlightOnDragOver && self.highlightColor != nil) {
    self.highlightView.backgroundColor = [UIColor clearColor];
    self.highlightView.hidden = YES;
  }
}



#pragma mark- Geometry helpers

- (CGPoint) calculateCenterOfDraggableObject:(SEDraggable *)object inPosition:(NSInteger)position {
  CGPoint point;
  //self.objectGutterBounds.frame = self.frame;
  //NSLog(@"gutter: %f %f %f %f", self.objectGutterBounds.origin.x, self.objectGutterBounds.origin.y, self.objectGutterBounds.size.width ,self.objectGutterBounds.size.height);
  CGRect rect = self.objectGutterBounds.frame; //[self convertRect:self.objectGutterBounds fromView:self.superview];
  int objectsPerRow = floor(((rect.size.width - self.marginLeft - self.marginRight - (2 * self.marginBetweenX)) / self.objectWidth));
  int objectsPerCol = floor(((rect.size.height - self.marginTop - self.marginBottom - (2 * self.marginBetweenY)) / self.objectHeight));
  int row, col;
  
  // prevent divide-by-zero errors
  if (objectsPerRow == 0) objectsPerRow = 1;
  if (objectsPerCol == 0) objectsPerCol = 1;
  
  if (self.fillHorizontallyFirst) {
    col = position % objectsPerRow;
    row = (position - col) / objectsPerRow;
  }
  else {
    row = position % objectsPerCol;
    col = (position - row) / objectsPerCol;
  }
  
  point.x = rect.origin.x + self.marginLeft + (col * (self.marginBetweenX + self.objectWidth)) + (self.objectWidth / 2);
  point.y = rect.origin.y + self.marginTop  + (row * (self.marginBetweenY + self.objectHeight)) + (self.objectHeight / 2);
  
  return point;
}

- (CGPoint) calculateNearestPointInGutterBoundsForDraggableObject:(SEDraggable *)draggable {
//  CGPoint topLeftCorner = {0};
//  topLeftCorner.x = draggable.center.x - (draggable.bounds.size.width / 2);
//  topLeftCorner.y = draggable.center.y - (draggable.bounds.size.height / 2);

  //if (self pointInside:<#(CGPoint)#> withEvent:<#(UIEvent *)#>
  
  return draggable.center;
}

- (CGPoint) getAcceptableLocationForDraggableObject:(SEDraggable *)object inPosition:(NSInteger)position {
  if (position == SEDraggableLocationPositionDetermineAutomatically) {
    if (self.shouldKeepObjectsArranged) {
      position = self.containedObjects.count - 1;
      return [self calculateCenterOfDraggableObject:object inPosition:position];
    }
    else {
      // return the center point
      //@@CONVERTPOINT return CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
      return [self getCenterInWindowCoordinates]; //[self convertPoint:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds)) toView:nil];
    }
  }
  else {
    if (self.shouldKeepObjectsArranged) {
      position = self.containedObjects.count - 1;
      return [self calculateCenterOfDraggableObject:object inPosition:position];
    }
    else {
      // @@TODO: ??
      // for now gonna return the center point
      return [self getCenterInWindowCoordinates];
    }
  }
}

- (void) recalculateAllObjectPositions {
  __block SEDraggableLocation *myself = self;
  
  void (^blockRecalculate)() = ^{
    NSInteger index = 0;
    unsigned int iseed = (unsigned int)time(NULL);
    srand(iseed);
    double max = RAND_MAX;
    double irand;
    double mult = self.randomArrangementOffsetMultiplier;
    for (SEDraggable *object in myself.containedObjects) {
      CGPoint center = [myself getAcceptableLocationForDraggableObject:object inPosition:index++];
      irand = (double)rand();
      center.x += (CGFloat)((irand / max) * mult) - (mult / 2);
      center.y += (CGFloat)((irand / max) * mult) - (mult / 2);
      
      [object setCenter:center];
    }
  };
  
  void (^blockCompletion)(BOOL) = ^(BOOL finished) {
    if ([myself.delegate respondsToSelector:@selector(draggableLocationDidRecalculateObjectPositions:)])
      [myself.delegate draggableLocationDidRecalculateObjectPositions:myself];
  };
  
  if (self.shouldAnimateObjectAdjustments) {
    [UIView animateWithDuration:self.animationDuration delay:self.animationDelay options:self.animationOptions
                     animations:blockRecalculate completion:blockCompletion];
  }
  else {
    blockRecalculate();
    blockCompletion(YES);
  }
}

- (BOOL) pointIsInsideResponsiveBounds:(CGPoint)point {
  // 'point' must be in self's local coordinate system already (@@CONVERTPOINT not true at the moment)
  
  NSLogCGPoint(@"pointIsInsideResponsiveBounds (point) >> ", point);
  NSLogCGRect(@"pointIsInsideResponsiveBounds (bound) >> ", self.responsiveBounds.bounds);
  //@@CONVERTPOINT
  CGPoint localPoint = [self.responsiveBounds convertPoint:point fromView:nil];
  BOOL inside = [self.responsiveBounds pointInside:localPoint withEvent:nil];
  printf((inside ? "yes\n" : "no\n"));
  return inside;
  /*if (point.x > self.responsiveBounds.origin.x && point.x < (self.responsiveBounds.origin.x + self.responsiveBounds.size.width)
   && point.y > self.responsiveBounds.origin.y && point.y < (self.responsiveBounds.origin.y + self.responsiveBounds.size.height))
   return YES;
   else return NO;*/
}




#pragma mark- Entry decision handlers

- (void) acceptDraggableObject:(SEDraggable *)draggable
                   entryMethod:(SEDraggableLocationEntryMethod)entryMethod
                      animated:(BOOL)animated {
  
  // convert 'center' over to the receiver view's coordinate system in advance
  CGPoint draggableCenterInWindowCoords = [draggable getCenterInWindowCoordinates];
  CGPoint draggableCenterInReceiverCoords = [self convertPoint:draggableCenterInWindowCoords fromView:nil];
  draggable.center = draggableCenterInReceiverCoords;

  // @@TODO: this will cause retain cycles unless one side of the relationship is weak
  [self.containedObjects addObject:draggable];
  draggable.previousLocation = draggable.currentLocation;
  draggable.currentLocation = self;
  
  // add the draggable to its new parent view
  [self addSubview:draggable];
  
  CGPoint destinationPointInWindowCoords = [self getAcceptableLocationForDraggableObject:draggable
                                                     inPosition:SEDraggableLocationPositionDetermineAutomatically];
  CGPoint destinationPointInLocalCoords = [self convertPoint:destinationPointInWindowCoords fromView:nil];
  
  __block SEDraggableLocation *myself = self;
  __block SEDraggable *blockDraggable = draggable;
  void (^completionBlock)(BOOL) = ^(BOOL finished) {
    if (myself.shouldKeepObjectsArranged)
      [myself recalculateAllObjectPositions];
    
    // notify the draggable
    if ([blockDraggable respondsToSelector:@selector(draggableLocation:didAllowEntry:animated:)])
      [blockDraggable draggableLocation:myself didAllowEntry:entryMethod animated:animated];
    
    // notify my delegate
    if ([myself.delegate respondsToSelector:@selector(draggableLocation:didAcceptObject:entryMethod:)])
      [myself.delegate draggableLocation:myself didAcceptObject:blockDraggable entryMethod:entryMethod];
  };
  
  if (animated) {
    [draggable snapCenterToPoint:destinationPointInLocalCoords animated:animated completion:completionBlock];
  }
  else {
    completionBlock(YES);
  }
}

- (void) refuseDraggableObject:(SEDraggable *)draggable
                   entryMethod:(SEDraggableLocationEntryMethod)entryMethod
                      animated:(BOOL)animated {
  
  // notify the draggable
  [draggable draggableLocation:self didRefuseEntry:entryMethod animated:animated];
  
  // notify delegate
  if ([self.delegate respondsToSelector:@selector(draggableLocation:didRefuseObject:entryMethod:)])
    [self.delegate draggableLocation:self didRefuseObject:draggable entryMethod:entryMethod];
}

- (void) removeDraggableObject:(SEDraggable *)draggable {
  if (draggable.currentLocation == self) {
    draggable.previousLocation = draggable.currentLocation;
    draggable.currentLocation = nil;
  }
  
  [self.containedObjects removeObject:draggable];
  if (draggable.superview == self)
    [draggable removeFromSuperview];
  
  if ([self.delegate respondsToSelector:@selector(draggableObject:wasRemovedFromLocation:)])
    [self.delegate draggableObject:draggable wasRemovedFromLocation:self];

  if (self.shouldKeepObjectsArranged)
    [self recalculateAllObjectPositions];
}



#pragma mark- NSCoding

- (void)encodeWithCoder:(NSCoder *)encoder {
  [super encodeWithCoder:encoder];
  [encoder encodeFloat:self.objectWidth forKey:kOBJECT_WIDTH_KEY];
  [encoder encodeFloat:self.objectHeight forKey:kOBJECT_HEIGHT_KEY];
  [encoder encodeFloat:self.marginLeft forKey:kMARGIN_LEFT_KEY];
  [encoder encodeFloat:self.marginRight forKey:kMARGIN_RIGHT_KEY];
  [encoder encodeFloat:self.marginTop forKey:kMARGIN_TOP_KEY];
  [encoder encodeFloat:self.marginBottom forKey:kMARGIN_BOTTOM_KEY];
  [encoder encodeFloat:self.marginBetweenX forKey:kMARGIN_BETWEEN_X_KEY];
  [encoder encodeFloat:self.marginBetweenY forKey:kMARGIN_BETWEEN_Y_KEY];
  [encoder encodeFloat:self.randomArrangementOffsetMultiplier forKey:kRANDOM_ARRANGEMENT_OFFSET_MULTIPLIER_KEY];
  [encoder encodeObject:self.responsiveBounds forKey:kRESPONSIVE_BOUNDS_KEY];
  [encoder encodeObject:self.objectGutterBounds forKey:kOBJECT_GUTTER_BOUNDS_KEY];
  [encoder encodeBool:self.shouldAcceptDroppedObjects forKey:kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY];
  [encoder encodeBool:self.shouldKeepObjectsArranged forKey:kSHOULD_AUTOMATICALLY_RECALCULATE_OBJECT_POSITIONS_KEY];
  [encoder encodeBool:self.shouldAnimateObjectAdjustments forKey:kSHOULD_ANIMATE_OBJECT_ADJUSTMENTS_KEY];
  [encoder encodeFloat:self.animationDuration forKey:kANIMATION_DURATION_KEY];
  [encoder encodeFloat:self.animationDelay forKey:kANIMATION_DELAY_KEY];
#warning //ivar named: _animationOptions  and of type: UIViewAnimationOptions -- TYPE_NOT_SUPPORTED
#warning //[encoder encodeType(?):self.animationOptions forKey:kANIMATION_OPTIONS_KEY];
  [encoder encodeBool:self.fillHorizontallyFirst forKey:kFILL_HORIZONTALLY_FIRST_KEY];
  [encoder encodeBool:self.allowRows forKey:kALLOW_ROWS_KEY];
  [encoder encodeBool:self.allowColumns forKey:kALLOW_COLUMNS_KEY];
  [encoder encodeObject:self.delegate forKey:kDELEGATE_KEY];
  [encoder encodeObject:self.containedObjects forKey:kCONTAINED_OBJECTS_KEY];
}

- (id)initWithCoder:(NSCoder *)decoder {
  self = [super initWithCoder:decoder];
  if (self) {
    [self defaultAllOwnProperties];
    if ([decoder containsValueForKey:kOBJECT_WIDTH_KEY])
      self.objectWidth = [decoder decodeFloatForKey:kOBJECT_WIDTH_KEY];
    if ([decoder containsValueForKey:kOBJECT_HEIGHT_KEY])
      self.objectHeight = [decoder decodeFloatForKey:kOBJECT_HEIGHT_KEY];
    if ([decoder containsValueForKey:kMARGIN_LEFT_KEY])
      self.marginLeft = [decoder decodeFloatForKey:kMARGIN_LEFT_KEY];
    if ([decoder containsValueForKey:kMARGIN_RIGHT_KEY])
      self.marginRight = [decoder decodeFloatForKey:kMARGIN_RIGHT_KEY];
    if ([decoder containsValueForKey:kMARGIN_TOP_KEY])
      self.marginTop = [decoder decodeFloatForKey:kMARGIN_TOP_KEY];
    if ([decoder containsValueForKey:kMARGIN_BOTTOM_KEY])
      self.marginBottom = [decoder decodeFloatForKey:kMARGIN_BOTTOM_KEY];
    if ([decoder containsValueForKey:kMARGIN_BETWEEN_X_KEY])
      self.marginBetweenX = [decoder decodeFloatForKey:kMARGIN_BETWEEN_X_KEY];
    if ([decoder containsValueForKey:kMARGIN_BETWEEN_Y_KEY])
      self.marginBetweenY = [decoder decodeFloatForKey:kMARGIN_BETWEEN_Y_KEY];
    if ([decoder containsValueForKey:kRANDOM_ARRANGEMENT_OFFSET_MULTIPLIER_KEY])
      self.randomArrangementOffsetMultiplier = [decoder decodeFloatForKey:kRANDOM_ARRANGEMENT_OFFSET_MULTIPLIER_KEY];
    if ([decoder containsValueForKey:kRESPONSIVE_BOUNDS_KEY])
      self.responsiveBounds = [decoder decodeObjectForKey:kRESPONSIVE_BOUNDS_KEY];
    if ([decoder containsValueForKey:kOBJECT_GUTTER_BOUNDS_KEY])
      self.objectGutterBounds = [decoder decodeObjectForKey:kOBJECT_GUTTER_BOUNDS_KEY];
    if ([decoder containsValueForKey:kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY])
      self.shouldAcceptDroppedObjects = [decoder decodeBoolForKey:kSHOULD_ACCEPT_DROPPED_OBJECTS_KEY];
    if ([decoder containsValueForKey:kSHOULD_AUTOMATICALLY_RECALCULATE_OBJECT_POSITIONS_KEY])
      self.shouldKeepObjectsArranged = [decoder decodeBoolForKey:kSHOULD_AUTOMATICALLY_RECALCULATE_OBJECT_POSITIONS_KEY];
    if ([decoder containsValueForKey:kSHOULD_ANIMATE_OBJECT_ADJUSTMENTS_KEY])
      self.shouldAnimateObjectAdjustments = [decoder decodeBoolForKey:kSHOULD_ANIMATE_OBJECT_ADJUSTMENTS_KEY];
    if ([decoder containsValueForKey:kANIMATION_DURATION_KEY])
      self.animationDuration = [decoder decodeFloatForKey:kANIMATION_DURATION_KEY];
    if ([decoder containsValueForKey:kANIMATION_DELAY_KEY])
      self.animationDelay = [decoder decodeFloatForKey:kANIMATION_DELAY_KEY];
#warning //ivar named: animationOptions and of type: UIViewAnimationOptions -- TYPE_NOT_SUPPORTED 
#warning //[self setAnimationOptions:[decoder decodeType(?)ForKey:kANIMATION_OPTIONS_KEY]];
    if ([decoder containsValueForKey:kFILL_HORIZONTALLY_FIRST_KEY])
      self.fillHorizontallyFirst = [decoder decodeBoolForKey:kFILL_HORIZONTALLY_FIRST_KEY];
    if ([decoder containsValueForKey:kALLOW_ROWS_KEY])
      self.allowRows = [decoder decodeBoolForKey:kALLOW_ROWS_KEY];
    if ([decoder containsValueForKey:kALLOW_COLUMNS_KEY])
      self.allowColumns = [decoder decodeBoolForKey:kALLOW_COLUMNS_KEY];
    if ([decoder containsValueForKey:kDELEGATE_KEY])
      self.delegate = [decoder decodeObjectForKey:kDELEGATE_KEY];
    if ([decoder containsValueForKey:kCONTAINED_OBJECTS_KEY])
      self.containedObjects = [decoder decodeObjectForKey:kCONTAINED_OBJECTS_KEY];
  }
  return self;
}

- (id)copyWithZone:(NSZone *)zone {
    id theCopy = [[[self class] allocWithZone:zone] initWithFrame:self.frame];  // use designated initializer

    [theCopy setObjectWidth:self.objectWidth];
    [theCopy setObjectHeight:self.objectHeight];
    [theCopy setMarginLeft:self.marginLeft];
    [theCopy setMarginRight:self.marginRight];
    [theCopy setMarginTop:self.marginTop];
    [theCopy setMarginBottom:self.marginBottom];
    [theCopy setMarginBetweenX:self.marginBetweenX];
    [theCopy setMarginBetweenY:self.marginBetweenY];
    [theCopy setRandomArrangementOffsetMultiplier:self.randomArrangementOffsetMultiplier];
    [theCopy setResponsiveBounds:self.responsiveBounds];
    [theCopy setObjectGutterBounds:self.objectGutterBounds];
    [theCopy setShouldAcceptDroppedObjects:self.shouldAcceptDroppedObjects];
//    [theCopy setShouldAutomaticallyRecalculateObjectPositions:self.shouldKeepObjectsArranged];
    [theCopy setShouldAnimateObjectAdjustments:self.shouldAnimateObjectAdjustments];
    //[theCopy setAnimationDuration:self.animationDuration];
    [theCopy setAnimationDelay:self.animationDelay];
    [theCopy setAnimationOptions:self.animationOptions];
    [theCopy setFillHorizontallyFirst:self.fillHorizontallyFirst];
    [theCopy setAllowRows:self.allowRows];
    [theCopy setAllowColumns:self.allowColumns];
    //[theCopy setDelegate:[self.delegate copy]];
    [theCopy setContainedObjects:[self.containedObjects copy]];

    return theCopy;
}
@end
