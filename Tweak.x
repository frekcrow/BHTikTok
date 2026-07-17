#import "TikTokHeaders.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class BHDownload;

@interface BHTikTokProgressView : UIView
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UIImageView *statusImageView;
- (void)updateProgress:(CGFloat)progress;
- (void)showSuccess;
- (void)showError;
@end

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

@interface AWEFeedViewCell (BHTikTok)
@property (nonatomic, strong) BHTikTokProgressView *progressCircle;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) NSString *fileextension;
@property (nonatomic, strong) BHDownload *downloadManager;
- (void)addDownloadButton;
- (void)bh_downloadVideoAction;
- (void)bh_downloadCurrentPhotoAction;
- (void)bh_downloadAllPhotosAction;
- (UIMenu *)bh_buildDownloadMenu;
- (void)addHideElementButton;
- (UIViewController *)viewController;
- (UIViewController *)bh_getPhotoAlbumViewController;
@end

@interface AWEAwemeDetailTableViewCell (BHTikTok)
@property (nonatomic, strong) BHTikTokProgressView *progressCircle;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) NSString *fileextension;
@property (nonatomic, strong) BHDownload *downloadManager;
- (void)addDownloadButton;
- (void)bh_downloadVideoAction;
- (UIMenu *)bh_buildDownloadMenu;
- (void)addHideElementButton;
- (UIViewController *)viewController;
@end

@interface TTKStoryDetailTableViewCell (BHTikTok)
@property (nonatomic, strong) BHTikTokProgressView *progressCircle;
@property (nonatomic, assign) BOOL elementsHidden;
@property (nonatomic, retain) NSString *fileextension;
@property (nonatomic, strong) BHDownload *downloadManager;
- (void)addDownloadButton;
- (void)bh_downloadVideoAction;
- (UIMenu *)bh_buildDownloadMenu;
- (void)addHideElementButton;
- (UIViewController *)viewController;
@end

@interface AWENewFeedTableViewController : UIViewController
- (void)setPureMode:(BOOL)arg1 withAnimated:(BOOL)arg2;
- (void)setPureMode:(BOOL)arg1;
@end

@interface AWEPlayPhotoAlbumViewController : UIViewController
- (NSUInteger)currentIndex;
- (id)model; 
@end

@interface AWEAwemeModel : NSObject
- (id)imageAlbumModel; 
@end

NSArray *jailbreakPaths;

static void showConfirmation(void (^okHandler)(void)) {
  [%c(AWEUIAlertView) showAlertWithTitle:@"BHTikTok, Hi" description:@"Are you sure?" image:nil actionButtonTitle:@"Yes" cancelButtonTitle:@"No" actionBlock:^{
    okHandler();
  } cancelBlock:nil];
}

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
    BOOL hasLongPress = NO;
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
            hasLongPress = YES;
            break;
        }
    }
    
    if (!hasLongPress) {
        NSString *label = self.accessibilityLabel;
        if ([label containsString:@"Profile"] || [label containsString:@"الملف الشخصي"] || [label containsString:@"Me"] || [label containsString:@"أنا"]) {
            UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(bh_openSettings:)];
            longPress.minimumPressDuration = 0.5; 
            [self addGestureRecognizer:longPress];
        }
    }
}

%new
- (void)bh_openSettings:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        UINavigationController *BHTikTokSettings = [[UINavigationController alloc] initWithRootViewController:[[SettingsViewController alloc] init]];
        UIViewController *topVC = topMostController();
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

%hook TTKProfileHeaderView 
- (id)initWithFrame:(CGRect)arg1 {
    self = %orig;
    if ([BHIManager profileCopy]) {
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

%hook AWEFeedViewCell 
%property (nonatomic, strong) BHTikTokProgressView *progressCircle;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
%property (nonatomic, strong) BHDownload *downloadManager;

- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton]; 
}

- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton]; 
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [self.contentView viewWithTag:998];
    if (!downloadButton) {
        downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [downloadButton setTag:998];
        [downloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
        [downloadButton setTintColor:[UIColor whiteColor]];
        
        if (@available(iOS 14.0, *)) {
            downloadButton.showsMenuAsPrimaryAction = YES;
        } else {
            [downloadButton addTarget:self action:@selector(bh_downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.contentView addSubview:downloadButton];
        [self.contentView bringSubviewToFront:downloadButton];
        
        UIView *hideButton = [self.contentView viewWithTag:999];
        if (hideButton) {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:35],
                [downloadButton.heightAnchor constraintEqualToConstant:35],
            ]];
        }
    }
    
    if (@available(iOS 14.0, *)) {
        downloadButton.menu = [self bh_buildDownloadMenu];
    }
}

%new - (UIMenu *)bh_buildDownloadMenu {
    if (![self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) return nil;
    id rootVC = self.viewController;
    
    // استخدام valueForKeyPath لتخطي خطأ المترجم
    AWEAwemeModel *videoModel = [rootVC valueForKeyPath:@"model.currentPlayingStory"];
    
    NSMutableArray *actions = [NSMutableArray array];

    UIAction *downloadVideo = [UIAction actionWithTitle:@"Download video" image:[UIImage systemImageNamed:@"video"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self bh_downloadVideoAction]; 
    }];
    [actions addObject:downloadVideo];

    UIAction *copyDesc = [UIAction actionWithTitle:@"Copy description" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSString *video_description = [videoModel music_songName] ?: @"BHTikTok Options";
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    }];
    [actions addObject:copyDesc];

    return [UIMenu menuWithTitle:@"BHTikTok" children:actions];
}

%new - (UIViewController *)bh_getPhotoAlbumViewController {
    UIViewController *rootVC = [self respondsToSelector:@selector(viewController)] ? [self performSelector:@selector(viewController)] : nil;
    if (rootVC) {
        for (UIViewController *child in rootVC.childViewControllers) {
            if ([child isKindOfClass:%c(AWEPlayPhotoAlbumViewController)]) {
                return child;
            }
        }
    }
    return nil;
}

%new - (void)bh_downloadCurrentPhotoAction {
    AWEPlayPhotoAlbumViewController *albumVC = (AWEPlayPhotoAlbumViewController *)[self bh_getPhotoAlbumViewController];
    if (albumVC) {
        NSUInteger currentIndex = [albumVC currentIndex];
        id videoModel = [albumVC model];
        id imageAlbum = [videoModel respondsToSelector:@selector(imageAlbumModel)] ? [videoModel performSelector:@selector(imageAlbumModel)] : nil;
        NSArray *imagesArray = [imageAlbum respondsToSelector:@selector(imageAlbumItems)] ? [imageAlbum performSelector:@selector(imageAlbumItems)] : nil;
        
        if (imagesArray && currentIndex < imagesArray.count) {
            NSLog(@"BHTikTok: Ready to download single photo at index %lu", (unsigned long)currentIndex);
        }
    }
}

%new - (void)bh_downloadAllPhotosAction {
    AWEPlayPhotoAlbumViewController *albumVC = (AWEPlayPhotoAlbumViewController *)[self bh_getPhotoAlbumViewController];
    if (albumVC) {
        id videoModel = [albumVC model];
        id imageAlbum = [videoModel respondsToSelector:@selector(imageAlbumModel)] ? [videoModel performSelector:@selector(imageAlbumModel)] : nil;
        NSArray *imagesArray = [imageAlbum respondsToSelector:@selector(imageAlbumItems)] ? [imageAlbum performSelector:@selector(imageAlbumItems)] : nil;
        
        if (imagesArray && imagesArray.count > 0) {
            NSLog(@"BHTikTok: Ready to download ALL %lu photos", (unsigned long)imagesArray.count);
        }
    }
}

%new - (void)bh_downloadVideoAction {
    AWEAwemeModel *videoModel = [self respondsToSelector:@selector(model)] ? [self valueForKey:@"model"] : [self valueForKey:@"aweme"];
    NSURL *downloadableURL = [videoModel.video.playURL bestURLtoDownload];
    self.fileextension = [videoModel.video.playURL bestURLtoDownloadFormat];
    
    if (downloadableURL) {
        self.downloadManager = [[BHDownload alloc] init];
		[self.downloadManager downloadFileWithURL:downloadableURL];
		[self.downloadManager setDelegate:self];
        
        if (!self.progressCircle) {
            self.progressCircle = [[BHTikTokProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            self.progressCircle.center = self.contentView.center;
        }
        self.progressCircle.progressLayer.hidden = NO;
        self.progressCircle.statusImageView.hidden = YES;
        [self.progressCircle updateProgress:0.0];
        [self.contentView addSubview:self.progressCircle];
        [self.contentView bringSubviewToFront:self.progressCircle];
    }
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [self.contentView viewWithTag:999];
    if (!hideElementButton) {
        hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hideElementButton setTag:999];
        [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [hideElementButton setTintColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:hideElementButton];
        [self.contentView bringSubviewToFront:hideElementButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:35],
            [hideElementButton.heightAnchor constraintEqualToConstant:35],
        ]];
    }
    
    [hideElementButton setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
}

%new - (void)hideElementButtonHandler:(UIButton *)sender {
    self.elementsHidden = !self.elementsHidden;
    NSString *iconName = self.elementsHidden ? @"eye.slash.fill" : @"eye.fill";
    [sender setImage:[UIImage systemImageNamed:iconName] forState:UIControlStateNormal];
    
    UIViewController *rootVC = [self respondsToSelector:@selector(viewController)] ? [self performSelector:@selector(viewController)] : nil;
    
    if ([rootVC isKindOfClass:%c(AWENewFeedTableViewController)]) {
        AWENewFeedTableViewController *feedVC = (AWENewFeedTableViewController *)rootVC;
        if ([feedVC respondsToSelector:@selector(setPureMode:withAnimated:)]) {
            [feedVC setPureMode:self.elementsHidden withAnimated:YES];
        } else if ([feedVC respondsToSelector:@selector(setPureMode:)]) {
            [feedVC setPureMode:self.elementsHidden];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
    [self.progressCircle updateProgress:progress];
}

%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressCircle showSuccess];
        
        NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
        [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
        
        [BHIManager showSaveVC:@[newFilePath]];
    });
}

%new - (void)downloadDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.progressCircle showError];
        }
    });
}

%new - (void)downloaderProgress:(float)progress {
    [self.progressCircle updateProgress:progress];
}

%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressCircle showSuccess];
        [BHIManager showSaveVC:downloadedFilePaths];
    });
}

%new - (void)downloaderDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.progressCircle showError];
        }
    });
}
%end

%hook AWEAwemeDetailTableViewCell
%property (nonatomic, strong) BHTikTokProgressView *progressCircle;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
%property (nonatomic, strong) BHDownload *downloadManager;

- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}

- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}

%new - (void)bh_downloadVideoAction {
    if (![self.viewController isKindOfClass:%c(AWEAwemeDetailCellViewController)]) return;
    AWEAwemeDetailCellViewController *rootVC = (AWEAwemeDetailCellViewController *)self.viewController;
    NSURL *downloadableURL = [rootVC.model.video.playURL bestURLtoDownload];
    self.fileextension = [rootVC.model.video.playURL bestURLtoDownloadFormat];
    
    if (downloadableURL) {
        self.downloadManager = [[BHDownload alloc] init];
		[self.downloadManager downloadFileWithURL:downloadableURL];
		[self.downloadManager setDelegate:self];
        
        if (!self.progressCircle) {
            self.progressCircle = [[BHTikTokProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            self.progressCircle.center = self.contentView.center;
        }
        self.progressCircle.progressLayer.hidden = NO;
        self.progressCircle.statusImageView.hidden = YES;
        [self.progressCircle updateProgress:0.0];
        [self.contentView addSubview:self.progressCircle];
        [self.contentView bringSubviewToFront:self.progressCircle];
    }
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [self.contentView viewWithTag:998];
    if (!downloadButton) {
        downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [downloadButton setTag:998];
        [downloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
        [downloadButton setTintColor:[UIColor whiteColor]];
        
        if (@available(iOS 14.0, *)) {
            downloadButton.showsMenuAsPrimaryAction = YES;
        } else {
            [downloadButton addTarget:self action:@selector(bh_downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.contentView addSubview:downloadButton];
        [self.contentView bringSubviewToFront:downloadButton];
        
        UIView *hideButton = [self.contentView viewWithTag:999];
        if (hideButton) {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:35],
                [downloadButton.heightAnchor constraintEqualToConstant:35],
            ]];
        }
    }
    
    if (@available(iOS 14.0, *)) {
        downloadButton.menu = [self bh_buildDownloadMenu];
    }
}

%new - (UIMenu *)bh_buildDownloadMenu {
    if (![self.viewController isKindOfClass:%c(AWEAwemeDetailCellViewController)]) return nil;
    AWEAwemeDetailCellViewController *rootVC = (AWEAwemeDetailCellViewController *)self.viewController;
    AWEAwemeModel *videoModel = rootVC.model;
    
    NSMutableArray *actions = [NSMutableArray array];

    UIAction *downloadVideo = [UIAction actionWithTitle:@"Download video" image:[UIImage systemImageNamed:@"video"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self bh_downloadVideoAction]; 
    }];
    [actions addObject:downloadVideo];

    UIAction *downloadMusic = [UIAction actionWithTitle:@"Download music" image:[UIImage systemImageNamed:@"music.note"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *downloadableURL = [((AWEMusicModel *)[videoModel music]).playURL bestURLtoDownload];
        self.fileextension = [((AWEMusicModel *)[videoModel music]).playURL bestURLtoDownloadFormat];
        if (downloadableURL) {
            self.downloadManager = [[BHDownload alloc] init];
            [self.downloadManager downloadFileWithURL:downloadableURL];
            [self.downloadManager setDelegate:self];
            
            if (!self.progressCircle) {
                self.progressCircle = [[BHTikTokProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
                self.progressCircle.center = self.contentView.center;
            }
            self.progressCircle.progressLayer.hidden = NO;
            self.progressCircle.statusImageView.hidden = YES;
            [self.progressCircle updateProgress:0.0];
            [self.contentView addSubview:self.progressCircle];
            [self.contentView bringSubviewToFront:self.progressCircle];
        }
    }];
    [actions addObject:downloadMusic];

    UIAction *copyDesc = [UIAction actionWithTitle:@"Copy description" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSString *video_description = [videoModel music_songName] ?: @"BHTikTok Options";
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    }];
    [actions addObject:copyDesc];
    
    UIAction *copyVideoLink = [UIAction actionWithTitle:@"Copy video link" image:[UIImage systemImageNamed:@"link"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSURL *downloadableURL = [[videoModel video].playURL bestURLtoDownload];
        if (downloadableURL) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = [downloadableURL absoluteString];
        }
    }];
    [actions addObject:copyVideoLink];

    return [UIMenu menuWithTitle:@"BHTikTok" children:actions];
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [self.contentView viewWithTag:999];
    if (!hideElementButton) {
        hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hideElementButton setTag:999];
        [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [hideElementButton setTintColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:hideElementButton];
        [self.contentView bringSubviewToFront:hideElementButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:35],
            [hideElementButton.heightAnchor constraintEqualToConstant:35],
        ]];
    }
    
    [hideElementButton setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
}

%new - (void)hideElementButtonHandler:(UIButton *)sender {
    self.elementsHidden = !self.elementsHidden;
    NSString *iconName = self.elementsHidden ? @"eye.slash.fill" : @"eye.fill";
    [sender setImage:[UIImage systemImageNamed:iconName] forState:UIControlStateNormal];
    
    UIViewController *rootVC = [self respondsToSelector:@selector(viewController)] ? [self performSelector:@selector(viewController)] : nil;
    
    if ([rootVC isKindOfClass:%c(AWENewFeedTableViewController)]) {
        AWENewFeedTableViewController *feedVC = (AWENewFeedTableViewController *)rootVC;
        if ([feedVC respondsToSelector:@selector(setPureMode:withAnimated:)]) {
            [feedVC setPureMode:self.elementsHidden withAnimated:YES];
        } else if ([feedVC respondsToSelector:@selector(setPureMode:)]) {
            [feedVC setPureMode:self.elementsHidden];
        }
    }
}

%new - (void)downloadProgress:(float)progress {
    [self.progressCircle updateProgress:progress];
}

%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressCircle showSuccess];
        
        NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
        [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
        
        [BHIManager showSaveVC:@[newFilePath]];
    });
}

%new - (void)downloadDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.progressCircle showError];
        }
    });
}

%new - (void)downloaderProgress:(float)progress {
    [self.progressCircle updateProgress:progress];
}

%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressCircle showSuccess];
        [BHIManager showSaveVC:downloadedFilePaths];
    });
}

%new - (void)downloaderDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.progressCircle showError];
        }
    });
}
%end

%hook TTKStoryDetailTableViewCell
%property (nonatomic, strong) BHTikTokProgressView *progressCircle;
%property(nonatomic, assign) BOOL elementsHidden;
%property (nonatomic, retain) NSString *fileextension;
%property (nonatomic, strong) BHDownload *downloadManager;

- (void)configWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}

- (void)configureWithModel:(id)model {
    %orig;
    self.elementsHidden = false;
    if ([BHIManager hideElementButton]) [self addHideElementButton];
    if ([BHIManager downloadVideos]) [self addDownloadButton];
}

%new - (void)bh_downloadVideoAction {
    if (![self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) return;
    id rootVC = self.viewController;
    
    // استخدام valueForKeyPath لتخطي خطأ المترجم
    AWEAwemeModel *storyModel = [rootVC valueForKeyPath:@"model.currentPlayingStory"];
    NSURL *downloadableURL = [storyModel.video.playURL bestURLtoDownload];
    self.fileextension = [storyModel.video.playURL bestURLtoDownloadFormat];
    
    if (downloadableURL) {
        self.downloadManager = [[BHDownload alloc] init];
        [self.downloadManager downloadFileWithURL:downloadableURL];
        [self.downloadManager setDelegate:self];
        
        if (!self.progressCircle) {
            self.progressCircle = [[BHTikTokProgressView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            self.progressCircle.center = self.contentView.center;
        }
        self.progressCircle.progressLayer.hidden = NO;
        self.progressCircle.statusImageView.hidden = YES;
        [self.progressCircle updateProgress:0.0];
        [self.contentView addSubview:self.progressCircle];
        [self.contentView bringSubviewToFront:self.progressCircle];
    }
}

%new - (void)addDownloadButton {
    UIButton *downloadButton = [self.contentView viewWithTag:998];
    if (!downloadButton) {
        downloadButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [downloadButton setTag:998];
        [downloadButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [downloadButton setImage:[UIImage systemImageNamed:@"arrow.down.circle.fill"] forState:UIControlStateNormal];
        [downloadButton setTintColor:[UIColor whiteColor]];
        
        if (@available(iOS 14.0, *)) {
            downloadButton.showsMenuAsPrimaryAction = YES;
        } else {
            [downloadButton addTarget:self action:@selector(bh_downloadVideoAction) forControlEvents:UIControlEventTouchUpInside];
        }
        
        [self.contentView addSubview:downloadButton];
        [self.contentView bringSubviewToFront:downloadButton];
        
        UIView *hideButton = [self.contentView viewWithTag:999];
        if (hideButton) {
            [NSLayoutConstraint activateConstraints:@[
                [downloadButton.topAnchor constraintEqualToAnchor:hideButton.bottomAnchor constant:15],
                [downloadButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
                [downloadButton.widthAnchor constraintEqualToConstant:35],
                [downloadButton.heightAnchor constraintEqualToConstant:35],
            ]];
        }
    }
    
    if (@available(iOS 14.0, *)) {
        downloadButton.menu = [self bh_buildDownloadMenu];
    }
}

%new - (UIMenu *)bh_buildDownloadMenu {
    if (![self.viewController isKindOfClass:%c(TTKStoryDetailContainerViewController)]) return nil;
    id rootVC = self.viewController;
    AWEAwemeModel *videoModel = [rootVC model].currentPlayingStory;
    
    NSMutableArray *actions = [NSMutableArray array];

    UIAction *downloadVideo = [UIAction actionWithTitle:@"Download video" image:[UIImage systemImageNamed:@"video"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        [self bh_downloadVideoAction]; 
    }];
    [actions addObject:downloadVideo];

    UIAction *copyDesc = [UIAction actionWithTitle:@"Copy description" image:[UIImage systemImageNamed:@"doc.on.doc"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
        NSString *video_description = [videoModel music_songName] ?: @"BHTikTok Options";
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = video_description;
    }];
    [actions addObject:copyDesc];

    return [UIMenu menuWithTitle:@"BHTikTok" children:actions];
}

%new - (void)addHideElementButton {
    UIButton *hideElementButton = [self.contentView viewWithTag:999];
    if (!hideElementButton) {
        hideElementButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [hideElementButton setTag:999];
        [hideElementButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [hideElementButton addTarget:self action:@selector(hideElementButtonHandler:) forControlEvents:UIControlEventTouchUpInside];
        [hideElementButton setTintColor:[UIColor whiteColor]];
        
        [self.contentView addSubview:hideElementButton];
        [self.contentView bringSubviewToFront:hideElementButton];
        
        [NSLayoutConstraint activateConstraints:@[
            [hideElementButton.topAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.topAnchor constant:50],
            [hideElementButton.trailingAnchor constraintEqualToAnchor:self.contentView.safeAreaLayoutGuide.trailingAnchor constant:-10],
            [hideElementButton.widthAnchor constraintEqualToConstant:35],
            [hideElementButton.heightAnchor constraintEqualToConstant:35],
        ]];
    }
    
    [hideElementButton setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
}

%new - (void)hideElementButtonHandler:(UIButton *)sender {
    self.elementsHidden = !self.elementsHidden;
    [sender setImage:[UIImage systemImageNamed:self.elementsHidden ? @"eye.fill" : @"eye.slash.fill"] forState:UIControlStateNormal];
    
    id rootVC = self.viewController;
    if ([rootVC respondsToSelector:@selector(interactionController)]) {
        id interactionController = [rootVC interactionController];
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
    [self.progressCircle updateProgress:progress];
}

%new - (void)downloadDidFinish:(NSURL *)filePath Filename:(NSString *)fileName {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressCircle showSuccess];
        
        NSString *DocPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true).firstObject;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSURL *newFilePath = [[NSURL fileURLWithPath:DocPath] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, self.fileextension]];
        [manager moveItemAtURL:filePath toURL:newFilePath error:nil];
        
        [BHIManager showSaveVC:@[newFilePath]];
    });
}

%new - (void)downloadDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.progressCircle showError];
        }
    });
}

%new - (void)downloaderProgress:(float)progress {
    [self.progressCircle updateProgress:progress];
}

%new - (void)downloaderDidFinishDownloadingAllFiles:(NSMutableArray<NSURL *> *)downloadedFilePaths {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressCircle showSuccess];
        [BHIManager showSaveVC:downloadedFilePaths];
    });
}

%new - (void)downloaderDidFailureWithError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (error) {
            [self.progressCircle showError];
        }
    });
}
%end

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
