//
//  ReportViewController.m
//  LogoDetector
//
//  Created by Quach Ha Chan Thanh on 11/18/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#import "ReportViewController.h"
#import "ImageUtils.h"
#import "CameraViewController.h"
#import "UIImage+Orientation.h"
#import "MLManager.h"
#import "ImageUtils.h"
#import "GeometryUtil.h"

#import "Features2D-Homo.hpp"



@interface ReportViewController () <UITableViewDelegate, UITableViewDataSource>

@property NSMutableArray    *templateScalesArray;
@property UIImage           *currentSceneImage;
@property NSInteger         sceneKeyPoint;
@property cv::Mat           currentSceneImageMat;
@property dispatch_queue_t  imageProcessQueue;
@property map<string,Mat>   cacheMatMap;
@property NSMutableDictionary *outputDictionary;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.templateImageView.image = self.templateSelected;
    
    NSArray *widthScaleArray = @[@(150),@(200),@(250),@(300),@(350),@(450)];
    _templateScalesArray = [[NSMutableArray alloc] init];
    _outputDictionary = [NSMutableDictionary new];
    
    for (NSNumber *width in widthScaleArray) {
        
        UIImage *scaleImage = [ImageUtils imageWithImage:self.templateSelected scaledToWidth:[width floatValue]];
        [_templateScalesArray addObject:scaleImage];
    }
    
    // Add base image
    //[_templateScalesArray addObject:self.templateSelected];
    
    _imageProcessQueue = dispatch_queue_create("Processing Image", 0);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeScene:(id)sender {
    
    CameraViewController *cameraVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CameraViewController"];
    
    if (cameraVC) {
        cameraVC.photoHandler = (^(UIImage* image){
            
            _sceneImageView.image = image;
            _currentSceneImage = image;
            _currentSceneImageMat = [ImageUtils cvMatFromUIImage: image];
            _sceneKeyPoint = (getKeyPoint(_currentSceneImageMat)).size();
            _cacheMatMap.clear();
            
            [cameraVC dismissViewControllerAnimated:true completion:nil];
            
            
            [_reportTableView reloadData];
        });
        
        [self presentViewController:cameraVC animated:true completion:nil];
    }
    
}

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:true completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _templateScalesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    
    UIImage *templateImage = [_templateScalesArray objectAtIndex:indexPath.row];
    cv::Mat templateImageMat = [ImageUtils cvMatFromUIImage: templateImage];
    
    // Assgin size Image
    UILabel *sizeLabel = (UILabel *)[cell.contentView viewWithTag:101];
    if (sizeLabel) {
        sizeLabel.text = [NSString stringWithFormat:@"T: W: %0.1f - H: %0.1f",templateImage.size.width, templateImage.size.height];
    }
    
    // Assign Infomation. Keypoint of template - key point scene - good match point
    UILabel *infomationLabel = (UILabel *)[cell.contentView viewWithTag:102];
    if (infomationLabel) {
        NSInteger templateKeyPoint = (getKeyPoint(templateImageMat)).size();
        infomationLabel.text = [NSString stringWithFormat:
                                @"Template: KP: %ld - Scene KP: %ld"
                                ,(long)templateKeyPoint, (long)_sceneKeyPoint];
    }
    
    UIImageView *imageView = [(UIImageView *)cell.contentView viewWithTag:103];
    if (imageView) {
        imageView.image = nil;
    }
    
    if (_currentSceneImage) {
        
        string key = string([[NSString stringWithFormat:@"%d-%d",(int)templateImage.size.width,(int)templateImage.size.height] UTF8String]);
        
        
        if (_cacheMatMap.find(key) != _cacheMatMap.end()) {
            if (imageView) {
            
                imageView.image = [ImageUtils UIImageFromCVMat:_cacheMatMap[key]];
            }
            
            if (infomationLabel) {
                infomationLabel.text = [_outputDictionary valueForKey:[NSString stringWithUTF8String:key.c_str()]];
            }
        } else {
            
            __block NSInteger row = indexPath.row;
            __block string keyTemp = key;
            
            dispatch_async(_imageProcessQueue, ^{
                
                if (row == indexPath.row) {
                    string temp = "";
                    double currentTimer = [[NSDate alloc] init].timeIntervalSince1970;
                    
                    Mat resultMat = MatchingTemplateWithMultiScale(_currentSceneImageMat, templateImageMat, 0, temp );
                    
                   // dispatch_async(dispatch_get_main_queue(), ^{
//                        NSLog(@"Time: %f",);
                    //});
                    printf("\nTime: %f",[[NSDate alloc] init].timeIntervalSince1970 - currentTimer);
                    
                    _cacheMatMap.insert(pair<string, Mat>(keyTemp,resultMat));
                    [_outputDictionary setObject:[NSString stringWithUTF8String:temp.c_str()] forKey:[NSString stringWithUTF8String:keyTemp.c_str()]];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        if (imageView) {
                            imageView.image = [ImageUtils UIImageFromCVMat:resultMat];
                        }
                        
                        if (infomationLabel) {
                            infomationLabel.text = [NSString stringWithUTF8String:temp.c_str()];
                        }
                    });
                }
            });
        }
    }
    
    
    return cell;
}


@end
