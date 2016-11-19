//
//  Features2D-Homo.hpp
//  LogoDetector
//
//  Created by MACMALL MF840 on 11/3/16.
//  Copyright © 2016 altaibayar tseveenbayar. All rights reserved.
//

#ifndef Features2D_Homo_hpp
#define Features2D_Homo_hpp

#include <stdio.h>


# include "opencv2/core/core.hpp"
# include "opencv2/features2d/features2d.hpp"
# include "opencv2/highgui/highgui.hpp"
# include "opencv2/calib3d/calib3d.hpp"
# include "opencv2/nonfree/features2d.hpp"

#endif /* Features2D_Homo_hpp */

using namespace std;
using namespace cv;

extern vector<Mat> template_image;

//Mat feature2D(Mat img_object, Mat img_scene);
int detectFeature2D(Mat img_object_rgb, Mat img_scene_rgb);

Rect_<int> MatchingMethod(Mat img, Mat templ, int match_method);
Mat MatchingMethodWithDraw(Mat img, Mat templ, int match_method);
Mat MatchingTemplateWithMultiScale(Mat img, Mat templ, int match_method, string &output);

Rect_<int> detectFeature2D_TemplateMatch(Mat img_scene_rgb, int& index_template);
vector<KeyPoint> getKeyPoint(Mat mat);
