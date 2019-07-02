@interface CCUIModuleSliderView
	-(void)setValue:(float)arg1;
@end

@interface CCUIDisplayModuleViewController : UIViewController
	@property (nonatomic,retain) UIView * view;
	@property (retain,nonatomic) CCUIModuleSliderView * sliderView;
	-(void)_setBacklightLevel:(float)arg1;
@end

CCUIDisplayModuleViewController *ccBrightnessController;

static bool tweakIsEnabled = YES;
static float defaultBrightness = 0.5f;
static NSUserDefaults *prefs;

static void loadPrefs() {
	prefs = [[NSUserDefaults alloc] initWithSuiteName:@"gilesgc.easybrightness"];
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

%new
-(void)setBrightnessToDefault {
	if(ccBrightnessController && tweakIsEnabled) {
		[ccBrightnessController _setBacklightLevel:defaultBrightness];
		[ccBrightnessController.sliderView setValue:defaultBrightness];
	}
}
%end

%ctor
{
	NSBundle* displayModule = [NSBundle bundleWithPath:@"/System/Library/ControlCenter/Bundles/DisplayModule.bundle"];

	if(!displayModule.loaded)
		[displayModule load];

	//dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		loadPrefs();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadPrefs, CFSTR("gilesgc.easybrightness/prefChanged"), NULL, CFNotificationSuspensionBehaviorDeliverImmediately);
		%init;
	//});
}
