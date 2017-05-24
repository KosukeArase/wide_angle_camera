#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Detector: NSObject

//- (id)init;
- (bool)recognizeFace1:(UIImage *)image;
- (bool)recognizeFace2:(UIImage *)image;
- (bool)recognizeFace3:(UIImage *)image;
- (void)set_var_image1:(UIImage *)image;
- (void)set_var_image2:(UIImage *)image;
- (void)set_var_image3:(UIImage *)image;
//- (int)test:(int)dummy;
- (UIImage *)get_var_image:(int)dummy;
- (UIImage *)get_image1:(int)dummy;
- (UIImage *)get_image3:(int)dummy;
- (UIImage *)get_image4:(int)dummy;
- (UIImage *)get_image2:(int)dummy;
- (UIImage *)compose:(int)dummy;


@end