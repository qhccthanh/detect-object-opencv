//
//  PickTemplateViewController.h
//  LogoDetector
//
//  Created by Quach Ha Chan Thanh on 11/17/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CACHE_PATH NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true).firstObject

@interface PickTemplateViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *templateCollectionView;

@end
