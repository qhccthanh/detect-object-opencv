//
//  ReportViewController.h
//  LogoDetector
//
//  Created by Quach Ha Chan Thanh on 11/18/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReportViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *sceneImageView;
@property (weak, nonatomic) IBOutlet UIImageView *templateImageView;
@property (weak, nonatomic) IBOutlet UITableView *reportTableView;


@property UIImage* templateSelected;


@end
