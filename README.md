# // draggable

![Screenshot](https://github.com/brynbellomy/iOS-DragAndDrop/raw/master/SEDraggableDemo/screenshot.png)

# wtf is this

It's currently not possible to use Cocoa's drag-and-drop classes and protocols
in iPhone/iPad apps.  This really sucks.  Implementing a
__UIPanGestureRecognizer__ is really fucking boring.

__SEDraggable__ is a subclass of __UIView__ that fills this void, making it
easy to add drag-and-drop functionality to any __UIView__ in your application.

# how

**Note: check out the example project.  It's a pain to explain code in English,
and I didn't try very hard.**

Add the source files to your Xcode project.  Import the `SEDraggable.h` and
`SEDraggableLocation.h` headers.

```objective-c
#import "SEDraggable.h"
#import "SEDraggableLocation.h"
```

To initialize an instance of __SEDraggable__, you'll probably want to use one
of these:

```objective-c
- (id) initWithFrame:(CGRect)frame;
- (id) initWithImage:(UIImage *)image andSize:(CGSize)size;
- (id) initWithImageView:(UIImageView *)imageView;
```

```objective-c
// set up the UIImageView that will be used as the visible component of our draggable element
UIImage *image = [[UIImage alloc] initWithContentsOfFile:@"someFile.png"];
UIImageView *imageView = [UIImageView alloc] initWithImage:image];

// initialize the draggable element itself
SEDraggable *draggableView = [SEDraggable initWithImageView:imageView];
```

Of course, as mentioned, there are simpler init methods to suit different
needs.

```objective-c
CGRect frame = CGRectMake(10, 10, 100, 100);
SEDraggable *draggableView = [SEDraggable initWithFrame:frame];
// ... or ...
SEDraggable *draggableView = [SEDraggable init];
```

# using SEDraggableLocation's automatic behaviors

__SEDraggableLocation__ allows you to easily switch between certain automatic
behaviors -- for example, visually arranging a set of __SEDraggable__ objects
so that they don't appear to be haphazardly strewn about, or yanking an
__SEDraggable__ back to its original location when a drag-and-drop operation is
unsuccessful for some reason.

Try something like the following.  Run the code and then play around with the
draggable objects to see how they behave.

```objective-c
SEDraggable *draggableView = ...

// create the SEDraggableLocation to represent the draggable element's starting point
CGRect homeLocationBounds = CGRectMake(10, 10, 100, 100);
CGRect otherLocationBounds = CGRectMake(200, 200, 100, 100);
SEDraggableLocation *homeLocation = [SEDraggableLocation initWithBounds:homeLocationBounds];
SEDraggableLocation *otherLocation = [SEDraggableLocation initWithBounds:otherLocationBounds];

// configure a whole litany of options
otherLocation.objectWidth = draggableView.frame.size.width;
otherLocation.objectHeight = draggableView.frame.size.height;
otherLocation.marginLeft = 3;
otherLocation.marginRight = 3;
otherLocation.marginTop = 3;
otherLocation.marginBottom = 3;
otherLocation.marginBetweenX = 3;
otherLocation.marginBetweenY = 3;
otherLocation.shouldAcceptDroppedObjects = YES;
otherLocation.shouldAutomaticallyRecalculateObjectPositions = YES;
otherLocation.shouldAnimateObjectAdjustments = YES;
otherLocation.animationDuration = 0.5f;
otherLocation.animationDelay = 0.0f;
otherLocation.animationOptions = UIViewAnimationOptionBeginFromCurrentState;
otherLocation.fillHorizontallyFirst = YES; // NO makes it fill rows first
otherLocation.allowRows = YES;
otherLocation.allowColumns = YES;

// add the draggable object, or maybe even several
draggableView.homeLocation = homeLocation;
[draggableView addAllowedDropLocation:homeLocation];
[draggableView addAllowedDropLocation:otherLocation];
[homeLocation addDraggableObject:draggableView];
```

# SEDraggableLocation bounds

You can even specify different boundaries for where an __SEDraggableLocation__
will _accept_ dropped objects and where it will _place_ them.  And these two
regions don't even have to be contiguous in any way!  It's kind of cool to
watch what happens if they're not -- when you drop your draggable objects, they
fly from one area of the screen to another automatically.

These are the two properties you'll want to look at if you want to configure
this kind of behavior:

```objective-c
@property (nonatomic, readwrite) CGRect responsiveBounds;
@property (nonatomic, readwrite) CGRect objectGutterBounds;
```

# delegate messages

You can specify a delegate that will be notified of pertinent drag-and-drop
events.  Delegates of __SEDraggable__ and __SEDraggableLocation__ objects must
conform either to the __SEDraggableEventResponder__ protocol or the
__SEDraggableLocationEventResponder__ protocol, respectively.  The two
protocols define the following messages, _all of which are optional_:

## @protocol SEDraggableEventResponder

```objective-c
- (void) draggableObjectDidMove:(SEDraggable *)object;
- (void) draggableObjectDidStopMoving:(SEDraggable *)object;

- (void) draggableObject:(SEDraggable *)object didMoveWithinLocation:(SEDraggableLocation *)location;
- (void) draggableObject:(SEDraggable *)object didStopMovingWithinLocation:(SEDraggableLocation *)location;

- (void) draggableObjectWillSnapBackToHomeFrame:(SEDraggable *)object;
- (void) draggableObjectDidEndSnappingBackToHomeFrame:(SEDraggable *)object;

- (void) draggableObject:(SEDraggable *)object didBeginSnapAnimationWithID:(NSString *)animationID andContext:(void *)context;
- (void) draggableObject:(SEDraggable *)object didEndSnapAnimationWithID:(NSString *)animationID andContext:(void *)context;
```

## @protocol SEDraggableLocationEventResponder

```objective-c
- (void) draggableLocation:(SEDraggableLocation *)location didAcceptDroppedObject:(SEDraggable *)object;
- (void) draggableLocation:(SEDraggableLocation *)location didRefuseDroppedObject:(SEDraggable *)object;
- (void) draggableObject:(SEDraggable *)object wasRemovedFromLocation:(SEDraggableLocation *)location;
```

# authors and contributors

bryn austin bellomy <<bryn@signals.io>>

# license (MIT license)

Copyright (c) 2012 bryn austin bellomy // [robot bubble bath LLC](http://robotbubblebath.com/)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
