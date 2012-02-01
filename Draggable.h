//
//  Draggable.h
//  RemoteIORecordPlayOut
//
//  Created by bryn austin bellomy on 10/23/11.
//  Copyright 2011 illumntr. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DraggableLocation, Draggable;

@protocol DraggableEventResponder

  - (void) draggableObjectDidMove:(Draggable *)object;
  - (void) draggableObjectDidStopMoving:(Draggable *)object;

  - (void) draggableObject:(Draggable *)object didMoveWithinLocation:(DraggableLocation *)location;
  - (void) draggableObject:(Draggable *)object didStopMovingWithinLocation:(DraggableLocation *)location;

  - (void) draggableObjectWillSnapBackToHomeFrame:(Draggable *)object;
  - (void) draggableObjectDidEndSnappingBackToHomeFrame:(Draggable *)object;

  - (void) draggableObject:(Draggable *)object didBeginSnapAnimationWithID:(NSString *)animationID andContext:(void *)context;
  - (void) draggableObject:(Draggable *)object didEndSnapAnimationWithID:(NSString *)animationID andContext:(void *)context; // it's up to the delegate to set draggable.currentLocation when the delegate initiates the animation and it's appropriate to do so

@end



@interface Draggable : NSObject <UIGestureRecognizerDelegate> {

  DraggableLocation *_homeLocation;
  DraggableLocation *_currentLocation;
  DraggableLocation *_previousLocation;
  NSArray *_droppableLocations;
  UIView *_holderView;
  UIPanGestureRecognizer *_panGestureRecognizer;
  BOOL _shouldSnapBackToHomeFrame;
  BOOL _isHidden;
  CGFloat firstX;
  CGFloat firstY;
  id <DraggableEventResponder> __unsafe_unretained _delegate;
  int _tag;
  
}

@property (nonatomic, readwrite, strong) UIView *holderView;
@property (nonatomic, readwrite, strong, getter = imageView) UIImageView *imageView;
@property (nonatomic, readwrite, strong) DraggableLocation *currentLocation;
@property (nonatomic, readwrite, strong) DraggableLocation *homeLocation;
@property (nonatomic, readwrite, strong) DraggableLocation *previousLocation;
@property (nonatomic, readwrite, strong) NSArray *droppableLocations;
@property (nonatomic, readwrite, unsafe_unretained) id <DraggableEventResponder> delegate;
@property (nonatomic, readwrite) BOOL isHidden;
@property (nonatomic, readwrite) BOOL shouldSnapBackToHomeFrame;
@property (nonatomic, readwrite) int tag;

- (id) initWithImage:(UIImage *)image andSize:(CGSize)size andHomeLocation:(DraggableLocation *)location;
- (void) handleDrag:(id)sender;
- (void) snapCenterToPoint:(CGPoint)point withAnimationID:(NSString *)animationID andContext:(void *)context;
- (void) snapBackToHomeFrame;
- (void) draggableLocationDidRefuseDrop:(DraggableLocation *)location;
- (void) iconSnapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

@end


