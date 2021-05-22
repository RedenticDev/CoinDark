#import <UIKit/UIKit.h>

@interface UIColor (DarkMode)
+ (UIColor *)OLEDBackgroundColor API_AVAILABLE(ios(13.0));
+ (UIColor *)OLEDTextColor API_AVAILABLE(ios(13.0));
+ (UIColor *)systemBackgroundColorIfEligible:(UIColor *)input;
+ (UIColor *)systemTextColorIfEligible:(UIColor *)input;
@end

@implementation UIColor (DarkMode)

+ (UIColor *)OLEDBackgroundColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleLight ? 
                [UIColor colorWithWhite:1.00 alpha:1.00] :
                [UIColor colorWithWhite:0.00 alpha:1.00];
    }];
}

+ (UIColor *)OLEDTextColor {
    return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traits) {
        return traits.userInterfaceStyle == UIUserInterfaceStyleLight ? 
                [UIColor colorWithWhite:0.00 alpha:1.00] :
                [UIColor colorWithWhite:1.00 alpha:1.00];
    }];
}

+ (UIColor *)systemBackgroundColorIfEligible:(UIColor *)input {
    if (@available(iOS 13.0, *)) {
        if (input && input != [UIColor systemBackgroundColor]) {
            CGFloat red, green, blue, alpha;
            [input getRed:&red green:&green blue:&blue alpha:&alpha];
            if (red >= .9 && green >= .9 && blue >= .9) {
                return [[UIColor OLEDBackgroundColor] colorWithAlphaComponent:alpha];
            }
        }
    }
    return input;
}

+ (UIColor *)systemTextColorIfEligible:(UIColor *)input {
    if (@available(iOS 13.0, *)) {
        if (input && input != [UIColor labelColor]) {
            CGFloat red, green, blue, alpha;
            [input getRed:&red green:&green blue:&blue alpha:&alpha];
            if (red <= .1 && green <= .1 && blue <= .2) {
                return [[UIColor OLEDTextColor] colorWithAlphaComponent:alpha];
            }
        }
    }
    return input;
}

@end

@interface RCTTextView : UIView
@end

@interface RCTRootView : UIView
@end

@interface RCTView : UIView
@end

@interface RNCSafeAreaView : RCTView
@end

@interface RCTUITextView : UITextView
@end

%hook BVLinearGradient

- (void)setColors:(NSArray<UIColor *> *)colors {
    if (@available(iOS 13.0, *)) {
        if (colors && colors.count == 2) {
            CGFloat red1, red2, green1, green2, blue1, blue2, alpha1, alpha2;
            [colors[0] getRed:&red1 green:&green1 blue:&blue1 alpha:&alpha1];
            [colors[1] getRed:&red2 green:&green2 blue:&blue2 alpha:&alpha2];
            if (red1 == 1 && green1 == 1 && blue1 == 1 && red1 == red2 && red2 == green2 && green2 && blue2) {
                if (alpha1 == 0 && alpha2 == 1) {
                    %orig(@[
                        [[UIColor OLEDBackgroundColor] colorWithAlphaComponent:0],
                        [UIColor OLEDBackgroundColor]
                    ]);
                }
            }
        }
    }
    %orig;
}

%end

%hook RCTTextView

- (void)setTextStorage:(NSTextStorage *)textStorage contentFrame:(CGRect)contentFrame descendantViews:(NSArray<UIView *> *)descendantViews {
    NSMutableDictionary *attributes = [[textStorage attributesAtIndex:0 effectiveRange:nil] mutableCopy];
    if (attributes[NSForegroundColorAttributeName]) {
        attributes[NSForegroundColorAttributeName] = [UIColor systemTextColorIfEligible:attributes[NSForegroundColorAttributeName]];
        [textStorage setAttributes:attributes range:NSMakeRange(0, textStorage.length)];
    }

    %orig(textStorage, contentFrame, descendantViews);
}

%end

%hook RCTRootView

- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor systemBackgroundColorIfEligible:self.backgroundColor];
}

- (void)didMoveToSuperview {
    %orig;
    self.backgroundColor = [UIColor systemBackgroundColorIfEligible:self.backgroundColor];
}

- (UIColor *)backgroundColor {
    return [UIColor systemBackgroundColorIfEligible:%orig];
}

%end

%hook RCTView

- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor systemBackgroundColorIfEligible:self.backgroundColor];
}

- (void)didMoveToSuperview {
    %orig;
    self.backgroundColor = [UIColor systemBackgroundColorIfEligible:self.backgroundColor];
}

- (UIColor *)backgroundColor {
    return [UIColor systemBackgroundColorIfEligible:%orig];
}

%end

%hook RNCSafeAreaView

- (void)didMoveToWindow {
    %orig;
    self.backgroundColor = [UIColor systemBackgroundColorIfEligible:self.backgroundColor];
}

- (void)didMoveToSuperview {
    %orig;
    self.backgroundColor = [UIColor systemBackgroundColorIfEligible:self.backgroundColor];
}

- (UIColor *)backgroundColor {
    return [UIColor systemBackgroundColorIfEligible:%orig];
}

%end

%hook RCTUITextView

- (void)textDidChange {
    %orig;
    if (@available(iOS 13.0, *)) {
        self.textColor = [UIColor labelColor];
    }
}

- (NSDictionary *)defaultTextAttributes {
    if (@available(iOS 13.0, *)) {
        NSMutableDictionary *attributes = [%orig mutableCopy];
        if (attributes[NSForegroundColorAttributeName]) {
            attributes[NSForegroundColorAttributeName] = [UIColor systemTextColorIfEligible:attributes[NSForegroundColorAttributeName]];
            return attributes;
        }
    }
    return %orig;
}

- (UIColor *)textColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor labelColor];
    }
    return %orig;
}

%end

%hook UIApplication

- (NSInteger)statusBarStyle {
    if (@available(iOS 13.0, *)) {
        return UIStatusBarStyleDefault;
    }
    return %orig;
}

%end
