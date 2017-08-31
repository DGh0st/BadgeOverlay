#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSSliderTableCell.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface BORootListController : PSListController <MFMailComposeViewControllerDelegate>

@end

@interface UIImage (BOPrivate)
+(UIImage *)_applicationIconImageForBundleIdentifier:(NSString *)bundleIdentifier format:(NSInteger)format scale:(CGFloat)scale;
@end

@interface PSRootController
+(void)setPreferenceValue:(id)value specifier:(id)specifier;
@end

@interface BOSliderCell : PSSliderTableCell <UIAlertViewDelegate, UITextFieldDelegate>
-(void)presentAlert;
@end