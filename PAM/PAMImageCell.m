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

@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, assign) int currentImageIdx;

@end

@implementation PAMImageCell

- (instancetype)initWithIndex:(int)index
{
    self = [super init];
    if (self) {
        _index = index;
        [self setupImageNames];
        [self shuffleImage];
    }
    return self;
}

- (void)setupImageNames
{
    NSMutableArray *names = [NSMutableArray arrayWithCapacity:IMAGE_COUNT];
    for (int i = 0; i < IMAGE_COUNT; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%d_%d", self.index+1, i+1];
        [names addObject:imageName];
    }
    self.imageNames = names;
    self.currentImageIdx = IMAGE_COUNT + 1; // ensure random first image
    
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
    
    NSString *name = self.imageNames[newIdx];
    UIImage *image = [UIImage imageNamed:name];
    [self setBackgroundImage:image forState:UIControlStateNormal];
}

- (NSString *)currentImageID
{
    return [NSString stringWithFormat:@"%d_%d", self.index+1, self.currentImageIdx+1];
}

@end
