#import "SecurityViewController.h"
#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h> // ضروري جداً لعمل البصمة والـ FaceID

@implementation SecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // إعداد الخلفية الضبابية
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurView.frame = self.view.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight; // تتمدد مع الشاشة
    [self.view addSubview:blurView];
    
    // إعداد زر المصادقة
    UIButton *authenticateButton = [UIButton buttonWithType:UIButtonTypeSystem];
    authenticateButton.frame = CGRectMake(0, 0, 200, 60);
    [authenticateButton setTitle:@"Authenticate" forState:UIControlStateNormal];
    authenticateButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [authenticateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    authenticateButton.center = self.view.center;
    authenticateButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin; // يبقى في المنتصف دائماً
    
    [authenticateButton addTarget:self action:@selector(authenticateButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:authenticateButton];
    
    // استدعاء المصادقة فور فتح الواجهة
    [self authenticate];
}

- (void)authenticateButtonTapped:(id)sender {
    [self authenticate];
}

- (void)authenticate {
    LAContext *context = [[LAContext alloc] init];
    NSError *error = nil;
    
    // التحقق مما إذا كان الجهاز يدعم المصادقة (مفعل به رمز قفل أو بصمة)
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthentication error:&error]) {
        NSString *reason = @"Identify yourself to access BHTikTok!";
        
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthentication localizedReason:reason reply:^(BOOL success, NSError *authenticationError) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    // المستخدم ألغى المصادقة أو فشلت، يمكنه المحاولة مجدداً بضغط الزر
                }
            });
        }];
    } else {
        // الجهاز لا يحتوي على حماية (لا رمز ولا بصمة)، نتخطى القفل حتى لا يعلق المستخدم
        dispatch_async(dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}

@end
