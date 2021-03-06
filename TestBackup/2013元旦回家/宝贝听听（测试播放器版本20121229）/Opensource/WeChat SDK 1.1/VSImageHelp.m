//
//  VSImageHelp.m
//  cutTest
//
//  Created by zhangdong on 11-7-21.
//  Copyright 2011年 Vita Stone Ltd. All rights reserved.

#import "VSImageHelp.h"

@implementation VSImageHelp
+ (CGSize)fitSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGFloat scale;
	CGSize newsize = thisSize;
	if (newsize.height && (newsize.height > aSize.height))
	{
		scale = aSize.height / newsize.height;
		newsize.width *= scale;
		newsize.height *= scale;
	}
	if (newsize.width && (newsize.width >= aSize.width))
	{
		scale = aSize.width / newsize.width;
		newsize.width *= scale;
		newsize.height *= scale;
	}
    int height = (int)newsize.height;
    int h = height % 3;
    newsize.height = height - h;
 	return newsize;
}

+ (CGRect)frameSize:(CGSize)thisSize inSize:(CGSize)aSize
{
	CGSize size = [self fitSize:thisSize inSize: aSize];
	float dWidth = aSize.width - size.width;
	float dHeight = aSize.height - size.height;
	return CGRectMake(dWidth / 2.0f, dHeight / 2.0f, size.width, size.height);
}

+ (UIImage *)image:(UIImage *)image fitInSize:(CGSize)viewsize
{
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:[VSImageHelp frameSize:image.size inSize:viewsize]];
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();  
    return newimg;  
}

+ (UIImage *)image:(UIImage *)image imageAtRect:(CGRect)rect
{
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	UIImage* subImage = [UIImage imageWithCGImage: imageRef];
	CGImageRelease(imageRef);
	return subImage;
}
@end