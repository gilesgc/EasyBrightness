#import <UIKit/UIKit.h>
#import <BackBoardServices/BKSDisplayBrightness.h>

@interface CCUIModuleSliderView
- (void)setValue:(float)arg1;
@end

@interface CCUIDisplayModuleViewController : UIViewController
@property (nonatomic,retain) UIView * view;
@property (retain,nonatomic) CCUIModuleSliderView * sliderView;
@end

@interface SBBrightnessController
+ (id)sharedBrightnessController;
- (void)setBrightnessLevel:(float)arg1;
@end

@interface SBDisplayBrightnessController
- (id)init;
- (void)setBrightnessLevel:(float)arg1;
@end

CCUIDisplayModuleViewController *ccBrightnessController;

static bool tweakIsEnabled = YES;
static float defaultBrightness = 0.5f;

static void loadPrefs() {
	NSUserDefaults *prefs = [[NSUserDefaults alloc] initWithSuiteName:@"com.gilesgc.easybrightness"];
	tweakIsEnabled = [prefs objectForKey:@"isEnabled"] ? [prefs boolForKey:@"isEnabled"] : YES;
	defaultBrightness = [prefs objectForKey:@"brightnessSlider"] ? [prefs floatForKey:@"brightnessSlider"] : 0.5f;
}

%hook CCUIDisplayModule
-(UIViewController *)contentViewController {
	if(!tweakIsEnabled)
		return %orig;

	ccBrightnessController = (CCUIDisplayModuleViewController*)%orig;
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBrightnessToDefault)];
	[ccBrightnessController.view addGestureRecognizer:tapGesture];
	return ccBrightnessController;
}

-(UIViewController *)contentViewControllerForContext:(id)arg1 {
	if(!tweakIsEnabled)
		return %orig;

	ccBrightnessController = (CCUIDisplayModuleViewController*)%orig;
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setBrightnessToDefault)];
	[ccBrightnessController.view addGestureRecognizer:tapGesture];
	return ccBrightnessController;
}

%new
-(void)setBrightnessToDefault {
	if(ccBrightnessController && tweakIsEnabled) {
		[[%c(SBBrightnessController) sharedBrightnessController] setBrightnessLevel:defaultBrightness];
		[[[%c(SBDisplayBrightnessController) alloc] init] setBrightnessLevel:defaultBrightness];

		//Credit to hbang for this code which prevents brightness shifts after respring
		BKSDisplayBrightnessTransactionRef transaction = BKSDisplayBrightnessTransactionCreate(kCFAllocatorDefault);
		BKSDisplayBrightnessSet(BKSDisplayBrightnessGetCurrent(), 1);
		CFRelease(transaction);

		[ccBrightnessController.sliderView setValue:defaultBrightness];
	}
}
%end

%ctor
{
	NSBundle* displayModule = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/DisplayModule.bundle"];

	if(!displayModule.loaded)
		[displayModule load];

	loadPrefs();
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("com.gilesgc.easybrightness/prefChanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
	%init;

}
