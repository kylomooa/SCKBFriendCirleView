//
//  KBFriendCirleView.m
//  friendCirle
//
//  Created by kangbing on 16/6/17.
//  Copyright © 2016年 kangbing. All rights reserved.
//

#import "KBFriendCirleView.h"
#import "UIView+Extension.h"
#import "SDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "YYWebImage.h"

#define kMarGin 6

@interface KBFriendCirleView ()<SDPhotoBrowserDelegate>

@property (nonatomic, strong) NSArray *imageViewsArray;

@end

@implementation KBFriendCirleView


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    NSMutableArray *temp = [NSMutableArray new];
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    for (int i = 0; i < 9; i++) {
        UIImageView *imageView = [UIImageView new];
        imageView.backgroundColor = [UIColor clearColor];
        [self addSubview:imageView];
        imageView.userInteractionEnabled = YES;
        imageView.tag = i;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        [temp addObject:imageView];
    }
    
    self.imageViewsArray = [temp copy];
}

-(void)setThumbnailImage:(NSArray *)thumbnailImage{
    _thumbnailImage = thumbnailImage;
    
    if (_thumbnailImage.count > 9 ) {
        return;  // 大于9 , 就不显示, 必须小于9张
    }
    
    for (long i = _thumbnailImage.count; i < self.imageViewsArray.count; i++) {
        UIImageView *imageView = [self.imageViewsArray objectAtIndex:i];
        // 5个地址, 小于9个, 后面的全部隐藏
        imageView.hidden = YES;
    }
    
    //  如果是0个地址, 就不显示
    if (_thumbnailImage.count == 0) {
        self.height = 0;
        
        return;
    }
    
    // 根据图片数量订item的宽高
    CGFloat itemW = [self itemWidthForPicPathArray:_thumbnailImage];
    CGFloat itemH = 0;
    if (_thumbnailImage.count == 1) {  // 如果是一张
        
        itemH = itemW ;
        
    } else {
        
        // 正方形
        itemH = itemW;
    }
    
    // 返回多少列
    long perRowItemCount = [self perRowItemCountForPicPathArray:_thumbnailImage];
    CGFloat margin = kMarGin;
    
    [_thumbnailImage enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        long columnIndex = idx % perRowItemCount;
        long rowIndex = idx / perRowItemCount;
        UIImageView *imageView = [_imageViewsArray objectAtIndex:idx];
        
        imageView.hidden = NO;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        // 显示的imageView赋值
        //        [imageView yy_setImageWithURL:[NSURL URLWithString:obj] options:YYWebImageOptionProgressive];
        //        [imageView sd_setImageWithURL:[NSURL URLWithString:obj]];
        imageView.frame = CGRectMake(columnIndex * (itemW + margin), rowIndex * (itemH + margin), itemW, itemH);
                [imageView yy_setImageWithURL:[NSURL URLWithString:obj]  placeholder:[SCTools createImageWithColor:WEBRBGCOLOR(0xEEEEEE) withRect:imageView.bounds] options:YYWebImageOptionSetImageWithFadeAnimation completion:nil];
//        [imageView setImageWithURL:[NSURL URLWithString:obj] placeholderImage:[SCTools createImageWithColor:WEBRBGCOLOR(0xEEEEEE) withRect:imageView.bounds]];
        
    }];
    
    
    // 这个view的宽和高
    CGFloat w = perRowItemCount * itemW + (perRowItemCount - 1) * margin;
    int columnCount = ceilf(_thumbnailImage.count * 1.0 / perRowItemCount);
    CGFloat h = columnCount * itemH + (columnCount - 1) * margin;
    self.width = w;
    self.height = h;
    
}

#pragma mark - private actions

- (void)tapImageView:(UITapGestureRecognizer *)tap
{
    UIView *imageView = tap.view;
    SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
    browser.currentImageIndex = imageView.tag;
    browser.sourceImagesContainerView = self;
    browser.imageCount = self.thumbnailImage.count;
    browser.delegate = self;
    [browser show];
}

#pragma mark 返回item的宽
- (CGFloat)itemWidthForPicPathArray:(NSArray *)array
{
    if (array.count == 1) {
//        return [UIScreen mainScreen].bounds.size.width / 2 ;
        return 250;
    } else {
//        CGFloat w = [UIScreen mainScreen].bounds.size.width > 320 ? 110 : 90;
        
        CGFloat w = ([UIScreen mainScreen].bounds.size.width - 3 * kMarGin - 2*20)/3 ;
        return w;
    }
}

#pragma mark 返回列数
- (NSInteger)perRowItemCountForPicPathArray:(NSArray *)array
{
    if (array.count <= 3) {
        return array.count;
        
    } else if (array.count <= 4) {
        
        return 2;
    } else {
        return 3;
    }
}


#pragma mark - SDPhotoBrowserDelegate
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *imageName = self.imageUrls[index];
    NSURL *url = [NSURL URLWithString:imageName];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = self.subviews[index];
    return imageView.image;
}


@end
