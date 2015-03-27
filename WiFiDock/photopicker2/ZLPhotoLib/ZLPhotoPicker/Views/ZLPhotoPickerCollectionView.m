//
//  PickerCollectionView.m
//  相机
//
//  Created by 张磊 on 14-11-11.
//  Copyright (c) 2014年 com.zixue101.www. All rights reserved.
//

#define MAX_COUNT 9 // 选择图片最大数默认是9

#import "ZLPhotoPickerCollectionView.h"
#import "ZLPhotoPickerCollectionViewCell.h"
#import "ZLPhotoPickerImageView.h"
#import "ZLPhotoPickerFooterCollectionReusableView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ZLPhotoAssets.h"

@interface ZLPhotoPickerCollectionView () <UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic , strong) ZLPhotoPickerFooterCollectionReusableView *footerView;

// 判断是否是第一次加载
@property (nonatomic , assign , getter=isFirstLoadding) BOOL firstLoadding;

@end

@implementation ZLPhotoPickerCollectionView

#pragma mark -getter
- (NSMutableArray *)selectsIndexPath{
    if (!_selectsIndexPath) {
        _selectsIndexPath = [NSMutableArray array];
    }
    return _selectsIndexPath;
}

#pragma mark -setter
- (void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout{
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        _selectAsstes = [NSMutableArray array];
    }
    return self;
}

#pragma mark -<UICollectionViewDataSource>
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZLPhotoPickerCollectionViewCell *cell = [ZLPhotoPickerCollectionViewCell cellWithCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    ZLPhotoPickerImageView *cellImgView = [[ZLPhotoPickerImageView alloc] initWithFrame:cell.bounds];
    cellImgView.contentMode = UIViewContentModeScaleAspectFill;
    cellImgView.clipsToBounds = YES;
    [cell.contentView addSubview:cellImgView];
    
    cellImgView.maskViewFlag = ([self.selectsIndexPath containsObject:@(indexPath.row)]);
    
    ZLPhotoAssets *asset = self.dataArray[indexPath.item];
    if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
        cellImgView.image = asset.thumbImage;
    }
    
    return cell;
}

-(void)selectAllFile
{
    for (int row = 0; row < self.dataArray.count; row++) {
        
        NSIndexPath *index = [NSIndexPath indexPathForRow:row inSection:0];
        
        [self collectionView:self didSelectItemAtIndexPath:index];
        
    }

}

#pragma mark - <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ZLPhotoPickerCollectionViewCell *cell = (ZLPhotoPickerCollectionViewCell *) [collectionView cellForItemAtIndexPath:indexPath];
    
    ZLPhotoAssets *asset = self.dataArray[indexPath.row];
    ZLPhotoPickerImageView *pickerImageView = [cell.contentView.subviews lastObject];
    // 如果没有就添加到数组里面，存在就移除
    if (pickerImageView.isMaskViewFlag) {
        [self.selectsIndexPath removeObject:@(indexPath.row)];
        [self.selectAsstes removeObject:asset];
    }else{
        // 1 判断图片数超过最大数或者小于1
        NSUInteger minCount = (self.minCount > MAX_COUNT || self.minCount < 1) ? MAX_COUNT :  self.minCount;
        
        if (self.selectsIndexPath.count >= minCount) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:[NSString stringWithFormat:@"最多只能选择%zd张图片",minCount] delegate:self cancelButtonTitle:nil otherButtonTitles:@"好的", nil];
            [alertView show];
            return ;
        }
        
        [self.selectsIndexPath addObject:@(indexPath.row)];
        [self.selectAsstes addObject:asset];
    }
    pickerImageView.maskViewFlag = ([pickerImageView isKindOfClass:[ZLPhotoPickerImageView class]]) && !pickerImageView.isMaskViewFlag;
    
    // 告诉代理现在被点击了!
    if ([self.collectionViewDelegate respondsToSelector:@selector(pickerCollectionViewDidSelected:)]) {
        [self.collectionViewDelegate pickerCollectionViewDidSelected:self];
    }
}

#pragma mark 底部View
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    ZLPhotoPickerFooterCollectionReusableView *reusableView = nil;
    if (kind == UICollectionElementKindSectionFooter) {
        ZLPhotoPickerFooterCollectionReusableView *footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FooterView" forIndexPath:indexPath];
        footerView.count = self.dataArray.count;
        reusableView = footerView;
        self.footerView = footerView;
    }else{
        
    }
    return reusableView;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    
    // 时间置顶的话
    if (self.status == ZLPickerCollectionViewShowOrderStatusTimeDesc) {
        if (!self.firstLoadding && self.contentSize.height > [[UIScreen mainScreen] bounds].size.height) {
            // 滚动到最底部（最新的）
            [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.dataArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
            // 展示图片数
            self.contentOffset = CGPointMake(self.contentOffset.x, self.contentOffset.y + 100);
            self.firstLoadding = YES;
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
