//
//  ViewController.h
//  TestCamera
//
//  Created by 赵铭 on 2017/9/29.
//  Copyright © 2017年 zm. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol TestJSExport<JSExport>
JSExportAs
(openCamera,
 - (void)showToastWithParameters:(NSString *)parameterone parametertwo:(NSString *)parametertwo
 );

JSExportAs
(openFile,
 - (void)openFileWithParameters:(NSString *)parameterone parametertwo:(NSString *)parametertwo
 );
@end
@interface ViewController : UIViewController


@end

