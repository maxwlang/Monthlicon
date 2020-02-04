@interface SBApplication
	- (NSString *) bundleIdentifier;
	- (NSString *) iconIdentifier; 
	- (NSString *) displayName;
@end

%hook SBApplication
- (id) displayName {
	if([self.bundleIdentifier isEqualToString:@"com.apple.mobilecal"]) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"MMMM"];
		NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];        
		[dateFormatter release];
	} else {
		return %orig;
	}
}
%end

%hook SBRootFolderView

@interface SBRootFolderViewDelegate
	- (void) resetIconListViews;
@end

@interface MonthliconHelper: NSObject
	+ (instancetype)sharedHelper;
	@property (nonatomic, assign) NSString *lastMonth;
@end

@implementation MonthliconHelper

+ (instancetype)sharedHelper {
    static MonthliconHelper* sharedHelper = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedHelper = [[MonthliconHelper alloc] init];
    });
    return sharedHelper;
}

@end

BOOL timerInitiated = NO;
extern NSString *lastMonth;

// App label patch - Sets current month to 
- (void) resetIconListViews {
	%orig();
	if(!timerInitiated) {
		// Create a timer if we haven't already. Probably a better way to handle this.
		[NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *timer) {
			NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
			[dateFormatter setDateFormat:@"MMMM"];
			[dateFormatter stringFromDate:[NSDate date]];        
			[dateFormatter release];
			
			if(![dateString isEqualToString:[[MonthliconHelper sharedHelper] lastMonth]]) {
				%orig();
			}

			[[MonthliconHelper sharedHelper] setLastMonth:dateString];
		}];

		timerInitiated = YES;
	}
}
%end

// Switcher patch - Keeps the label as "Calendar" in the app switcher.
%hook SBFluidSwitcherItemContainerHeaderView
- (void) layoutSubviews {
	%orig();

	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"MMMM"];
	[dateFormatter stringFromDate:[NSDate date]];        
	[dateFormatter release];
	
	UILabel *appNameLabel = MSHookIvar<UILabel *>(self, "_firstIconTitle");
	if([appNameLabel.text isEqualToString:dateString]) {
	
		appNameLabel.text = @"Calendar";
		appNameLabel.frame = CGRectMake(appNameLabel.frame.origin.x, appNameLabel.frame.origin.y, appNameLabel.frame.size.width * 5, appNameLabel.frame.size.height);
	
		MSHookIvar<UILabel *>(self, "_firstIconTitle") = appNameLabel;
	}
}
%end

