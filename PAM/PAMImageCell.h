//
//  PAMImageCell.h
//  PAM
//
//  Created by Charles Forkish on 11/22/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAMImageCell : UIButton

@property (nonatomic, readonly) int index;
@property (nonatomic, readonly) NSString *currentImageID;

- (instancetype)initWithIndex:(int)index;
- (void)shuffleImage;

@end
