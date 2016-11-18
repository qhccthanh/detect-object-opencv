////////
// This sample is published as part of the blog article at www.toptal.com/blog 
// Visit www.toptal.com/blog and subscribe to our newsletter to read great posts
////////

//
//  CameraViewController.m
//  LogoDetector
//
//  Created by altaibayar tseveenbayar on 13/05/15.
//  Copyright (c) 2015 altaibayar tseveenbayar. All rights reserved.
//

#import "CameraViewController.h"
#import <opencv2/highgui/ios.h>
#import "UIImage+Orientation.h"
#import "MLManager.h"
#import "ImageUtils.h"
#import "GeometryUtil.h"

#import "Features2D-Homo.hpp"

#ifdef DEBUG
#import "FPS.h"
#endif

//this two values are dependant on defaultAVCaptureSessionPreset
#define W (480)
#define H (640)

@interface CameraViewController() 
{
    CvPhotoCamera *camera;
    BOOL started;
    
    NSMutableArray *images;
    NSUInteger count;
    
    BOOL flag;
    UIImage *basedObject;
    
    UIImageView *previewImage;
}

@end

@implementation CameraViewController

- (void) viewDidLoad
{
    [super viewDidLoad];
    flag = NO;
    //UI
    [_btn setTitle: @" " forState: UIControlStateNormal];
    
    previewImage = [[UIImageView alloc] initWithFrame:_img.frame];
    previewImage.contentMode = UIViewContentModeScaleAspectFit;
    previewImage.backgroundColor = [UIColor blackColor];

    //Camera
    camera = [[CvPhotoCamera alloc] initWithParentView: _img];
    camera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
    camera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetiFrame1280x720;
    camera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    camera.defaultFPS = 30;
//    camera.useAVCaptureVideoPreviewLayer = NO;

    // camera.grayscaleMode = NO;
    camera.delegate = self;

    started = NO;
    //_img.image = [UIImage imageNamed:@"scene1.jpg"];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    
    //[self test];
    [camera start];
    
    images = [[NSMutableArray alloc] init];
    
    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_water1.jpg"]]);
    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_water2.jpg"]]);
    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_water3.jpg"]]);
//    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_dep1.jpg"]]);
//    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_dep2.jpg"]]);
//    template_image.push_back([ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"object_dep3.jpg"]]);

//
//    [images addObject:[UIImage imageNamed:@"object_water.jpg"]];
//    [images addObject:[UIImage imageNamed:@"scene2.jpg"]];
//    [images addObject:[UIImage imageNamed:@"scene3.jpg"]];
//    [images addObject:[UIImage imageNamed:@"scene4.jpg"]];
//    [images addObject:[UIImage imageNamed:@"scene5.jpg"]];
//    [images addObject:[UIImage imageNamed:@"scene6.jpg"]];
//    [images addObject:[UIImage imageNamed:@"scene7.jpg"]];
//    
//    count = 0;
//    
//    Mat object = [ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"zalo_small.jpg"]];
//    Mat scene = [ImageUtils cvMatFromUIImage:[images objectAtIndex:count]];
//    _img.image = [ImageUtils UIImageFromCVMat: feature2D(object, scene)];
}

//- (void) test 
//{
//    UIImage *logo = [UIImage imageNamed: @"toptal logo"];    
//    cv::Mat image = [ImageUtils cvMatFromUIImage: logo];
//
//    //get gray image
//    cv::Mat gray;
//    cvtColor(image, gray, CV_BGRA2GRAY);
//    
//    //mser with maximum area is
//    std::vector<cv::Point> mser = [ImageUtils maxMser: &gray];
//    
//    //get 4 vertices of the maxMSER minrect
//    cv::RotatedRect rect = cv::minAreaRect(mser);    
//    cv::Point2f points[4];
//    rect.points(points);
//    
//    //normalize image
//    cv::Mat M = [GeometryUtil getPerspectiveMatrix: points toSize: rect.size];
//    cv::Mat normalizedImage = [GeometryUtil normalizeImage: &gray withTranformationMatrix: &M withSize: rect.size.width];
//
//    //get maxMser from normalized image
//    std::vector<cv::Point> normalizedMser = [ImageUtils maxMser: &normalizedImage];
//    
//    _img.backgroundColor = [UIColor greenColor];
//    _img.contentMode = UIViewContentModeCenter;
//    _img.image = [ImageUtils UIImageFromCVMat: normalizedImage];
//}
//
- (IBAction)btn_TouchUp:(id)sender 
{
    flag = NO;
    [camera takePicture];
//   // started = !started;
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)btn_TouchUp2:(id)sender
{
    if (previewImage.superview != nil) {
        [previewImage removeFromSuperview];
    }
    [camera start];
}

- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image {
    image = [image fixOrientation];
//    if (!flag) {
//        basedObject = image;
//        [camera stop];
//    }
//    else {
////        Mat object = [ImageUtils cvMatFromUIImage:[UIImage imageNamed:@"zalo.jpg"]];
//        Mat scene = [ImageUtils cvMatFromUIImage:image];
//        
//        
//       // id newimage = [ImageUtils UIImageFromCVMat: detectFeature2D_TemplateMatch(scene)];
//        //previewImage.image = newimage;
//        int indexTemplate = -1;
//        Rect_<int> nrect = detectFeature2D_TemplateMatch(scene, indexTemplate);
//        CGRect rect = CGRectMake(nrect.x, nrect.y, nrect.width, nrect.height);
//        
//        NSLog(@"%@", rect);
//        
//        [camera stop];
//        
//        if (indexTemplate != -1 && rect.size.height !=0 && rect.size.width != 0) {
//            previewImage.frame = _img.frame;
//            
//            rectangle(scene, nrect, Scalar::all(0), 2, 8, 0);
//            previewImage.image = [ImageUtils UIImageFromCVMat:scene];
//            
//            [self.view addSubview:previewImage];
//            
//            _img.image = nil;
//        }
//        
//    }
    if (_photoHandler) {
        _photoHandler(image);
    }
}

- (IBAction)btn1_TouchUp:(id)sender
{
    flag = YES;
    [camera takePicture];
//    // started = !started;
//    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
//    picker.delegate = self;
//    picker.allowsEditing = YES;
//    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
//    
//    [self presentViewController:picker animated:YES completion:NULL];
}
//
//- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    
//    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
//    if (!flag) {
//        _img.image = chosenImage;
//        basedObject = chosenImage;
//    }
//    else {
//        Mat object = [ImageUtils cvMatFromUIImage:basedObject];
//        Mat scene = [ImageUtils cvMatFromUIImage:chosenImage];
//        
//        _img.image = [ImageUtils UIImageFromCVMat: feature2D(object, scene)];
//    }
//    
//    [picker dismissViewControllerAnimated:YES completion:NULL];
//}

//-(void)processImage:(cv::Mat &)image
//{    
//    if (!started) {
//       // [FPS draw: image];
//        return;
//    }
//    
//    cv::Mat gray;
//    cvtColor(image, gray, CV_BGRA2GRAY);
//    
//    std::vector<std::vector<cv::Point>> msers;
//    [[MSERManager sharedInstance] detectRegions: gray intoVector: msers];
//    if (msers.size() == 0) { return; };
//    
//    std::vector<cv::Point> *bestMser = nil;
//    double bestPoint = 10.0;
//    
//    std::for_each(msers.begin(), msers.end(), [&] (std::vector<cv::Point> &mser) 
//    {
//        MSERFeature *feature = [[MSERManager sharedInstance] extractFeature: &mser];
//    
//        if(feature != nil)            
//        {
//            if([[MLManager sharedInstance] isToptalLogo: feature] )
//            {
//                double tmp = [[MLManager sharedInstance] distance: feature ];
//                if ( bestPoint > tmp ) {
//                    bestPoint = tmp;
//                    bestMser = &mser;
//                }
//                
//                //[ImageUtils drawMser: &mser intoImage: &image withColor: GREEN];
//            }
//            else 
//            {
//                //NSLog(@"%@", [feature toString]);
//                //[ImageUtils drawMser: &mser intoImage: &image withColor: RED];
//            }
//        }
//        else 
//        {
//            //[ImageUtils drawMser: &mser intoImage: &image withColor: BLUE];
//        }
//    });
//
//    if (bestMser)
//    {
//        NSLog(@"minDist: %f", bestPoint);
//                
//        cv::Rect bound = cv::boundingRect(*bestMser);
//        cv::rectangle(image, bound, GREEN, 3);
//    }
//    else 
//    {
//        cv::rectangle(image, cv::Rect(0, 0, W, H), RED, 3);
//    }
//
//#if DEBUG    
//    const char* str_fps = [[NSString stringWithFormat: @"MSER: %ld", msers.size()] cStringUsingEncoding: NSUTF8StringEncoding];
//    cv::putText(image, str_fps, cv::Point(10, H - 10), CV_FONT_HERSHEY_PLAIN, 1.0, RED);
//#endif
//    
//    [FPS draw: image]; 
//}

@end
