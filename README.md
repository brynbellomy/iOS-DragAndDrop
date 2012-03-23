# SEDraggable

## wtf is this

It's currently not possible to use Cocoa's drag-and-drop classes and protocols
in iPhone/iPad apps.  This really sucks.  Implementing a UIPanGestureRecognizer
is really fucking boring.

__SEDraggable__ is a subclass of UIView that fills this void, making it easy to
add drag-and-drop functionality to any UIView in your application.

## How to use

Add the source files to your Xcode project.  Import the `SEDraggable.h` header.

```objective-c
#import "SEDraggable.h"
```

To initialize an instance of __SEDraggable__, you'll probably want to use

```objective-c
- (id) initWithImageView:(UIImageView *)imageView andHomeLocation:(SEDraggableLocation *)location;
```

### But I don't want to use a UIImageView

Go fork yourself (actually, pull requests are more than welcome, so please do). 
I do plan on refactoring this to be more general -- it's just one of those
thankless jobs that doesn't pay, and therefore is biding its time on the
backburner.  I promise you -- it's not lonely back there, not in the least.

You can work around this after you're done initializing your __SEDraggable__
object by simply calling __SEDraggable__'s inherited `addSubview:` method just
as with any other UIView.  Feel free to pass any kind of UIView objects or
UIView subclass objects to that method -- it shouldn't bork anything.

### And what's that home location parameter?

The `homeLocation` property is only really relevant when you want your
draggable elements to automatically snap back to where they began if they
aren't dropped in an allowed location (represented by the
__SEDraggableLocation__ class).  If you don't need this functionality, simply
create an instance of __SEDraggableLocation__ to represent where your draggable
element should first appear.

```objective-c
// create the SEDraggableLocation to represent the draggable element's starting point
CGRect initialLocation = CGRectMake(10, 10, 100, 100);
SEDraggableLocation *homeLocation = [SEDraggableLocation initWithBounds:initialLocation];

// set up the UIImageView that will be used as the visible component of our draggable element
UIImage *image = [[UIImage alloc] initWithContentsOfFile:@"someFile.png"];
UIImageView *imageView = [UIImageView alloc] initWithImage:image];

// finally, initialize the draggable element itself
SEDraggable *draggableView = [SEDraggable initWithImageView:imageView andHomeLocation:homeLocation];
```

## Delegate notifications

You can specify a delegate that will be notified of pertinent drag-and-drop
events.  Delegates of __SEDraggable__ and __SEDraggableLocation__ objects must
conform either to the __SEDraggableEventResponder__ protocol or the
__SEDraggableLocationEventResponder__ protocol, respectively.  The two
protocols define the following messages, _all of which are optional_:

### @protocol SEDraggableEventResponder

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

### @protocol SEDraggableLocationEventResponder

```objective-c
- (void) draggableLocation:(SEDraggableLocation *)location didAcceptDroppedObject:(SEDraggable *)object;
- (void) draggableLocation:(SEDraggableLocation *)location didRefuseDroppedObject:(SEDraggable *)object;
- (void) draggableObject:(SEDraggable *)object wasRemovedFromLocation:(SEDraggableLocation *)location;
```

# Authors and contributors

bryn austin bellomy <<bryn@signals.io>>

# License (MIT license)

Copyright (c) 2012 bryn austin bellomy, http://signals.io/

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
