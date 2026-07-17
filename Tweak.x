#import "TikTokHeaders.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
@interface TTKTabBarButton : UIControl
@end

@interface TTKProfileHeaderView : UIView
@property (nonatomic, weak) UIViewController *yy_viewController;
- (void)addHandleLongPress;
@end

@interface TTKEnlargeAvatarViewController : UIViewController
- (void)addHandleLongPress;
@end

// كلاسات غير موجودة في الهيدرات الأصلية (نعرفها بالكامل مع خصائصنا)
@interface TIKTOKProfileHeaderExtraViewController : UIViewController
@property (nonatomic, assign) BOOL bh_confirmed;
- (void)relationBtnClicked:(id)arg1;
@end

@interface AWEPlayInteractionUserAvatarElement : NSObject
@property (nonatomic, assign) BOOL bh_confirmed;
- (void)onFollowViewClicked:(id)arg1;
@end

@interface AWECommentPanelCell : UITableViewCell
@property (nonatomic, assign) BOOL bh_like_confirmed;
@property (nonatomic, assign) BOOL bh_dislike_confirmed;
- (void)likeButtonTapped;
- (void)dislikeButtonTapped;
@end

// كلاس موجود في الهيدرات الأصلية (نستخدم Category لإضافة خصائصنا فقط)
// كلاس موجود في الهيدرات الأصلية (نستخدم Category لإضافة خصائصنا فقط)
@interface AWEFeedVideoButton (BHTikTok)
@property (nonatomic, assign) BOOL bh_confirmed;
- (void)_onTouchUpInside; // <-- هذا هو السطر الذي سيحل المشكلة
@end

@interface AWEFeedViewCell : UITableViewCell
- (void)addDownloadButton;
- (void)bh_downloadVideoAction;
- (void)addHideElementButton;
- (void)addHandleLongPress;
@end

@interface AWEAwemeDetailTableViewCell : UITableViewCell
- (void)addDownloadButton;
- (void)bh_downloadVideoAction;
- (void)addHideElementButton;
- (void)addHandleLongPress;
@end

@interface TTKStoryDetailTableViewCell : UITableViewCell
- (void)addDownloadButton;
- (void)bh_downloadVideoAction;
- (void)addHideElementButton;
- (void)addHandleLongPress;
@end

NSArray *jailbreakPaths;

static void showConfirmation(void (^okHandler)(void)) {
  [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"Are you sure?" image:nil actionButtonTitle:@"Yes" cancelButtonTitle:@"No" actionBlock:^{
    okHandler();
  } cancelBlock:nil];
}

// ==========================================
// 2. إعدادات التطبيق وتخطي القيود
// ==========================================

%hook AppDelegate
- (_Bool)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    %orig;
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BHTikTokFirstRun"]) {
        [[NSUserDefaults standardUserDefaults] setValue:@"BHTikTokFirstRun" forKey:@"BHTikTokFirstRun"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"hide_ads"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"dw_videos"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"dw_musics"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"remove_elements_button"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_decription"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_video_link"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_music_link"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"show_porgress_bar"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"save_profile"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"copy_profile_information"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extended_bio"];
        [[NSUserDefaults standardUserDefaults] setBool:true forKey:@"extendedComment"];
    }
    [BHIManager cleanCache];
    return true;
}

static BOOL isAuthenticationShowed = FALSE;
- (void)applicationDidBecomeActive:(id)arg1 {
  %orig;
  if ([BHIManager appLock] && !isAuthenticationShowed) {
    UIViewController *rootController = [[self window] rootViewController];
    SecurityViewController *securityViewController = [SecurityViewController new];
    securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [rootController presentViewController:securityViewController animated:YES completion:nil];
    isAuthenticationShowed = TRUE;
  }
}

- (void)applicationWillEnterForeground:(id)arg1 {
  %orig;
  isAuthenticationShowed = FALSE;
}
%end

%hook TTKTabBarButton

- (void)layoutSubviews {
    %orig;
    
    // 1. التحقق من أننا لم نضف الإيماءة مسبقاً لتجنب التكرار والتسبب في كراش
    BOOL hasLongPress = NO;
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            hasLongPress = YES;
            break;
        }
    }
    
    // 2. إذا لم تكن الإيماءة موجودة، نقوم بإنشائها
    if (!hasLongPress) {
        // نستخدم الـ accessibilityLabel الذي استخرجته من FLEX لتمييز زر الملف الشخصي
        NSString *label = self.accessibilityLabel;
        
        // وضعنا عدة احتمالات للغات المختلفة (عربي/إنجليزي) لضمان عملها دائماً
        if ([label containsString:@"Profile"] || [label containsString:@"الملف الشخصي"] || [label containsString:@"Me"] || [label containsString:@"أنا"]) {
            
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bh_openSettings:)];
            longPress.minimumPressDuration = 0.5; // نصف ثانية من الضغط المستمر
            [self addGestureRecognizer:longPress];
        }
    }
}

// 3. الدالة التي سيتم تنفيذها عند الضغط المطول
%new
- (void)bh_openSettings:(UILongPressGestureRecognizer *)sender {
    // نتأكد أن الحدث يتم تنفيذه مرة واحدة عند بداية الضغط
    if (sender.state == UIGestureRecognizerStateBegan) {
        // تجهيز واجهة الإعدادات الخاصة بنا
        UINavigationController *BHTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
        
        // استخدام الدالة المساعدة لجلب الواجهة الحالية المفتوحة
        UIViewController *topVC = topMostController();
        
        // إظهار واجهة الإعدادات بانزلاق أنيق من الأسفل
        [topVC presentViewController:BHTikTokSettings animated:YES completion:nil];
    }
}

%end

%hook SparkViewController 
- (void)viewWillAppear:(BOOL)animated {
    if (![BHIManager alwaysOpenSafari]) {
        return %orig;
    }
    NSURLComponents *components = [NSURLComponents componentsWithURL:self.originURL resolvingAgainstBaseURL:NO];
    NSString *searchParameter = @"url";
    NSString *searchValue = nil;
    for (NSURLQueryItem *queryItem in components.queryItems) {
        if ([queryItem.name isEqualToString:searchParameter]) {
            searchValue = queryItem.value;
            break;
        }
    }
    if (searchValue) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:searchValue] options:@{} completionHandler:nil];
        [self didTapCloseButton];
    } else {
        return %orig;
    }
}
%end

%hook CTCarrier 
- (NSString *)mobileCountryCode {
    if ([BHIManager regionChangingEnabled] && [BHIManager selectedRegion]) {
        return [BHIManager selectedRegion][@"mcc"];
    }
    return %orig;
}
- (void)setIsoCountryCode:(NSString *)arg1 {
    if ([BHIManager regionChangingEnabled] && [BHIManager selectedRegion]) {
        return %orig([BHIManager selectedRegion][@"code"]);
    }
    return %orig(arg1);
}
- (NSString *)isoCountryCode {
    if ([BHIManager regionChangingEnabled] && [BHIManager selectedRegion]) {
        return [BHIManager selectedRegion][@"code"];
    }
    return %orig;
}
- (NSString *)mobileNetworkCode {
    if ([BHIManager regionChangingEnabled] && [BHIManager selectedRegion]) {
        return [BHIManager selectedRegion][@"mnc"];
    }
    return %orig;
}
%end

%hook AWEAwemeModel 
- (id)initWithDictionary:(id)arg1 error:(id *)arg2 {
    id orig = %orig;
    return [BHIManager hideAds] && self.isAds ? nil : orig;
}
- (id)init {
    id orig = %orig;
    return [BHIManager hideAds] && self.isAds ? nil : orig;
}
- (BOOL)progressBarDraggable {
    return [BHIManager progressBar] || %orig;
}
- (BOOL)progressBarVisible {
    return [BHIManager progressBar] || %orig;
}
%end

%hook AWEPlayVideoPlayerController 
- (void)playerWillLoopPlaying:(id)arg1 {
    if ([BHIManager autoPlay]) {
        if ([self.container.parentViewController isKindOfClass:%c(AWENewFeedTableViewController)]) {
            [((AWENewFeedTableViewController *)self.container.parentViewController) scrollToNextVideo];
            return;
        }
    }
    %orig;
}
%end

%hook AWEUserModel 
- (NSNumber *)followerCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"follower_count"];
        if (fakeCountString.length > 0) return @([fakeCountString integerValue]);
    }
    return %orig;
}
- (NSNumber *)followingCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fakeCountString = [[NSUserDefaults standardUserDefaults] stringForKey:@"following_count"];
        if (fakeCountString.length > 0) return @([fakeCountString integerValue]);
    }
    return %orig;
}
- (BOOL)isVerifiedUser {
    if ([BHIManager fakeVerified]) return true;
    return %orig;
}
%end

%hook AWETextInputController
- (NSUInteger)maxLength {
    if ([BHIManager extendedComment]) return 240;
    return %orig;
}
%end

%hook AWEProfileEditTextViewController
- (NSInteger)maxTextLength {
    if ([BHIManager extendedBio]) return 222;
    return %orig;
}
%end

// ==========================================
// 3. التفاعلات والتأكيدات (النسخة الآمنة)
// ==========================================

%hook TIKTOKProfileHeaderExtraViewController 
%property (nonatomic, assign) BOOL bh_confirmed;
- (void)relationBtnClicked:(id)sender {
    if (self.bh_confirmed) {
        self.bh_confirmed = NO;
        %orig(sender);
        return;
    }
    if ([BHIManager followConfirmation]) {
        showConfirmation(^{
            self.bh_confirmed = YES;
            [self relationBtnClicked:sender];
        });
    } else {
        %orig(sender);
    }
}
%end

%hook AWEPlayInteractionUserAvatarElement
%property (nonatomic, assign) BOOL bh_confirmed;
- (void)onFollowViewClicked:(id)sender {
    if (self.bh_confirmed) {
        self.bh_confirmed = NO;
        %orig(sender);
        return;
    }
    if ([BHIManager followConfirmation]) {
        showConfirmation(^{
            self.bh_confirmed = YES;
            [self onFollowViewClicked:sender];
        });
    } else {
        %orig(sender);
    }
}
%end

%hook AWEFeedVideoButton 
%property (nonatomic, assign) BOOL bh_confirmed;
- (void)_onTouchUpInside {
    if (self.bh_confirmed) {
        self.bh_confirmed = NO;
        %orig;
        return;
    }
    if ([BHIManager likeConfirmation] && [self.imageNameString isEqualToString:@"icon_home_like_before"]) {
        showConfirmation(^{ 
            self.bh_confirmed = YES;
            [self _onTouchUpInside];
        });
    } else {
        %orig;
    }
}
%end

%hook AWECommentPanelCell 
%property (nonatomic, assign) BOOL bh_like_confirmed;
%property (nonatomic, assign) BOOL bh_dislike_confirmed;

- (void)likeButtonTapped {
    if (self.bh_like_confirmed) {
        self.bh_like_confirmed = NO;
        %orig;
        return;
    }
    if ([BHIManager likeCommentConfirmation]) {
        showConfirmation(^{ 
            self.bh_like_confirmed = YES;
            [self likeButtonTapped]; 
        });
    } else {
        %orig;
    }
}

- (void)dislikeButtonTapped {
    if (self.bh_dislike_confirmed) {
        self.bh_dislike_confirmed = NO;
        %orig;
        return;
    }
    if ([BHIManager dislikeCommentConfirmation]) {
        showConfirmation(^{ 
            self.bh_dislike_confirmed = YES;
            [self dislikeButtonTapped]; 
        });
    } else {
        %orig;
    }
}
%end

// ==========================================
// 4. الملف الشخصي (النسخ والحفظ)
// ==========================================

%hook TTKProfileHeaderView 
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if ([BHIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
}
%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self addGestureRecognizer:longPress];
}
%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        id rootVC = self.yy_viewController;
        AWEUserModel *userModel = nil;
        if ([rootVC respondsToSelector:@selector(user)]) {
            userModel = [rootVC valueForKey:@"user"];
        } else if ([self respondsToSelector:@selector(user)]) {
            userModel = [self valueForKey:@"user"];
        }

        if (userModel) {
            TUXActionSheetController *alert = [[%c(TUXActionSheetController) alloc] initWithTitle:@"Select option to copy."];
            
            if (userModel.socialName) {
                NSString *accountName = userModel.socialName;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy social name" subtitle:accountName image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = accountName;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }
            if (userModel.nickname) {
                NSString *nickName = userModel.nickname;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy nick name" subtitle:nickName image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = nickName;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }
            if (userModel.signature) {
                NSString *bio = userModel.signature;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy bio" subtitle:nil image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = bio;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }
            if (userModel.bioUrl) {
                NSString *bioURL = userModel.bioUrl;
                [alert addAction:[[%c(TUXActionSheetAction) alloc] initWithStyle:0 title:@"Copy URL in bio" subtitle:bioURL image:[UIImage systemImageNamed:@"clipboard"] imageLabel:nil handler:^(TUXActionSheetAction * action) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = bioURL;
                    [%c(AWEToast) showSuccess:@"Copied"];
                }]];
            }

            [alert setTitle:@"Select option to copy."];
            [alert setDismissOnDraggingDown:true];
            [self.yy_viewController presentViewController:alert animated:YES completion:nil];
        }
    }
}
%end

%hook TTKEnlargeAvatarViewController 
- (void)viewDidLoad {
    %orig;
    if ([BHIManager profileSave]) {
        [self addHandleLongPress];
    }
}
%new 
- (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self.view addGestureRecognizer:longPress];
}
%new 
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UIImageView *imageView = [self valueForKey:@"avatarImageView"];
        if (imageView && imageView.image) {
            [BHIManager showSaveVC:@[imageView.image]];
        }
    }
}
%end

// ==========================================
// 5. أقسام التحميل وإخفاء العناصر (Feed/Detail/Story)
// ==========================================

%hook AWEFeedViewCell 
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;

- (void)configWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton]; // إضافة زر التحميل
}
- (void)configureWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton]; // إضافة زر التحميل
}

%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.4;
    [self addGestureRecognizer:longPress];
}

%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        AWEAwemeModel *videoModel = [self valueForKey:@"model"] ?: [self valueForKey:@"aweme"];
        NSString *video_description = videoModel.music_songName ?: @"BHTikTok Options";

        // استخدام واجهة النظام الأصلية بدلاً من واجهة تيك توك المعطلة
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BHTikTok" message:video_description preferredStyle:UIAlertControllerStyleActionSheet];

        if ([BHIManager downloadVideos]) {
            UIAlertAction *downloadVideo = [UIAlertAction actionWithTitle:@"Download video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self bh_downloadVideoAction];
            }];
            [downloadVideo setValue:[UIImage systemImageNamed:@"arrow.down"] forKey:@"image"];
            [alert addAction:downloadVideo];
        }

        if ([BHIManager downloadMusics]) {
            UIAlertAction *downloadMusic = [UIAlertAction actionWithTitle:@"Download music" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *downloadableURL = [((AWEMusicModel *)videoModel.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)videoModel.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:self.viewController.view];
                }
            }];
            [downloadMusic setValue:[UIImage systemImageNamed:@"music.note"] forKey:@"image"];
            [alert addAction:downloadMusic];
        }

        if ([BHIManager copyMusicLink]) {
            UIAlertAction *copyMusic = [UIAlertAction actionWithTitle:@"Copy music link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *downloadableURL = [((AWEMusicModel *)videoModel.music).playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                }
            }];
            [copyMusic setValue:[UIImage systemImageNamed:@"link"] forKey:@"image"];
            [alert addAction:copyMusic];
        }

        if ([BHIManager copyVideoLink]) {
            UIAlertAction *copyVideo = [UIAlertAction actionWithTitle:@"Copy video link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *downloadableURL = [videoModel.video.playURL bestURLtoDownload];
                if (downloadableURL) {
                    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                    pasteboard.string = [downloadableURL absoluteString];
                }
            }];
            [copyVideo setValue:[UIImage systemImageNamed:@"link"] forKey:@"image"];
            [alert addAction:copyVideo];
        }

        if ([BHIManager copyVideoDecription]) {
            UIAlertAction *copyDesc = [UIAlertAction actionWithTitle:@"Copy description" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = video_description;
            }];
            [copyDesc setValue:[UIImage systemImageNamed:@"doc.on.doc"] forKey:@"image"];
            [alert addAction:copyDesc];
        }

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];

        [self.viewController presentViewController:alert animated:YES completion:nil];
    }
}

// دالة التحميل المباشر
%new - (void)bh_downloadVideoAction {
    AWEAwemeModel *videoModel = [self valueForKey:@"model"] ?: [self valueForKey:@"aweme"];
    NSURL *downloadableURL = [videoModel.video.playURL bestURLtoDownload];
    self.fileextension = [videoModel.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:self.viewController.view];
    }
}

// رسم زر العين
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    // 1. عكس حالة الإخفاء الحالية (إذا كانت ظاهرة نخفيها والعكس)
    self.elementsHidden = !self.elementsHidden;
    
    // 2. تحديث أيقونة زر العين استجابةً للضغطة
    [sender setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
    
    // 3. الطريقة الأولى (الناعمة): محاولة استخدام نظام إخفاء تيك توك المدمج ديناميكياً
    id rootVC = [self respondsToSelector:@selector(viewController)] ? [self valueForKey:@"viewController"] : nil;
    
    if (rootVC && [rootVC respondsToSelector:@selector(interactionController)]) {
        id interactionController = [rootVC valueForKey:@"interactionController"];
        
        // نسأل إذا كانت دالة الإخفاء موجودة بغض النظر عن اسم الكلاس
        if ([interactionController respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
            [interactionController hideAllElements:self.elementsHidden exceptArray:nil];
            return; // نجحت العملية! نخرج من الدالة.
        }
    }
    
    // 4. الخطة البديلة (القوية): الإخفاء الإجباري لطبقات الواجهة في حال فشل الطريقة الأولى
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *view in self.contentView.subviews) {
            // استثناء أزرار أداتنا (زر العين 999، وزر التحميل 998) لكي لا تختفي
            if (view.tag == 999 || view.tag == 998) continue;
            
            // استثناء طبقة الفيديو الأساسية لكي يستمر العرض (عادة تكون أول طبقة)
            if (view == [self.contentView.subviews firstObject]) continue;
            
            NSString *className = NSStringFromClass([view class]);
            if ([className containsString:@"Video"] || [className containsString:@"Player"]) continue;
            
            // إخفاء أو إظهار باقي الطبقات (الأزرار، الوصف، اسم المستخدم)
            view.alpha = self.elementsHidden ? 0.0 : 1.0;
        }
    }];
}

// رسم زر التحميل الخارجي تحت زر العين
%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(bh_downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];

    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];
        
        UIView *hideButton = [self viewWithTag:999];
        if (hideButton) {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:30],
                [downloadButton.heightAnchor constraintEqualToConstant:30],
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:95],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:30],
                [downloadButton.heightAnchor constraintEqualToConstant:30],
            ]];
        }
    }
}


%new - (void)downloaderProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    [self.hud dismiss];
    [BHIManager showSaveVC:downloadedFilePaths];
}
%new - (void)downloaderDidFailureWithError:(NSError *)error {
    if (error) [self.hud dismiss];
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];
    [BHIManager showSaveVC:@[newFilePath]];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) [self.hud dismiss];
}
%end

%hook AWEAwemeDetailTableViewCell
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;

- (void)configWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}
- (void)configureWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}

%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.4;
    [self addGestureRecognizer:longPress];
}

%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (![self.viewController isKindOfClass:%c(AWEAwemeDetailCellViewController)]) return;
        AWEAwemeDetailCellViewController *rootVC = self.viewController;
        NSString *video_description = rootVC.model.music_songName ?: @"BHTikTok Options";

        // استخدام قائمة أبل الأصلية بدلاً من الشاشة البيضاء
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BHTikTok" message:video_description preferredStyle:UIAlertControllerStyleActionSheet];

        if ([BHIManager downloadVideos]) {
            UIAlertAction *downloadVideo = [UIAlertAction actionWithTitle:@"Download video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self bh_downloadVideoAction];
            }];
            [downloadVideo setValue:[UIImage systemImageNamed:@"arrow.down"] forKey:@"image"];
            [alert addAction:downloadVideo];
        }

        if ([BHIManager downloadMusics]) {
            UIAlertAction *downloadMusic = [UIAlertAction actionWithTitle:@"Download music" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *downloadableURL = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                self.fileextension = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownloadFormat];
                if (downloadableURL) {
                    BHDownload *dwManager = [[BHDownload alloc] init];
                    [dwManager downloadFileWithURL:downloadableURL];
                    [dwManager setDelegate:self];
                    self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
                    self.hud.textLabel.text = @"Downloading";
                    [self.hud showInView:self.viewController.view];
                }
            }];
            [downloadMusic setValue:[UIImage systemImageNamed:@"music.note"] forKey:@"image"];
            [alert addAction:downloadMusic];
        }

        if ([BHIManager copyMusicLink]) {
            UIAlertAction *copyMusic = [UIAlertAction actionWithTitle:@"Copy music link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *url = [((AWEMusicModel *)rootVC.model.music).playURL bestURLtoDownload];
                if (url) [UIPasteboard generalPasteboard].string = [url absoluteString];
            }];
            [copyMusic setValue:[UIImage systemImageNamed:@"link"] forKey:@"image"];
            [alert addAction:copyMusic];
        }

        if ([BHIManager copyVideoLink]) {
            UIAlertAction *copyVideo = [UIAlertAction actionWithTitle:@"Copy video link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                NSURL *url = [rootVC.model.video.playURL bestURLtoDownload];
                if (url) [UIPasteboard generalPasteboard].string = [url absoluteString];
            }];
            [copyVideo setValue:[UIImage systemImageNamed:@"link"] forKey:@"image"];
            [alert addAction:copyVideo];
        }

        // ميزة نسخ الوصف
        if ([BHIManager copyVideoDecription]) {
            UIAlertAction *copyDesc = [UIAlertAction actionWithTitle:@"Copy description" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [UIPasteboard generalPasteboard].string = video_description;
            }];
            [copyDesc setValue:[UIImage systemImageNamed:@"doc.on.doc"] forKey:@"image"];
            [alert addAction:copyDesc];
        }

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];

        [self.viewController presentViewController:alert animated:YES completion:nil];
    }
}

%new - (void)bh_downloadVideoAction {
    if (![self.viewController isKindOfClass:%c(AWEAwemeDetailCellViewController)]) return;
    AWEAwemeDetailCellViewController *rootVC = self.viewController;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:self.viewController.view];
    }
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(bh_downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];

    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];
        
        UIView *hideButton = [self viewWithTag:999];
        if (hideButton) {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:30],
                [downloadButton.heightAnchor constraintEqualToConstant:30],
            ]];
        } else {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:95],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:30],
                [downloadButton.heightAnchor constraintEqualToConstant:30],
            ]];
        }
    }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [hideElementButton setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];
        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}

%new - (void)hideElementButtonHandler:(UIButton *)sender {
    self.elementsHidden = !self.elementsHidden;
    [sender setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
    
    AWEAwemeBaseViewController *rootVC = self.viewController;
    if ([rootVC respondsToSelector:@selector(interactionController)]) {
        id interactionController = rootVC.interactionController;
        if ([interactionController respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
            [interactionController hideAllElements:self.elementsHidden exceptArray:nil];
            return;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *view in self.contentView.subviews) {
            if (view.tag == 999 || view.tag == 998) continue;
            if (view == [self.contentView.subviews firstObject]) continue;
            NSString *className = NSStringFromClass([view class]);
            if ([className containsString:@"Video"] || [className containsString:@"Player"]) continue;
            view.alpha = self.elementsHidden ? 0.0 : 1.0;
        }
    }];
}

%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];
    [BHIManager showSaveVC:@[newFilePath]];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) [self.hud dismiss];
}
%end

%hook TTKStoryDetailTableViewCell
// (نفس المنطق المطبق في الأعلى، قمت بتوحيده لتفادي أي مشاكل مستقبلية في القصص)
%property (nonatomic, strong) JGProgressHUD *hud;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;

- (void)configWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}
- (void)configureWithModel:(id)model {
    %orig;
    [self addHandleLongPress];
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}

%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.minimumPressDuration = 0.4;
    [self addGestureRecognizer:longPress];
}

%new - (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (![self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) return;
        TTKStoryDetailContainerViewController *rootVC = self.viewController;
        NSString *video_description = rootVC.model.currentPlayingStory.music_songName ?: @"BHTikTok Options";

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"BHTikTok" message:video_description preferredStyle:UIAlertControllerStyleActionSheet];

        if ([BHIManager downloadVideos]) {
            UIAlertAction *downloadVideo = [UIAlertAction actionWithTitle:@"Download video" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [self bh_downloadVideoAction];
            }];
            [downloadVideo setValue:[UIImage systemImageNamed:@"arrow.down"] forKey:@"image"];
            [alert addAction:downloadVideo];
        }
        
        // ... بقية الأزرار كما في الأعلى للقصص
        if ([BHIManager copyVideoDecription]) {
            UIAlertAction *copyDesc = [UIAlertAction actionWithTitle:@"Copy description" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                [UIPasteboard generalPasteboard].string = video_description;
            }];
            [copyDesc setValue:[UIImage systemImageNamed:@"doc.on.doc"] forKey:@"image"];
            [alert addAction:copyDesc];
        }

        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancel];

        [self.viewController presentViewController:alert animated:YES completion:nil];
    }
}

%new - (void)bh_downloadVideoAction {
    if (![self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) return;
    TTKStoryDetailContainerViewController *rootVC = self.viewController;
    NSURL *downloadableURL = [rootVC.model.currentPlayingStory.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.currentPlayingStory.video.playURL bestURLtoDownloadFormat];
    if (downloadableURL) {
        BHDownload *dwManager = [[BHDownload alloc] init];
        [dwManager downloadFileWithURL:downloadableURL];
        [dwManager setDelegate:self];
        self.hud = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        self.hud.textLabel.text = @"Downloading";
        [self.hud showInView:self.viewController.view];
    }
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [downloadButton setTag:998];
    [downloadButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [downloadButton addTarget:self action:@selector(bh_downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];

    if (![self viewWithTag:998]) {
        [downloadButton setTintColor:[UIColor whiteColor]];
        [self addSubview:downloadButton];
        
        UIView *hideButton = [self viewWithTag:999];
        if (hideButton) {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:30],
                [downloadButton.heightAnchor constraintEqualToConstant:30],
            ]];
        }
    }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [hideElementButton setTag:999];
    [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:false];
    [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
    [hideElementButton setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];

    if (![self viewWithTag:999]) {
        [hideElementButton setTintColor:[UIColor whiteColor]];
        [self addSubview:hideElementButton];
        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:30],
            [hideElementButton.heightAnchor constraintEqualToConstant:30],
        ]];
    }
}
%new - (void)hideElementButtonHandler:(UIButton *)sender {
    self.elementsHidden = !self.elementsHidden;
    [sender setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
    
    TTKStoryDetailContainerViewController *rootVC = self.viewController;
    if ([rootVC respondsToSelector:@selector(interactionController)]) {
        id interactionController = rootVC.interactionController;
        if ([interactionController respondsToSelector:@selector(hideAllElements:exceptArray:)]) {
            [interactionController hideAllElements:self.elementsHidden exceptArray:nil];
            return;
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        for (UIView *view in self.contentView.subviews) {
            if (view.tag == 999 || view.tag == 998) continue;
            if (view == [self.contentView.subviews firstObject]) continue;
            NSString *className = NSStringFromClass([view class]);
            if ([className containsString:@"Video"] || [className containsString:@"Player"]) continue;
            view.alpha = self.elementsHidden ? 0.0 : 1.0;
        }
    }];
}
%new - (void)downloadProgress:(float)progress {
    self.hud.detailTextLabel.text = [BHIManager getDownloadingPersent:progress];
}
%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
    [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
    [self.hud dismiss];
    [BHIManager showSaveVC:@[newFilePath]];
}
%new - (void)downloadDidFailureWithError:(NSError *)error {
    if (error) [self.hud dismiss];
}
%end

// ==========================================
// 6. أدوات التحميل وتخطي حماية النظام
// ==========================================

%hook AWEURLModel
%new - (NSString *)bestURLtoDownloadFormat {
    NSURL *bestURLFormat;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"]) bestURLFormat = @"mp4";
        else if ([url containsString:@".jpeg"]) bestURLFormat = @"jpeg";
        else if ([url containsString:@".png"]) bestURLFormat = @"png";
        else if ([url containsString:@".mp3"]) bestURLFormat = @"mp3";
        else if ([url containsString:@".m4a"]) bestURLFormat = @"m4a";
    }
    if (bestURLFormat == nil) bestURLFormat = @"m4a";
    return bestURLFormat;
}
%new - (NSURL *)bestURLtoDownload {
    NSURL *bestURL;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"] || [url containsString:@".jpeg"] || [url containsString:@".mp3"]) {
            bestURL = [NSURL URLWithString:url];
        }
    }
    if (bestURL == nil) bestURL = [NSURL URLWithString:[self.originURLList firstObject]];
    return bestURL;
}
%end

%hook NSFileManager
-(BOOL)fileExistsAtPath:(id)arg1 {
	for (NSString *file in jailbreakPaths) {
		if ([arg1 isEqualToString:file]) return NO;
	}
	return %orig;
}
-(BOOL)fileExistsAtPath:(id)arg1 isDirectory:(BOOL*)arg2 {
	for (NSString *file in jailbreakPaths) {
		if ([arg1 isEqualToString:file]) return NO;
	}
	return %orig;
}
%end

%hook BDADeviceHelper
+(bool)isJailBroken { return NO; }
%end

%hook UIDevice
+(bool)btd_isJailBroken { return NO; }
%end

%hook TTInstallUtil
+(bool)isJailBroken { return NO; }
%end

%hook AppsFlyerUtils
+(bool)isJailbrokenWithSkipAdvancedJailbreakValidation:(bool)arg2 { return NO; }
%end

%hook PIPOIAPStoreManager
-(bool)_pipo_isJailBrokenDeviceWithProductID:(id)arg2 orderID:(id)arg3 { return NO; }
%end

%hook IESLiveDeviceInfo
+(bool)isJailBroken { return NO; }
%end

%hook PIPOStoreKitHelper
-(bool)isJailBroken { return NO; }
%end

%hook BDInstallNetworkUtility
+(bool)isJailBroken { return NO; }
%end

%hook TTAdSplashDeviceHelper
+(bool)isJailBroken { return NO; }
%end

%hook GULAppEnvironmentUtil
+(bool)isFromAppStore { return YES; }
+(bool)isAppStoreReceiptSandbox { return NO; }
+(bool)isAppExtension { return YES; }
%end

%hook FBSDKAppEventsUtility
+(bool)isDebugBuild { return NO; }
%end

%hook AWEAPMManager
+(id)signInfo { return @"AppStore"; }
%end

%hook NSBundle
-(id)pathForResource:(id)arg1 ofType:(id)arg2 {
	if ([arg2 isEqualToString:@"mobileprovision"]) return nil;
	return %orig;
}
%end

%hook AWESecurity
- (void)resetCollectMode { return; }
%end

%hook MSManagerOV
- (id)setMode { return (id (^)(id)) ^{ }; }
%end

%hook MSConfigOV
- (id)setMode { return (id (^)(id)) ^{ }; }
%end


%ctor {
    jailbreakPaths = @[
        @"/Applications/Cydia.app", @"/Applications/blackra1n.app",
        @"/Applications/FakeCarrier.app", @"/Applications/Icy.app",
        @"/Applications/IntelliScreen.app", @"/Applications/MxTube.app",
        @"/Applications/RockApp.app", @"/Applications/SBSettings.app", @"/Applications/WinterBoard.app",
        @"/.cydia_no_stash", @"/.installed_unc0ver", @"/.bootstrapped_electra",
        @"/usr/libexec/cydia/firmware.sh", @"/usr/libexec/ssh-keysign", @"/usr/libexec/sftp-server",
        @"/usr/bin/ssh", @"/usr/bin/sshd", @"/usr/sbin/sshd",
        @"/var/lib/cydia", @"/var/lib/dpkg/info/mobilesubstrate.md5sums",
        @"/var/log/apt", @"/usr/share/jailbreak/injectme.plist", @"/usr/sbin/frida-server",
        @"/Library/MobileSubstrate/CydiaSubstrate.dylib", @"/Library/TweakInject",
        @"/Library/MobileSubstrate/MobileSubstrate.dylib", @"Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist", @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        @"/System/Library/LaunchDaemons/com.ikey.bbot.plist", @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist", @"/System/Library/CoreServices/SystemVersion.plist",
        @"/private/var/mobile/Library/SBSettings/Themes", @"/private/var/lib/cydia",
        @"/private/var/tmp/cydia.log", @"/private/var/log/syslog",
        @"/private/var/cache/apt/", @"/private/var/lib/apt",
        @"/private/var/Users/", @"/private/var/stash",
        @"/usr/lib/libjailbreak.dylib", @"/usr/lib/libz.dylib",
        @"/usr/lib/system/introspectionNSZombieEnabled",
        @"/usr/lib/dyld",
        @"/jb/amfid_payload.dylib", @"/jb/libjailbreak.dylib",
        @"/jb/jailbreakd.plist", @"/jb/offsets.plist",
        @"/jb/lzma",
        @"/hmd_tmp_file",
        @"/etc/ssh/sshd_config", @"/etc/apt/undecimus/undecimus.list",
        @"/etc/apt/sources.list.d/sileo.sources", @"/etc/apt/sources.list.d/electra.list",
        @"/etc/apt", @"/etc/ssl/certs", @"/etc/ssl/cert.pem",
        @"/bin/sh", @"/bin/bash",
    ];
    %init;
}
