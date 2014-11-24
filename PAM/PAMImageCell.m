//
//  PAMImageCell.m
//  PAM
//
//  Created by Charles Forkish on 11/22/14.
//  Copyright (c) 2014 Charlie Forkish. All rights reserved.
//

#import "PAMImageCell.h"

#define IMAGE_COUNT 3

@interface PAMImageCell ()

@property (nonatomic, strong) NSArray *images;
@property (nonatomic, assign) int currentImageIdx;

@end

@implementation PAMImageCell

- (instancetype)initWithIndex:(int)index
{
    self = [super init];
    if (self) {
        self.index = index;
        [self setupImages];
        [self shuffleImage];
    }
    return self;
}

- (void)setupImages
{
    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:IMAGE_COUNT];
    for (int i = 0; i < IMAGE_COUNT; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d_%d", self.index+1, i+1];
        UIImage *image = [UIImage imageNamed:imageName];
        [imgs addObject:image];
    }
    self.images = imgs;
    self.currentImageIdx = IMAGE_COUNT + 1;
    
    UIImage *check = [UIImage imageNamed:@"check_small"];
    [self setImage:check forState:UIControlStateSelected];
    
}

- (void)shuffleImage
{
    int newIdx = self.currentImageIdx;
    while (newIdx == self.currentImageIdx) {
        newIdx = arc4random() % 3;
    }
    self.currentImageIdx = newIdx;
    
    UIImage *image = self.images[newIdx];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

@end
