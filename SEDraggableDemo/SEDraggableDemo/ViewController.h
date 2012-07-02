//
//  ViewController.h
//  SEDraggableDemo
//
//  Created by bryn austin bellomy on 7/2/12.
//  Copyright (c) 2012 robot bubble bath LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#define UIImageWithBundlePNG(x) ([UIImage imageWithContentsOfFile: [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:(x)] ofType:@"png"]])

@interface ViewController : UIViewController

@end
