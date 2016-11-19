//
//  PickTemplateViewController.m
//  LogoDetector
//
//  Created by Quach Ha Chan Thanh on 11/17/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#import "PickTemplateViewController.h"
#import "SelectionViewController.h"

@interface PickTemplateViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property NSMutableArray<NSArray<UIImage *> *> *templateTypeArray;
@property NSMutableArray<NSString *> *headerTypeArray;

@end

@implementation PickTemplateViewController

- (void)viewDidLoad {
    
    // Do any additional setup after loading the view.
    _templateTypeArray = [[NSMutableArray alloc] init];
    
    
    // Add array UIImage for section HCN Vertical
    [_templateTypeArray addObject: @[
                                     [UIImage imageNamed:@"LyZalo.jpg"],
                                     [UIImage imageNamed:@"Olong.jpg"],
                                     ]
     ];
    
    // Add array UIImage for section HCN Horizontal
    [_templateTypeArray addObject: @[
                                     [UIImage imageNamed:@"IP4.jpg"],
                                     [UIImage imageNamed:@"Vi.jpg"],
                                     ]
     ];
    
    // Add array UIImage for section HV
    [_templateTypeArray addObject: @[
                                     [UIImage imageNamed:@"Quat.jpeg"],
                                  
                                     ]
     ];
    
    // Add header Section
    _headerTypeArray = [[NSMutableArray alloc] initWithObjects:@"Hình chữ nhật đứng", @"Hình chữ nhật ngang", @"Hình vuông", nil];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _templateTypeArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _templateTypeArray[section].count + 1 ;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell;
    NSString *reuseIdentifierCell = indexPath.row == 0 ? @"HeaderCell" : @"ImageCell";
    
    cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifierCell forIndexPath:indexPath];
    
    UIImageView *imageView = [cell.contentView viewWithTag:101];
    if (imageView) {
        imageView.image =  _templateTypeArray[indexPath.section][indexPath.row - 1];
    }
    
    if (indexPath.row == 0) {
        UILabel *label = [cell.contentView viewWithTag:102];
        if (label) {
            label.text = _headerTypeArray[indexPath.section];
        }
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row != 0) {
        SelectionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectionViewController"];
        
        if (vc) {
            vc.templateSelected = _templateTypeArray[indexPath.section][indexPath.row - 1];
            [self presentViewController:vc animated:true completion:nil];
        }
    }
    
    return false;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        return CGSizeMake(collectionView.frame.size.width, 20);
    }
    
    return CGSizeMake(collectionView.frame.size.width * 0.45, 250);
}


@end
