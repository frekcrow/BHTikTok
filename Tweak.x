
#import "TikTokHeaders.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class BHDownload;

#pragma mark - Forward declarations (existing app classes we hook into)

@interface BHTikTokProgressView : UIView
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIImageView *statusImageView;
- (void)updateProgress:(CGFloat)progress;
- (void)showSuccess;
- (void)showError;
- (void)bh_resetAppearance;
@end

@interface TTKTabBarButton : UIControl
@end

@interface TTKProfileHeaderView : UIView
@property (nonatomic, weak) UIViewController *yy_viewController;
- (void)addHandleLongPress;
@end

@interface TTKEnlargeAvatarViewController : UIViewController
- (void)addHandleLongPress;
@end

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

@interface AWEFeedVideoButton (BHTikTok)
@property (nonatomic, assign) BOOL bh_confirmed;
- (void)_onTouchUpInside;
@end

@interface AWENewFeedTableViewController (BHTikTok)
- (void)setPureMode:(BOOL)arg1 withAnimated:(BOOL)arg2;
- (void)setPureMode:(BOOL)arg1;
@end

@interface AWEPlayPhotoAlbumViewController (BHTikTok)
- (NSUInteger)currentIndex;
- (id)model;
@end

@interface AWEAwemeModel (BHTikTok)
- (id)imageAlbumModel;
@end

#pragma mark - Shared UITableViewCell surface
//
// Every video/photo cell we care about (feed, detail, story) is a UITableViewCell
// subclass. Everything below is generic to "a cell that can show a download button,
// a hide-elements button, and a progress ring" — none of it depends on which concrete
// subclass it's attached to. Declaring + implementing it once here means a fix here
// fixes all three call sites instead of needing to be repeated three times.

@interface UITableViewCell (BHTikTok)
@property (nonatomic, strong) BHTikTokProgressView *bh_progressCircle;
@property (nonatomic, assign) BOOL bh_elementsHidden;
@property (nonatomic, retain) NSString *bh_fileExtension;
@property (nonatomic, strong) BHDownload *bh_downloadManager;
- (UIViewController *)viewController;
- (void)bh_addHideElementButton;
- (void)bh_installDownloadButtonWithMenu:(UIMenu *)menu fallbackAction:(SEL)fallbackAction;
- (void)bh_beginDownloadWithURL:(NSURL *)url fileExtension:(NSString *)extension;
@end

static void showConfirmation(void (^okHandler)(void)) {
    [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi"
                                description:@"Are you sure?"
                                      image:nil
                          actionButtonTitle:@"Yes"
                          cancelButtonTitle:@"No"
                                actionBlock:^{ okHandler(); }
                                cancelBlock:nil];
}

// Single source of truth for the download menu shown on every cell type.
// `downloadCurrentPhoto` / `downloadAllPhotos` are nil for cells that aren't showing
// a photo album (video posts), so those actions simply won't be added.
static UIMenu *BHBuildDownloadMenu(UITableViewCell *cell,
                                   AWEAwemeModel *model,
                                   BOOL includeMusicAction,
                                   void (^downloadCurrentPhoto)(void),
                                   void (^downloadAllPhotos)(void)) {
    if (!model) return nil;
    NSMutableArray<UIMenuElement *> *actions = [NSMutableArray array];

    [actions addObject:[UIAction actionWithTitle:@"Download video"
                                            image:[UIImage systemImageNamed:@"video"]
                                       identifier:nil
                                          handler:^(__kindof UIAction *action) {
        NSURL *url = [model.video.playURL bestURLtoDownload];
        NSString *ext = [model.video.playURL bestURLtoDownloadFormat];
        [cell bh_beginDownloadWithURL:url fileExtension:ext];
    }]];

    if (includeMusicAction && model.music) {
        [actions addObject:[UIAction actionWithTitle:@"Download music"
                                                image:[UIImage systemImageNamed:@"music.note"]
                                           identifier:nil
                                              handler:^(__kindof UIAction *action) {
            AWEMusicModel *music = (AWEMusicModel *)model.music;
            NSURL *url = [music.playURL bestURLtoDownload];
            NSString *ext = [music.playURL bestURLtoDownloadFormat];
            [cell bh_beginDownloadWithURL:url fileExtension:ext];
        }]];
    }

    [actions addObject:[UIAction actionWithTitle:@"Copy description"
                                            image:[UIImage systemImageNamed:@"doc.on.doc"]
                                       identifier:nil
                                          handler:^(__kindof UIAction *action) {
        NSString *description = [model music_songName] ?: @"BHTikTok Options";
        [UIPasteboard generalPasteboard].string = description;
    }]];

    [actions addObject:[UIAction actionWithTitle:@"Copy video link"
                                            image:[UIImage systemImageNamed:@"link"]
                                       identifier:nil
                                          handler:^(__kindof UIAction *action) {
        NSURL *url = [model.video.playURL bestURLtoDownload];
        if (url) [UIPasteboard generalPasteboard].string = url.absoluteString;
    }]];

    if (downloadCurrentPhoto) {
        [actions addObject:[UIAction actionWithTitle:@"Download this photo"
                                                image:[UIImage systemImageNamed:@"photo"]
                                           identifier:nil
                                              handler:^(__kindof UIAction *action) {
            downloadCurrentPhoto();
        }]];
    }

    if (downloadAllPhotos) {
        [actions addObject:[UIAction actionWithTitle:@"Download all photos"
                                                image:[UIImage systemImageNamed:@"square.stack"]
                                           identifier:nil
                                              handler:^(__kindof UIAction *action) {
            downloadAllPhotos();
        }]];
    }

    return [UIMenu menuWithTitle:@"BHTikTok" children:actions];
}

%hook UITableViewCell

%property (nonatomic, strong) BHTikTokProgressView *bh_progressCircle;
%property (nonatomic, assign) BOOL bh_elementsHidden;
%property (nonatomic, retain) NSString *bh_fileExtension;
%property (nonatomic, strong) BHDownload *bh_downloadManager;

%new - (void)bh_addHideElementButton {
    UIButton *hideElementButton = [self.contentView viewWithTag:999];
    if (!hideElementButton) {
        hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
        hideElementButton.tag = 999;
        hideElementButton.translatesAutoresizingMaskIntoConstraints = NO;
        [hideElementButton addTarget:self action:@selector(bh_hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        hideElementButton.tintColor = [UIColor whiteColor];

        [self.contentView addSubview:hideElementButton];
        [self.contentView bringSubviewToFront:hideElementButton];

        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:35],
            [hideElementButton.heightAnchor constraintEqualToConstant:35],
        ]];
    }
    [hideElementButton setImage:[UIImage systemImageNamed:self.bh_elementsHidden ? @"eye.fill" : @"eye.slash.fill"]
                        forState:UIControlStateNormal];
}

%new - (void)bh_hideElementButtonHandler:(UIButton *)sender {
    self.bh_elementsHidden = !self.bh_elementsHidden;
    [sender setImage:[UIImage systemImageNamed:self.bh_elementsHidden ? @"eye.fill" : @"eye.slash.fill"]
             forState:UIControlStateNormal];

    // Some feed containers expose a first-class "pure mode" API — prefer that over
    // manually fading subviews, since it's what the app itself uses.
    id rootVC = [self respondsToSelector:@selector(viewController)] ? [self performSelector:@selector(viewController)] : nil;
    if ([rootVC isKindOfClass:%c(AWENewFeedTableViewController)]) {
        AWENewFeedTableViewController *feedVC = (AWENewFeedTableViewController *)rootVC;
        if ([feedVC respondsToSelector:@selector(setPureMode:withAnimated:)]) {
            [feedVC setPureMode:self.bh_elementsHidden withAnimated:YES];
            return;
        } else if ([feedVC respondsToSelector:@selector(setPureMode:)]) {
            [feedVC setPureMode:self.bh_elementsHidden];
            return;
        }
    }

    [UIView animateWithDuration:0.3 animations:^{
        NSArray<UIView *> *subviews = self.contentView.subviews;
        for (UIView *view in subviews) {
            if (view.tag == 999 || view.tag == 998) continue;
            if (view == subviews.firstObject) continue; // skip the player/media layer
            NSString *className = NSStringFromClass([view class]);
            if ([className containsString:@"Video"] || [className containsString:@"Player"]) continue;
            view.alpha = self.bh_elementsHidden ? 0.0 : 1.0;
        }
    }];
}

%new - (void)bh_installDownloadButtonWithMenu:(UIMenu *)menu fallbackAction:(SEL)fallbackAction {
    UIButton *downloadButton = [self.contentView viewWithTag:998];
    if (!downloadButton) {
        downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        downloadButton.tag = 998;
        downloadButton.translatesAutoresizingMaskIntoConstraints = NO;
        [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
        downloadButton.tintColor = [UIColor whiteColor];

        if (@available(iOS 14.0, *)) {
            downloadButton.showsMenuAsPrimaryAction = YES;
        } else if (fallbackAction) {
            [downloadButton addTarget:self action:fallbackAction forControlEvents:UIControlEventTouchUpInside];
        }

        [self.contentView addSubview:downloadButton];
        [self.contentView bringSubviewToFront:downloadButton];

        UIView *hideButton = [self.contentView viewWithTag:999];
        NSLayoutConstraint *topConstraint = hideButton
            ? [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15]
            : [downloadButton.topAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.topAnchor constant:50];

        [NSLayoutConstraint activateConstraints:@[
            topConstraint,
            [downloadButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [downloadButton.widthAnchor constraintEqualToConstant:35],
            [downloadButton.heightAnchor constraintEqualToConstant:35],
        ]];
    }

    if (@available(iOS 14.0, *)) {
        downloadButton.menu = menu;
    }
}

%new - (void)bh_beginDownloadWithURL:(NSURL *)url fileExtension:(NSString *)extension {
    if (!url) return;

    self.bh_fileExtension = extension;
    self.bh_downloadManager = [[BHDownload alloc] init];
    [self.bh_downloadManager setDelegate:self];
    [self.bh_downloadManager downloadFileWithURL:url];

    if (!self.bh_progressCircle) {
        self.bh_progressCircle = [[BHTikTokProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.bh_progressCircle.center = self.contentView.center;
    }
    [self.bh_progressCircle bh_resetAppearance];
    [self.contentView addSubview:self.bh_progressCircle];
    [self.contentView bringSubviewToFront:self.bh_progressCircle];
}

// BHDownload delegate callbacks — single-file variant.
%new - (void)downloadProgress:(float)progress {
    [self.bh_progressCircle updateProgress:progress];
}

%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bh_progressCircle showSuccess];

        NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        NSURL *destination = [[NSURL fileURLWithPath:docPath]
            URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.bh_fileExtension]];
        [[NSFileManager defaultManager] moveItemAtURL:filePath toURL:destination error:nil];

        [BHIManager showSaveVC:@[destination]];
    });
}

%new - (void)downloadDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) [self.bh_progressCircle showError];
    });
}

// BHDownload delegate callbacks — batch variant (used for "download all photos").
%new - (void)downloaderProgress:(float)progress {
    [self.bh_progressCircle updateProgress:progress];
}

%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.bh_progressCircle showSuccess];
        [BHIManager showSaveVC:downloadedFilePaths];
    });
}

%new - (void)downloaderDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) [self.bh_progressCircle showError];
    });
}

%end

#pragma mark - BHTikTokProgressView

@implementation BHTikTokProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.7];
        self.layer.cornerRadius = frame.size.width / 2;
        self.clipsToBounds = YES;

        UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(frame.size.width / 2, frame.size.height / 2)
                                                                    radius:(frame.size.width / 2) - 4
                                                                startAngle:-M_PI_2
                                                                  endAngle:M_PI_2 * 3
                                                                 clockwise:YES];

        CAShapeLayer *trackLayer = [CAShapeLayer layer];
        trackLayer.path = circlePath.CGPath;
        trackLayer.strokeColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor;
        trackLayer.fillColor = [UIColor clearColor].CGColor;
        trackLayer.lineWidth = 3.0;
        [self.layer addSublayer:trackLayer];

        self.progressLayer = [CAShapeLayer layer];
        self.progressLayer.path = circlePath.CGPath;
        self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
        self.progressLayer.fillColor = [UIColor clearColor].CGColor;
        self.progressLayer.lineWidth = 3.0;
        self.progressLayer.strokeEnd = 0.0;
        self.progressLayer.lineCap = kCALineCapRound;
        [self.layer addSublayer:self.progressLayer];

        self.statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width * 0.5, frame.size.height * 0.5)];
        self.statusImageView.center = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        self.statusImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.statusImageView.tintColor = [UIColor whiteColor];
        self.statusImageView.hidden = YES;
        [self addSubview:self.statusImageView];
    }
    return self;
}

// Restores the view to a clean, pre-download state. Call this before kicking off a
// new download on a reused progress circle — otherwise a previous error (red stroke)
// stays visible even after a subsequent successful download.
- (void)bh_resetAppearance {
    self.progressLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.progressLayer.strokeEnd = 0.0;
    self.progressLayer.hidden = NO;
    self.statusImageView.hidden = YES;
    self.hidden = NO;
}

- (void)updateProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.statusImageView.hidden = YES;
        self.progressLayer.strokeEnd = progress;
    });
}

- (void)showSuccess {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLayer.hidden = YES;
        self.statusImageView.image = [UIImage systemImageNamed:@"checkmark"];
        self.statusImageView.tintColor = [UIColor whiteColor];
        self.statusImageView.hidden = NO;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    });
}

- (void)showError {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLayer.strokeColor = [UIColor redColor].CGColor;
        self.progressLayer.strokeEnd = 1.0;
        self.progressLayer.hidden = NO;
        self.statusImageView.image = [UIImage systemImageNamed:@"xmark"];
        self.statusImageView.tintColor = [UIColor redColor];
        self.statusImageView.hidden = NO;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeFromSuperview];
        });
    });
}
@end

#pragma mark - App lifecycle

static BOOL isAuthenticationShowed = NO;

%hook AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(id)arg2 {
    BOOL result = %orig;

    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"BHTikTokFirstRun"]) {
        NSDictionary<NSString *, NSNumber *> *defaults = @{
            @"hide_ads": @YES,
            @"dw_videos": @YES,
            @"dw_musics": @YES,
            @"remove_elements_button": @YES,
            @"copy_decription": @YES,
            @"copy_video_link": @YES,
            @"copy_music_link": @YES,
            @"show_porgress_bar": @YES,
            @"save_profile": @YES,
            @"copy_profile_information": @YES,
            @"extended_bio": @YES,
            @"extendedComment": @YES,
        };
        [defaults enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSNumber *value, BOOL *stop) {
            [[NSUserDefaults standardUserDefaults] setBool:value.boolValue forKey:key];
        }];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"BHTikTokFirstRun"];
    }

    [BHIManager cleanCache];
    return result;
}

- (void)applicationDidBecomeActive:(id)arg1 {
    %orig;
    if ([BHIManager appLock] && !isAuthenticationShowed) {
        UIViewController *rootController = self.window.rootViewController;
        SecurityViewController *securityViewController = [SecurityViewController new];
        securityViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [rootController presentViewController:securityViewController animated:YES completion:nil];
        isAuthenticationShowed = YES;
    }
}

- (void)applicationWillEnterForeground:(id)arg1 {
    %orig;
    isAuthenticationShowed = NO;
}
%end

#pragma mark - Settings entry point (long-press the profile tab)

%hook TTKTabBarButton
- (void)layoutSubviews {
    %orig;
    BOOL hasLongPress = NO;
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            hasLongPress = YES;
            break;
        }
    }

    if (!hasLongPress) {
        NSString *label = self.accessibilityLabel ?: @"";
        NSArray<NSString *> *profileLabels = @[@"Profile", @"الملف الشخصي", @"Me", @"أنا"];
        BOOL isProfileTab = NO;
        for (NSString *candidate in profileLabels) {
            if ([label containsString:candidate]) { isProfileTab = YES; break; }
        }
        if (isProfileTab) {
            UILongPressGestureRecognizer *longPress =
                [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bh_openSettings:)];
            longPress.minimumPressDuration = 0.5;
            [self addGestureRecognizer:longPress];
        }
    }
}

%new - (void)bh_openSettings:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    UINavigationController *settingsNav =
        [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
    UIViewController *topVC = topMostController();
    [topVC presentViewController:settingsNav animated:YES completion:nil];
}
%end

#pragma mark - In-app browser redirect

%hook SparkViewController
- (void)viewWillAppear:(BOOL)animated {
    if (![BHIManager alwaysOpenSafari]) {
        %orig;
        return;
    }

    NSURLComponents *components = [NSURLComponents componentsWithURL:self.originURL resolvingAgainstBaseURL:NO];
    NSString *externalURLString = nil;
    for (NSURLQueryItem *item in components.queryItems) {
        if ([item.name isEqualToString:@"url"]) {
            externalURLString = item.value;
            break;
        }
    }

    if (externalURLString) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:externalURLString] options:@{} completionHandler:nil];
        [self didTapCloseButton];
    } else {
        %orig;
    }
}
%end

#pragma mark - Region spoofing

%hook CTCarrier
- (NSString *)mobileCountryCode {
    if ([BHIManager regionChangingEnabled] && [BHIManager selectedRegion]) {
        return [BHIManager selectedRegion][@"mcc"];
    }
    return %orig;
}
- (void)setIsoCountryCode:(NSString *)arg1 {
    if ([BHIManager regionChangingEnabled] && [BHIManager selectedRegion]) {
        %orig([BHIManager selectedRegion][@"code"]);
        return;
    }
    %orig(arg1);
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

#pragma mark - Feed content behaviour (ads, progress bar, autoplay, fake counts, text limits)

%hook AWEAwemeModel
- (id)initWithDictionary:(id)arg1 error:(id *)arg2 {
    id result = %orig;
    return ([BHIManager hideAds] && self.isAds) ? nil : result;
}
- (id)init {
    id result = %orig;
    return ([BHIManager hideAds] && self.isAds) ? nil : result;
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
    if ([BHIManager autoPlay] && [self.container.parentViewController isKindOfClass:%c(AWENewFeedTableViewController)]) {
        [(AWENewFeedTableViewController *)self.container.parentViewController scrollToNextVideo];
        return;
    }
    %orig;
}
%end

%hook AWEUserModel
- (NSNumber *)followerCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fake = [[NSUserDefaults standardUserDefaults] stringForKey:@"follower_count"];
        if (fake.length > 0) return @(fake.integerValue);
    }
    return %orig;
}
- (NSNumber *)followingCount {
    if ([BHIManager fakeChangesEnabled]) {
        NSString *fake = [[NSUserDefaults standardUserDefaults] stringForKey:@"following_count"];
        if (fake.length > 0) return @(fake.integerValue);
    }
    return %orig;
}
- (BOOL)isVerifiedUser {
    return [BHIManager fakeVerified] ?: %orig;
}
%end

%hook AWETextInputController
- (NSUInteger)maxLength {
    return [BHIManager extendedComment] ? 240 : %orig;
}
%end

%hook AWEProfileEditTextViewController
- (NSInteger)maxTextLength {
    return [BHIManager extendedBio] ? 222 : %orig;
}
%end

#pragma mark - Confirmation dialogs (follow / like / dislike)

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

#pragma mark - Profile picture / avatar saving

%hook TTKProfileHeaderView
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if (self && [BHIManager profileCopy]) {
        [self addHandleLongPress];
    }
    return self;
}
%end

%hook TTKEnlargeAvatarViewController
- (void)viewDidLoad {
    %orig;
    if ([BHIManager profileSave]) {
        [self addHandleLongPress];
    }
}

%new - (void)addHandleLongPress {
    UILongPressGestureRecognizer *longPress =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bh_handleLongPress:)];
    longPress.minimumPressDuration = 0.3;
    [self.view addGestureRecognizer:longPress];
}

%new - (void)bh_handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) return;
    UIImageView *imageView = [self valueForKey:@"avatarImageView"];
    if (imageView.image) {
        [BHIManager showSaveVC:@[imageView.image]];
    }
}
%end

#pragma mark - Feed cell (main "For You" feed)

@interface AWEFeedViewCell (BHTikTok)
- (UIViewController *)viewController;
- (UIViewController *)bh_getPhotoAlbumViewController;
- (AWEAwemeModel *)bh_currentAwemeModel;
- (NSURL *)bh_urlForAlbumItem:(id)item;
- (NSArray *)bh_currentAlbumItems;
- (void)bh_downloadCurrentPhotoAction;
- (void)bh_downloadAllPhotosAction;
- (void)bh_downloadVideoAction;
- (void)bh_refreshOverlayButtons;
@end

%hook AWEFeedViewCell

- (void)configWithModel:(id)model {
    %orig;
    [self bh_refreshOverlayButtons];
}

- (void)configureWithModel:(id)model {
    %orig;
    [self bh_refreshOverlayButtons];
}

%new - (AWEAwemeModel *)bh_currentAwemeModel {
    return [self respondsToSelector:@selector(model)]
        ? [self valueForKey:@"model"]
        : [self valueForKey:@"aweme"];
}

%new - (UIViewController *)bh_getPhotoAlbumViewController {
    UIViewController *rootVC = [self respondsToSelector:@selector(viewController)] ? [self performSelector:@selector(viewController)] : nil;
    for (UIViewController *child in rootVC.childViewControllers) {
        if ([child isKindOfClass:%c(AWEPlayPhotoAlbumViewController)]) return child;
    }
    return nil;
}

// TODO: adjust this to match the real property on your photo-item model. The
// original draft only had access to `imageAlbumItems`, a plain array, without a
// known accessor for a single item's downloadable URL. If your header exposes e.g.
// `-(AWEURLModel *)urlList` or `-(NSString *)downloadURL` on each item, plug it in
// here — this is the one place it needs to change.
%new - (NSURL *)bh_urlForAlbumItem:(id)item {
    if ([item respondsToSelector:@selector(urlList)]) {
        AWEURLModel *urlModel = [item performSelector:@selector(urlList)];
        return [urlModel bestURLtoDownload];
    }
    if ([item respondsToSelector:@selector(downloadURL)]) {
        return [item performSelector:@selector(downloadURL)];
    }
    return nil;
}

%new - (NSArray *)bh_currentAlbumItems {
    AWEPlayPhotoAlbumViewController *albumVC = (AWEPlayPhotoAlbumViewController *)[self bh_getPhotoAlbumViewController];
    if (!albumVC) return nil;
    id videoModel = [albumVC model];
    id imageAlbum = [videoModel respondsToSelector:@selector(imageAlbumModel)] ? [videoModel performSelector:@selector(imageAlbumModel)] : nil;
    return [imageAlbum respondsToSelector:@selector(imageAlbumItems)] ? [imageAlbum performSelector:@selector(imageAlbumItems)] : nil;
}

%new - (void)bh_downloadCurrentPhotoAction {
    AWEPlayPhotoAlbumViewController *albumVC = (AWEPlayPhotoAlbumViewController *)[self bh_getPhotoAlbumViewController];
    NSArray *items = [self bh_currentAlbumItems];
    if (!albumVC || !items) return;

    NSUInteger index = [albumVC currentIndex];
    if (index >= items.count) return;

    NSURL *url = [self bh_urlForAlbumItem:items[index]];
    if (!url) return;
    [self bh_beginDownloadWithURL:url fileExtension:(url.pathExtension.length ? url.pathExtension : @"jpeg")];
}

%new - (void)bh_downloadAllPhotosAction {
    NSArray *items = [self bh_currentAlbumItems];
    if (!items.count) return;

    NSMutableArray<NSURL *> *urls = [NSMutableArray arrayWithCapacity:items.count];
    for (id item in items) {
        NSURL *url = [self bh_urlForAlbumItem:item];
        if (url) [urls addObject:url];
    }
    if (!urls.count) return;

    self.bh_fileExtension = urls.firstObject.pathExtension.length ? urls.firstObject.pathExtension : @"jpeg";
    self.bh_downloadManager = [[BHDownload alloc] init];
    [self.bh_downloadManager setDelegate:self];
    // BHDownload is assumed (per the original header usage) to expose a batch entry
    // point alongside -downloadFileWithURL:. Adjust the selector name if yours differs.
    if ([self.bh_downloadManager respondsToSelector:@selector(downloadFilesWithURLs:)]) {
        [self.bh_downloadManager performSelector:@selector(downloadFilesWithURLs:) withObject:urls];
    }

    if (!self.bh_progressCircle) {
        self.bh_progressCircle = [[BHTikTokProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.bh_progressCircle.center = self.contentView.center;
    }
    [self.bh_progressCircle bh_resetAppearance];
    [self.contentView addSubview:self.bh_progressCircle];
    [self.contentView bringSubviewToFront:self.bh_progressCircle];
}

%new - (void)bh_downloadVideoAction {
    AWEAwemeModel *model = [self bh_currentAwemeModel];
    NSURL *url = [model.video.playURL bestURLtoDownload];
    NSString *ext = [model.video.playURL bestURLtoDownloadFormat];
    [self bh_beginDownloadWithURL:url fileExtension:ext];
}

%new - (void)bh_refreshOverlayButtons {
    self.bh_elementsHidden = NO;

    if ([BHIManager hideElementButton]) {
        [self bh_addHideElementButton];
    }

    if ([BHIManager downloadVideos]) {
        AWEAwemeModel *model = [self bh_currentAwemeModel];
        BOOL isPhotoPost = [self bh_currentAlbumItems].count > 0;

        UIMenu *menu = BHBuildDownloadMenu(self, model, /*includeMusic=*/YES,
            isPhotoPost ? ^{ [self bh_downloadCurrentPhotoAction]; } : nil,
            isPhotoPost ? ^{ [self bh_downloadAllPhotosAction]; } : nil);

        [self bh_installDownloadButtonWithMenu:menu fallbackAction:@selector(bh_downloadVideoAction)];
    }
}
%end

#pragma mark - Detail view cell (single-video "detail" screen)

@interface AWEAwemeDetailTableViewCell (BHTikTok)
- (UIViewController *)viewController;
- (AWEAwemeModel *)bh_currentAwemeModel;
- (void)bh_downloadVideoAction;
- (void)bh_refreshOverlayButtons;
@end

%hook AWEAwemeDetailTableViewCell

- (void)configWithModel:(id)model {
    %orig;
    [self bh_refreshOverlayButtons];
}

- (void)configureWithModel:(id)model {
    %orig;
    [self bh_refreshOverlayButtons];
}

%new - (AWEAwemeModel *)bh_currentAwemeModel {
    if (![self.viewController isKindOfClass:%c(AWEAwemeDetailCellViewController)]) return nil;
    return ((AWEAwemeDetailCellViewController *)self.viewController).model;
}

%new - (void)bh_downloadVideoAction {
    AWEAwemeModel *model = [self bh_currentAwemeModel];
    NSURL *url = [model.video.playURL bestURLtoDownload];
    NSString *ext = [model.video.playURL bestURLtoDownloadFormat];
    [self bh_beginDownloadWithURL:url fileExtension:ext];
}

%new - (void)bh_refreshOverlayButtons {
    self.bh_elementsHidden = NO;

    if ([BHIManager hideElementButton]) {
        [self bh_addHideElementButton];
    }

    if ([BHIManager downloadVideos]) {
        AWEAwemeModel *model = [self bh_currentAwemeModel];
        UIMenu *menu = BHBuildDownloadMenu(self, model, /*includeMusic=*/YES, nil, nil);
        [self bh_installDownloadButtonWithMenu:menu fallbackAction:@selector(bh_downloadVideoAction)];
    }
}
%end

#pragma mark - Story detail cell

@interface TTKStoryDetailTableViewCell (BHTikTok)
- (UIViewController *)viewController;
- (AWEAwemeModel *)bh_currentAwemeModel;
- (void)bh_downloadVideoAction;
- (void)bh_refreshOverlayButtons;
@end

%hook TTKStoryDetailTableViewCell

- (void)configWithModel:(id)model {
    %orig;
    [self bh_refreshOverlayButtons];
}

- (void)configureWithModel:(id)model {
    %orig;
    [self bh_refreshOverlayButtons];
}

%new - (AWEAwemeModel *)bh_currentAwemeModel {
    if (![self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) return nil;
    return [self.viewController valueForKeyPath:@"model.currentPlayingStory"];
}

%new - (void)bh_downloadVideoAction {
    AWEAwemeModel *model = [self bh_currentAwemeModel];
    NSURL *url = [model.video.playURL bestURLtoDownload];
    NSString *ext = [model.video.playURL bestURLtoDownloadFormat];
    [self bh_beginDownloadWithURL:url fileExtension:ext];
}

%new - (void)bh_refreshOverlayButtons {
    self.bh_elementsHidden = NO;

    if ([BHIManager hideElementButton]) {
        [self bh_addHideElementButton];
    }

    if ([BHIManager downloadVideos]) {
        AWEAwemeModel *model = [self bh_currentAwemeModel];
        UIMenu *menu = BHBuildDownloadMenu(self, model, /*includeMusic=*/YES, nil, nil);
        [self bh_installDownloadButtonWithMenu:menu fallbackAction:@selector(bh_downloadVideoAction)];
    }
}
%end

#pragma mark - URL helpers

%hook AWEURLModel
%new - (NSString *)bestURLtoDownloadFormat {
    NSString *format;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"]) format = @"mp4";
        else if ([url containsString:@".jpeg"]) format = @"jpeg";
        else if ([url containsString:@".png"]) format = @"png";
        else if ([url containsString:@".mp3"]) format = @"mp3";
        else if ([url containsString:@".m4a"]) format = @"m4a";
    }
    return format ?: @"m4a";
}

%new - (NSURL *)bestURLtoDownload {
    NSString *bestURLString;
    for (NSString *url in self.originURLList) {
        if ([url containsString:@"video_mp4"] || [url containsString:@".jpeg"] || [url containsString:@".mp3"]) {
            bestURLString = url;
        }
    }
    bestURLString = bestURLString ?: self.originURLList.firstObject;
    return bestURLString ? [NSURL URLWithString:bestURLString] : nil;
}
%end

#pragma mark - Jailbreak detection bypass

static NSArray<NSString *> *jailbreakPaths;

%hook NSFileManager
- (BOOL)fileExistsAtPath:(NSString *)path {
    if ([jailbreakPaths containsObject:path]) return NO;
    return %orig;
}
- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory {
    if ([jailbreakPaths containsObject:path]) return NO;
    return %orig;
}
%end

%hook BDADeviceHelper
+ (BOOL)isJailBroken { return NO; }
%end

%hook UIDevice
+ (BOOL)btd_isJailBroken { return NO; }
%end

%hook TTInstallUtil
+ (BOOL)isJailBroken { return NO; }
%end

%hook AppsFlyerUtils
+ (BOOL)isJailbrokenWithSkipAdvancedJailbreakValidation:(BOOL)skip { return NO; }
%end

%hook PIPOIAPStoreManager
- (BOOL)_pipo_isJailBrokenDeviceWithProductID:(id)productID orderID:(id)orderID { return NO; }
%end

%hook IESLiveDeviceInfo
+ (BOOL)isJailBroken { return NO; }
%end

%hook PIPOStoreKitHelper
- (BOOL)isJailBroken { return NO; }
%end

%hook BDInstallNetworkUtility
+ (BOOL)isJailBroken { return NO; }
%end

%hook TTAdSplashDeviceHelper
+ (BOOL)isJailBroken { return NO; }
%end

%hook GULAppEnvironmentUtil
+ (BOOL)isFromAppStore { return YES; }
+ (BOOL)isAppStoreReceiptSandbox { return NO; }
+ (BOOL)isAppExtension { return YES; }
%end

%hook FBSDKAppEventsUtility
+ (BOOL)isDebugBuild { return NO; }
%end

%hook AWEAPMManager
+ (id)signInfo { return @"AppStore"; }
%end

%hook NSBundle
- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)type {
    if ([type isEqualToString:@"mobileprovision"]) return nil;
    return %orig;
}
%end

%hook AWESecurity
- (void)resetCollectMode { /* no-op */ }
%end

%hook MSManagerOV
- (id)setMode { return nil; }
%end

%hook MSConfigOV
- (id)setMode { return nil; }
%end

#pragma mark - Constructor

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
        @"/Library/MobileSubstrate/MobileSubstrate.dylib",
        @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist", @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
        @"/System/Library/LaunchDaemons/com.ikey.bbot.plist", @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
        @"/System/Library/CoreServices/SystemVersion.plist",
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
