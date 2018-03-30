//
//  LiveViewController.m
//  Fitbase
//
//  Created by Karthikeyan on 28/12/17.
//

#import "LiveViewController.h"
#import "NSDictionary+Safety.h"
#import <UIKit/UIKit.h>
#define APP_IN_FULL_SCREEN @"appInFullScreenMode"

static NSString *const kApiKey = @"46033242";
// Replace with your generated session ID
static NSString *const kSessionId = @"2_MX40NjAzMzI0Mn5-MTUxNTE1OTI1MTgxNX41TVVVWjBaVXRIRHNqZGJUaWoxY0ZjNDB-fg";
// Replace with your generated token
static NSString *const kToken = @"T1==cGFydG5lcl9pZD00NjAzMzI0MiZzaWc9N2VmNmYzNTViMTEyNzFjN2E0YTc0ZGI2YzIyOTE4OWZhMjRmYjc1NjpzZXNzaW9uX2lkPTJfTVg0ME5qQXpNekkwTW41LU1UVXhOVEUxT1RJMU1UZ3hOWDQxVFZWVldqQmFWWFJJUkhOcVpHSlVhV294WTBaak5EQi1mZyZjcmVhdGVfdGltZT0xNTE1MjQwODIyJm5vbmNlPTAuMTQzNzU0NTY3OTYyODc1MzMmcm9sZT1tb2RlcmF0b3ImZXhwaXJlX3RpbWU9MTUxNzgzMjgyMSZpbml0aWFsX2xheW91dF9jbGFzc19saXN0PQ==";

@interface LiveViewController ()<OTSessionDelegate, OTSubscriberKitDelegate,
OTPublisherDelegate,UIGestureRecognizerDelegate,UIScrollViewDelegate>
{
    OTSession *_session;
    OTPublisher *_publisher;
    OTSubscriber *_currentSubscriber;
    //BOOL isFullScreen;
}
@property (weak, nonatomic) IBOutlet UIButton *audioBTNOne;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNTwo;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNThree;
@property (weak, nonatomic) IBOutlet UIButton *audioBTNFour;



@property (weak, nonatomic) IBOutlet UIView *publisherView;

@property (strong, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UIButton *swapCameraButton;

@property (strong, nonatomic) IBOutlet UIButton *audioSubUnsubButton;
@property (strong, nonatomic) IBOutlet UIButton *videoSubUnsubButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;


@property (weak, nonatomic) IBOutlet UIImageView *publisherDeaultImage;



@property (strong, nonatomic) NSTimer *overlayTimer;
@property (nonatomic, strong) UIAlertController *alert;

@property (weak, nonatomic) IBOutlet UILabel *sessionReconnectingMsgLabel;


@property UIBackgroundTaskIdentifier backgroundUpdateTask;
@property (weak, nonatomic) IBOutlet UIView *scrollContainerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *changeViewButton;
@property (weak, nonatomic) IBOutlet UIView *topToolBar;
@property (weak, nonatomic) IBOutlet UIButton *muteUnmuteAllButton;
@property (weak, nonatomic) IBOutlet UIButton *scrollContainerAudioBtn;

@property (weak, nonatomic) IBOutlet UIView *mainContainerView;



- (void)showReconnectingAlert;
- (void)dismissReconnectingAlert;
@property (weak, nonatomic) IBOutlet UILabel *timer;
@property (weak, nonatomic) IBOutlet UILabel *messegeForUser;
@property NSMutableDictionary *allSubscribers;//
@property NSMutableDictionary *allSubcribersPresentVideos;
@property NSMutableDictionary *allStreams;
@property NSMutableArray *allConnectionIds;
@end

@implementation LiveViewController
NSMutableArray *keys;
double countDownTimerMilliSeconds;
NSString *comingView;
int groupSize;
NSArray *buttons;
NSArray *audioButtons;
bool sessionDisconnect=NO;
float initialYaxisScroll;
float afterIconsOnYaxis;
Boolean changeveiw;
bool tapped=YES;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self beginBackgroundUpdateTask];
    [self requestPermissions];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self.topToolBar setHidden:YES];
    [self.scrollContainerAudioBtn setHidden:YES];
    changeveiw=true;
    [self setHiddenContainerView: true];
    buttons=[NSArray arrayWithObjects:_exitBtn,_audioSubUnsubButton,_videoSubUnsubButton,_swapCameraButton,nil];
    audioButtons=[NSArray arrayWithObjects:_audioBTNOne,_audioBTNTwo,_audioBTNThree,_audioBTNFour,nil];
    [self setBorderForAudioButtons];
    [self setHiddenAll:true];
    _allSubscribers=[[NSMutableDictionary alloc] init];//initializing the variables
    _allStreams=[[NSMutableDictionary alloc] init];
    _allConnectionIds=[[NSMutableArray alloc] init];
     keys=[[NSMutableArray alloc] init];
    _allSubcribersPresentVideos=[[NSMutableDictionary alloc] init];
    NSLocale* currentLocale = [NSLocale currentLocale];
    [[NSDate date] descriptionWithLocale:currentLocale];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    NSString *dateStr  = [self.hybridParams safeObjectForKey:@"startDate"];
    NSString *splitStr = [dateStr componentsSeparatedByString:@"."][0];
    double minuts = [[self.hybridParams safeObjectForKey:@"duration"] doubleValue];
    NSDate *addedDate= [[dateFormatter dateFromString:splitStr] dateByAddingTimeInterval:minuts*60]; //adding duretion to startdate
    NSTimeInterval countDownTimer=[addedDate timeIntervalSince1970];
    countDownTimerMilliSeconds=countDownTimer*1000; // here we are adding milliseconds to countdowntime
    [self countDownTime];
    [self buttonsBackground];
    [self setupSession];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(enteringBackgroundMode:)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(leavingBackgroundMode:)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
    //isFullScreen = NO;
    UIPanGestureRecognizer * pan1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveObject:)];
    pan1.minimumNumberOfTouches = 1;
    _publisherView.tag=3;
    [_publisherView addGestureRecognizer:pan1];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(orientationChanged:)
     name:UIDeviceOrientationDidChangeNotification
     object:[UIDevice currentDevice]];
    // listen to taps around the screen, and hide/show overlay views
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(viewTappedInLive:)];
    tgr.delegate = self;
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tgr];
     [self overlayTimerSetUp];
}//view controller

- (void) beginBackgroundUpdateTask
{
    self.backgroundUpdateTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //  [self endBackgroundUpdateTask];
    }];
}
- (void) endBackgroundUpdateTask
{
    [[UIApplication sharedApplication] endBackgroundTask: self.backgroundUpdateTask];
    self.backgroundUpdateTask = UIBackgroundTaskInvalid;
}



-(void)requestPermissions
{
    AVAuthorizationStatus _cameraAuthorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (_cameraAuthorizationStatus)
    {
        case AVAuthorizationStatusNotDetermined:
        {
            NSLog(@"%@", @"Camera access not determined. Ask for permission.");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
             {
                 if(granted)
                 {
                     NSLog(@"Granted access to %@", AVMediaTypeVideo);
                     
                 }
                 else
                 {
                     dispatch_async( dispatch_get_main_queue(), ^{
                         [self accessDynamicpermissons:@"camera"];
                     });
                     NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                     // *** Camera access rejected by user, perform respective action ***
                 }
             }];
        }
            break;
        case AVAuthorizationStatusRestricted:
        case AVAuthorizationStatusDenied:
        {
            // Prompt for not authorized message & provide option to navigate to settings of app.
            dispatch_async( dispatch_get_main_queue(), ^{
                [self accessDynamicpermissons:@"camera"];
            });
        }
            break;
        default:
            break;
    }
    
    AVAudioSessionRecordPermission permissionStatus = [[AVAudioSession sharedInstance] recordPermission];
    
    switch (permissionStatus) {
        case AVAudioSessionRecordPermissionUndetermined:{
            [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
                // CALL YOUR METHOD HERE - as this assumes being called only once from user interacting with permission alert!
                if (granted) {
                    
                }
                else {
                    // Microphone disabled code
                    dispatch_async( dispatch_get_main_queue(), ^{
                        [self accessDynamicpermissons:@"Microphone"];
                    });
                }
            }];
            break;
        }
        case AVAudioSessionRecordPermissionDenied:{
            dispatch_async( dispatch_get_main_queue(), ^{
                [self accessDynamicpermissons:@"Microphone"];
            });
            break;
        }
        case AVAudioSessionRecordPermissionGranted: {
            
            break;
        }
    }
}
-(void) accessDynamicpermissons:(NSString *)type{
    
    NSString *message;
    if([type isEqual:@"Microphone"]){
        message = NSLocalizedString( @"Fitbase doesn't have permission to use the Microphone, please change privacy settings", @"Alert message when the user has denied access to the microphone" );
    }else{
        message = NSLocalizedString( @"Fitbase doesn't have permission to use the camera, please change privacy settings", @"Alert message when the user has denied access to the camera" );
    }
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Fitbase" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Cancel", @"Alert OK button" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
        [self destroyAll];
    }];
    [alertController addAction:cancelAction];
    // Provide quick access to Settings.
    UIAlertAction *settingsAction = [UIAlertAction actionWithTitle:NSLocalizedString( @"Settings", @"Alert button to open Settings" ) style:UIAlertActionStyleDefault handler:^( UIAlertAction *action ) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alertController addAction:settingsAction];
    [self presentViewController:alertController animated:YES completion:nil];
}



-(void)setBorderForAudioButtons{
    for (int i=0;i<audioButtons.count;i++) {
        UIButton* uibutton= [audioButtons objectAtIndex:i];
         [uibutton.layer setBorderWidth:1.0];
         [uibutton.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    }
}

/*--buttonsBackground---*/
-(void) buttonsBackground{
    for (int i=0;i<buttons.count;i++) {
        UIButton* uibutton= [buttons objectAtIndex:i];
        if(uibutton != _exitBtn){
            [uibutton setBackgroundColor: [UIColor colorWithRed:60/255.0f green:179/255.0f blue:202/255.0f alpha:1.0f]];
        }
    }
}//buttonsBackground

// Handling Background and foreground
- (void)enteringBackgroundMode:(NSNotification*)notification{
    _publisher.publishVideo = NO;
    
}
/*------leavingBackgroundMode-----*/
- (void)leavingBackgroundMode:(NSNotification*)notification{
     _publisher.publishVideo = YES;
     [self shuffle];
}//leavingBackgroundMode
/*--setHiddenAll---*/
- (void) setHiddenAll:(Boolean )value{
    [self.publisherDeaultImage setHidden:value];
    [self.sessionReconnectingMsgLabel setHidden:value];
    [self hideAudioButtons:value];
}//setHidden Function
/*------hideAudioButtons-----*/
-(void)hideAudioButtons:(Boolean )value{
    [self.audioBTNOne setHidden:value];
    [self.audioBTNTwo setHidden:value];
    [self.audioBTNThree setHidden:value];
    [self.audioBTNFour setHidden:value];
}//hideAudioButtons
/*-----setHiddenContainerView------*/
-(void)setHiddenContainerView:(Boolean )value{
    [self.scrollContainerView setHidden:value];
    [self.scrollView setHidden:value];
}//setHiddenContainerView
/*----changeView----*/
- (IBAction)changeView:(id)sender {
    if(changeveiw){
       // [self setHiddenAll:true];
        [self setupScrollView];
        [self setHiddenContainerView:false];
        [self removeSubViewsInMaincontainerViwe];
        changeveiw=false;
        [_changeViewButton setImage:[UIImage imageNamed:@"gridView"] forState:UIControlStateNormal];
        [self setUpPublisherFrame:_scrollView.frame.origin.y height:_scrollView.frame.size.height];
        self.publisherView.layer.borderWidth=1;
        self.publisherView.layer.borderColor=[[UIColor whiteColor] CGColor];
        initialDefaultImgXaxis=102;
        OTSubscriber *sub=[_allSubscribers objectForKey:keys[0]];
        [self addViewMainScrollScontainer:sub tagValue:0];
        [self shuffle];
    }else{
        [self removeViewsFromRecycler];
        self.publisherView.layer.borderWidth=0;
         [_changeViewButton setImage:[UIImage imageNamed:@"galaryView"] forState:UIControlStateNormal];
        [self setHiddenContainerView:true];
        [self.scrollContainerAudioBtn setHidden:YES];
        changeveiw=true;
        [self shuffle];
    }
}//changeView
/*------setupScrollView-----*/
-(void)setupScrollView{
    initialYaxisScroll=_scrollView.frame.origin.y;
    afterIconsOnYaxis=_scrollContainerView.frame.size.height-_scrollView.frame.size.height;
}//setupScrollView
/*-------move publisher Object -----------*/
-(void)moveObject:(UIPanGestureRecognizer *)pan;
{
    if(changeveiw){
    _publisherView.center = [pan locationInView:_publisherView.superview];
    _publisherDeaultImage.center=[pan locationInView:_publisherDeaultImage.superview];
    }
}//moveObject
/*---------enableAndDisableAllSubscriberAudios----------*/
-(void)enableAndDisableAllSubscriberAudios:(Boolean )value{
    if(changeveiw==false){ [self adjustSubscriberAudio:value subscriber:maincontainerSub button:_scrollContainerAudioBtn];}
    for(int i=0;i<_allSubscribers.count;i++){
        OTSubscriber *sub=[_allSubscribers objectForKey:keys[i]];
            UIButton *button=(i==0)?_audioBTNOne:(i==1)?_audioBTNTwo:(i==2)? _audioBTNThree: _audioBTNFour;
            [self adjustSubscriberAudio:value subscriber:sub button:button];
    }
}//enableAndDisableAllSubscriberAudios

 -(void)tapOnScrollerViews:(UIPanGestureRecognizer *)pan;
{
    NSLog(@" -------%ld",pan.view.tag);
    int index=(int)pan.view.tag;
    int mainScrollViewConTag=(int)_scrollContainerView.tag;
   
    OTSubscriber * fistDefaultImgConSub=[_allSubscribers objectForKey:keys[mainScrollViewConTag]];
    OTSubscriber * tappedSub=[_allSubscribers objectForKey:keys[index]];
    maincontainerSub=nil;
    [self addViewMainScrollScontainer:tappedSub tagValue:index];
    [self addRecyclerView:fistDefaultImgConSub xAxis:initialDefaultImgXaxis tagValue:mainScrollViewConTag];
    [self addRecyclerView:tappedSub xAxis:pan.view.frame.origin.x tagValue:index];
    initialDefaultImgXaxis=pan.view.frame.origin.x;
}
/*------removeUIViewsFromScroller-------*/
-(void)removeUIViewsFromScroller:(int )tag{
    OTSubscriber * tappedSubscriberNew=[_allSubscribers objectForKey:keys[tag]];
    UIView * viewToRemove=[self.view viewWithTag:tag];
    float xAxis=viewToRemove.frame.origin.x;
    [viewToRemove removeFromSuperview];
    [self addViewMainScrollScontainer:tappedSubscriberNew tagValue:tag];
    [self addRecyclerView:tappedSubscriberNew xAxis:xAxis tagValue:tag];
}//removeUIViewsFromScroller

/*-------------removeViewsFromRecycler--------*/
-(void)removeViewsFromRecycler{
    for(UIView *subview in _scrollView.subviews){
        [subview removeFromSuperview];
    }
}//removeViewsFromRecycler
/*-------------orientationChanged---------*/
- (void) orientationChanged:(NSNotification *)note
{
    UIDeviceOrientation Orientation=[[UIDevice currentDevice]orientation];
   if(sessionDisconnect==NO){
    if(Orientation==UIDeviceOrientationLandscapeLeft || Orientation==UIDeviceOrientationLandscapeRight)
    {
         [self checkSubscribersList];
    }
    else if(Orientation==UIDeviceOrientationPortrait)
    {
          [self checkSubscribersList];
    }
  }//sessiondisconnect condition
}//orientationChanged

/*-----------checkSubscribersList--------*/
-(void)checkSubscribersList{
    if(_allSubscribers.count>0){
        [self shuffle];
        if(changeveiw ==false){
            [self setUpPublisherFrame:_scrollView.frame.origin.y height:_scrollView.frame.size.height];
            [self setupScrollView]; [self addViewMainScrollScontainer:maincontainerSub tagValue:(int)_scrollContainerView.tag];[self recyclerView];
        }else{
            [self setUpPublisherFrame:_publisherView.frame.origin.y height:100];
        }
    }
}//checkSubscribersList

/*cam swape*/
- (IBAction)swapCam:(id)sender {
    NSLog(@"swipe cliked");
    if (_publisher.cameraPosition == AVCaptureDevicePositionBack) {
        _publisher.cameraPosition = AVCaptureDevicePositionFront;
        
    } else if (_publisher.cameraPosition == AVCaptureDevicePositionFront) {
        _publisher.cameraPosition = AVCaptureDevicePositionBack;
        
    }
}

NSTimer *timer;
/*----countDownTime----*/
-(void)countDownTime{
    timer= [NSTimer scheduledTimerWithTimeInterval: 1.0 target:self selector:@selector(updateCountdown) userInfo:nil repeats: YES];
}//countDownTime
/*-----updateCountdown-----*/
-(void)updateCountdown{
    NSDate *today = [NSDate date];
    NSTimeInterval seconds1=[today timeIntervalSince1970];
    double millies1=seconds1*1000;
    int distance=countDownTimerMilliSeconds-millies1;
    if(distance>0){
        //;
        int hour=(distance % 86400000)/(3600000);
        int minut=(distance % 3600000)/60000;
        int sec = (distance % 60000)/1000;
        self.timer.text= [NSString stringWithFormat:@"%02d:%02d:%02d", hour, minut, sec];
        
    }else{
            // disconnect session
            NSLog(@"disconnecting....");
        
        [self destroyAll];
        [timer invalidate];
        timer = nil;
    }
    
}//updateCountdown

/*--showReconnectingAlert--*/
- (void)showReconnectingAlert{
    [self.sessionReconnectingMsgLabel setHidden:NO];
}//showReconnectingAlert

/*---dismissReconnectingAlert---*/
- (void)dismissReconnectingAlert{
    [self.sessionReconnectingMsgLabel setHidden:YES];
}

/*------sessionDidBeginReconnecting------*/
- (void)sessionDidBeginReconnecting:(OTSession *)session{
    [self showReconnectingAlert];
}//sessionDidBeginReconnecting

/*-----sessionDidBeginReconnecting-----*/
- (void)sessionDidReconnect:(OTSession *)session{
    [self dismissReconnectingAlert];
}//sessionDidReconnect


/*---setupSession----*/
- (void)setupSession{
    NSLog(@" =---------entered----");
    [_activityIndicator startAnimating];//spinner start
    //setup one time session
    if (_session) {
        _session = nil;
    }
    
    _session = [[OTSession alloc] initWithApiKey:self.openTokApi_Key
                                       sessionId:self.openTokSessionID
                                        delegate:self];
    [_session connectWithToken:self.openTokToken error:nil];
    [self setupPublisher];
    
}//setupSession

/*---setupPublisher---*/
- (void)setupPublisher{
    OTPublisherSettings *settings = [[OTPublisherSettings alloc] init];
    settings.name =  [self.hybridParams safeObjectForKey:@"userName"];//[UIDevice currentDevice].name;
    _publisher = [[OTPublisher alloc] initWithDelegate:self settings:settings];
    [self addPublisherview:_publisher];
    [_messegeForUser setHidden:NO];
}//setupPublisher

/*----addViewForPublisher-----*/
-(void)addPublisherview:(OTPublisher *)publisher{
    [_publisher.view setFrame:CGRectMake(0, 0, self.publisherView.frame.size.width, self.publisherView.frame.size.height)];
    [self.publisherView addSubview:_publisher.view];
}//addViewForPublisher

/*------setUpPublisherFrame--------*/
-(void)setUpPublisherFrame:(float )yaxis height:(float )height{
    self.publisherView.frame=CGRectMake(0, yaxis, 100, height);
    self.publisherDeaultImage.frame=CGRectMake(0, yaxis, 100, height);
    [self addPublisherview:_publisher];
}//setUpPublisherFrame
/*---------------controllAudioOfSubscribers--------------*/
- (IBAction)controllAudioOfSubscribers:(UIButton *)sender {
    int tag =(int)sender.tag;
    OTSubscriber *sub=[_allSubscribers objectForKey:keys[tag]];
    UIButton * button=(tag==0)?_audioBTNOne :(tag==1)? _audioBTNTwo :(tag==2)?_audioBTNThree:_audioBTNFour;
    if([button.currentImage isEqual:[UIImage imageNamed:@"audio"]]){
        [self adjustSubscriberAudio:false subscriber:sub button:button];
    }else{
         [self adjustSubscriberAudio:true subscriber:sub button:button];
    }
}//controllAudioOfSubscribers

/*---setHiddenShowForICONs----*/
-(void)setHiddenShowForICONs:(Boolean ) value{
    [self.exitBtn setHidden:value];
    [self.audioSubUnsubButton setHidden:value];
    [self.videoSubUnsubButton setHidden:value];
    [self.swapCameraButton setHidden:value];
}//setHiddenShowForICONs

/*---View Tapped When Hide Back and BottomView--*/
- (void)viewTappedInLive:(UITapGestureRecognizer *)tgr {
    [self afterOverlayTimeAction];
}//viewTappedInLive

-(void)afterOverlayTimeAction{
  
    if (tapped) {
        [UIView animateWithDuration:0.5
                         animations:^{
                             [self setHiddenShowForICONs:true];
                             if(keys.count>1){ [self.topToolBar setHidden:YES];}
                             if(changeveiw==false){
                                 _scrollView.frame=CGRectMake(0,afterIconsOnYaxis, _scrollView.frame.size.width, _scrollView.frame.size.height);
                                 [self setUpPublisherFrame:afterIconsOnYaxis height:_scrollView.frame.size.height];
                             }
                         }];
        tapped=NO;
    }else{
        [UIView animateWithDuration:.5
                         animations:^{
                             if (self.overlayTimer) {[self.overlayTimer invalidate];}
                             [self setHiddenShowForICONs:false];
                             [self overlayTimerSetUp];// start overlay hide timer
                             if(keys.count>1){  [self.topToolBar setHidden:NO];}
                             if(changeveiw==false){_scrollView.frame=CGRectMake(0,initialYaxisScroll,_scrollView.frame.size.width, _scrollView.frame.size.height);
                                 [self setUpPublisherFrame:initialYaxisScroll height:_scrollView.frame.size.height];
                             }
                         }];
        tapped=YES;
    }
   
   
}//afterOverlayTimeAction

-(void)overlayTimerSetUp{
    self.overlayTimer =
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(overlayTimerAction)
                                   userInfo:nil
                                    repeats:NO];
}


/*----overlayTimerAction ----*/
- (void)overlayTimerAction{
    // Hide views
        [self afterOverlayTimeAction];
      //  [self setHiddenShowForICONs:true];
        if (self.overlayTimer) { [self.overlayTimer invalidate]; }
}//overlayTimerAction



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*-----createSubscriber----*/
- (void)createSubscriber:(OTStream *)stream{
    // create subscriber
    _currentSubscriber = [[OTSubscriber alloc]
                          initWithStream:stream delegate:self];
    OTError *error = nil;
    [_session subscribe:_currentSubscriber error:&error];
    if (error)
    {
        //            [self showAlert:[error localizedDescription]];
    }
}//createSubscriber


// Open Tok Delegates
# pragma mark - OTSession delegate callbacks
/*-------------mySession streamCreated-------------*/
- (void) session:(OTSession *)mySession streamCreated:(OTStream *)stream {
    NSLog(@"Connection Meta Data  in mySession streamCreated : %@",stream.connection.data);
    [self createSubscriber:stream];
}//streamCreated

/*------sessionDidDisconnect-----*/
- (void)sessionDidDisconnect:(OTSession *)session {
    sessionDisconnect=YES;
    [self destroyAll];
}//sessionDidDisconnect

/*------destroyAll-------*/
-(void) destroyAll{
    [_session disconnect:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self endBackgroundUpdateTask];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self cleanupPublisher];
    [_allSubscribers removeAllObjects];
    [_allStreams removeAllObjects];
    [keys removeAllObjects];
    return;
}//destroyAll

/*-----sessionDidConnect-----*/
- (void)sessionDidConnect:(OTSession *)session {
    // now publish
    OTError *error = nil;
    [_session publish:_publisher error:&error];
    if (error)
    {
        //        [self showAlert:[error localizedDescription]];
    }
    [_activityIndicator stopAnimating]; //spinner close
    [_activityIndicator setHidden:YES];
}//sessionDidConnect

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
}

/*-----streamDestroyed-----*/
- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{
    NSLog(@"streamDestroyed %@", stream.connection.connectionId);
    OTSubscriber *subscriber = [_allSubscribers objectForKey:stream.connection.connectionId];
    [keys removeObject:stream.connection.connectionId];
    [subscriber.view removeFromSuperview];
    [_allSubscribers removeObjectForKey:stream.connection.connectionId];
    if(changeveiw==false){
        [self removeViewsFromRecycler];
    }
    if(_allSubscribers.count==0){[_messegeForUser setHidden:NO];
        if(changeveiw==false){
             [self.scrollContainerAudioBtn setHidden:YES];
        }
    }
   if(keys.count==1 && changeveiw==false){
       [self.changeViewButton setHidden:YES];
       OTSubscriber *lastSub=[_allSubscribers objectForKey:keys[0]];
       [self addViewMainScrollScontainer:lastSub tagValue:0];
   }
    
    if(_allSubscribers.count<=1){
        [_topToolBar setHidden:YES];
    }
    [self shuffle];
   
}//streamDestroyed

/*---cleanupSubscriber---*/
- (void)cleanupSubscriber{
    [_currentSubscriber.view removeFromSuperview];
    _currentSubscriber = nil;
}//cleanupSubscriber

/*----cleanupPublisher----*/
- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}//cleanupPublisher

# pragma mark - OTPublisher delegate callbacks

- (void)publisher:(OTPublisherKit *)publisher
streamCreated:(OTStream *)stream{
    NSLog(@"Connection Meta Data  in publisher streamCreated -------: %@",stream.connection.data);
}//streamCreated

- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    if ([_currentSubscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    [self cleanupPublisher];
}
/*----------------publisher didFailWithError------------*/
- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error
{
    NSLog(@"publisher didFailWithError %@", error);
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
}//publisher didFailWithError

# pragma mark - OTSubscriber delegate callbacks
/*-----------------subscriberDidConnectToStream---------------*/
- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber
{
    OTSubscriber *sub = (OTSubscriber *)subscriber;
    [_allSubscribers setObject:sub forKey:sub.stream.connection.connectionId];
    [keys addObject:sub.stream.connection.connectionId];
    
    if(_allSubscribers.count==1){
        [_messegeForUser setHidden:YES];
        if(changeveiw==false){[self addViewMainScrollScontainer:sub tagValue:0];}
    }
    [_allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
    if(keys.count>1){[self.changeViewButton setHidden:NO];}
    if([_muteUnmuteAllButton.titleLabel.text isEqualToString:@"Unmute all"]){
        [self enableAndDisableAllSubscriberAudios:false];
    }else{
        [self enableAndDisableAllSubscriberAudios:true];
    }
     [self shuffle];
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
}//subscriberDidConnectToStream

/*---------addViewsForGridView------*/
-(void)addViewForGridView:(OTSubscriber *)sub   width:(float )width height:(float )height xAxis:(float )xAxis yAxis:(float )yAxis tagValue:(int )tag {
    UIView* view=[[UIView alloc] initWithFrame:CGRectMake(xAxis, yAxis, width, height)];
    [_mainContainerView addSubview:view];
    [sub.view setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
    [view addSubview:sub.view];
    UIButton * button=(tag==0)?_audioBTNOne:(tag==1)?_audioBTNTwo:(tag==2)?_audioBTNThree:_audioBTNFour;
    [self addFrameForButtons:width button:button tagValue:tag];
    [sub.view addSubview:button];
}//addViewForGridView

/*-------------addFrameForButtons------*/
-(void)addFrameForButtons:(float )width button :(UIButton *)button tagValue:(int )tag{
     [button setHidden:false];
     button.tag=tag;
     button.frame = CGRectMake(width-40,18 ,35,35);
}//addFrameForButtons

-(void)addDefaultImageForViewInGrid:(OTSubscriber *)sub width:(float )width height:(float )height xAxis:(float )xAxis yAxis:(float )yAxis tagValue:(int )tag{
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
    image.frame = CGRectMake(xAxis, yAxis,width,height);
    image.backgroundColor=[UIColor darkGrayColor];
    [_mainContainerView addSubview:image];
    UIButton * button=(tag==0)?_audioBTNOne:(tag==1)?_audioBTNTwo:(tag==2)?_audioBTNThree:_audioBTNFour;
    [self addFrameForButtons:width button:button tagValue:tag];
    [image addSubview:button];
}

-(void)removeSubViewsInMaincontainerViwe{
    for(UIView * subview in _mainContainerView.subviews){
        [subview removeFromSuperview];
    }
}

/*-----loopForGridViews-----*/
-(void)loopForGridViews:(float )width height:(float )height xAxis:(float )xAxis yAxis:(float )yAxis {
    float widthOfView=width;
    float xAxisOfview=0;
    float yAxisOfview=0;
    float heightOfView=height;
   
    NSLog(@" -------height----- %f,%f",height,width);
    NSLog(@"---------xaxis and yaxis----- %f,%f",xAxisOfview,yAxisOfview );
    
    for(int i=0;i<_allSubscribers.count;i++){
        OTSubscriber * sub=[_allSubscribers objectForKey:keys[i]];
       if(sub.stream.hasVideo){
            [self addViewForGridView:sub width:widthOfView height:heightOfView xAxis:xAxisOfview yAxis:yAxisOfview tagValue:i];
        }else{
            [self addDefaultImageForViewInGrid:sub width:widthOfView height:heightOfView xAxis:xAxisOfview yAxis:yAxisOfview tagValue:i];
        }
        
        /*if(i==0){
            yAxisOfview=(_allSubscribers.count==2)?_mainContainerView.frame.size.height/2:0;
            xAxisOfview=(_allSubscribers.count==3 || _allSubscribers.count==4)? width:0;
        }
        if(i==1){
            xAxisOfview=0;
            yAxisOfview=(_allSubscribers.count==3 || _allSubscribers.count==4)? _mainContainerView.frame.size.height/2:yAxisOfview;
            width=(_allSubscribers.count==3)? _mainContainerView.frame.size.width: width;
        }
        if(i==2){
            xAxisOfview=_mainContainerView.frame.size.width/2;
        }*/
        
        yAxisOfview=(_allSubscribers.count==2 && i==0)?_mainContainerView.frame.size.height/2:(_allSubscribers.count==3 && i==1)? height:(_allSubscribers.count==4 && (i==1 || i==2))? height:0;
        xAxisOfview=((_allSubscribers.count==3||_allSubscribers.count==4)&& (i==0||i==2))? width:0;
        widthOfView=(_allSubscribers.count==3 && i==1)?_mainContainerView.frame.size.width :(_allSubscribers.count==2)?_mainContainerView.frame.size.width :width;
   }
}//loopForGridViews


/*-------shuffle-----*/
-(void)shuffle
{
   if(changeveiw){
       float width= (_allSubscribers.count==1 || _allSubscribers.count==2)?_mainContainerView.frame.size.width:_mainContainerView.frame.size.width/2 ;
       float height= (_allSubscribers.count>1)?_mainContainerView.frame.size.height/2:_mainContainerView.frame.size.height;
       [self removeSubViewsInMaincontainerViwe];
       [self loopForGridViews:width height:height xAxis:0 yAxis:0];
    
  }else{
      //[self addPublisherview:_publisher];
      [self removeSubViewsInMaincontainerViwe];
      [self hideAudioButtons:YES];
      [self recyclerView];
  }
}//shuffle
int initialDefaultImgXaxis;
-(void)recyclerView{
    double xAxis=102;
        double width=100;
        for(int i=0;i<keys.count;i++){
            OTSubscriber *sub=[_allSubscribers objectForKey:keys[i]];
            [_scrollView setContentSize:CGSizeMake(width+180, _scrollView.frame.size.height)];
            _scrollView.delegate=self;
            [self addRecyclerView:sub xAxis:xAxis tagValue:i];
            width+=100;
            xAxis+=102;
    }
 }//recyclerView

OTSubscriber *maincontainerSub=nil;
/*----------addViewMainScrollScontainer-------*/
-(void)addViewMainScrollScontainer:(OTSubscriber *)sub tagValue:(int )tag{
    maincontainerSub=sub;
    self.scrollContainerView.tag=tag;
    [_scrollContainerAudioBtn.layer setBorderWidth:1.0];
    [_scrollContainerAudioBtn.layer setBorderColor:[[UIColor lightGrayColor] CGColor]];
    [self.scrollContainerAudioBtn setHidden:NO];
    if([_muteUnmuteAllButton.titleLabel.text isEqualToString:@"Mute all"]){
          [self adjustSubscriberAudio:true subscriber:maincontainerSub button:_scrollContainerAudioBtn];
    }else{[self adjustSubscriberAudio:false subscriber:maincontainerSub button:_scrollContainerAudioBtn];}
    if(sub.stream.hasVideo){
    [sub.view setFrame:CGRectMake(0, 0 ,self.scrollContainerView.frame.size.width ,self.scrollContainerView.frame.size.height)];
        [self.scrollContainerView addSubview:sub.view];
    }else{
        [self addDefaultImage:sub xAxis:0 widht:self.scrollContainerView.frame.size.width height:self.scrollContainerView.frame.size.height container:@"main" tagValue:tag];
    }
}//addViewMainScrollScontainer
/*----------addRecyclerView---------*/
-(void)addRecyclerView:(OTSubscriber *)sub xAxis:(double )xAxis tagValue:(int )tag{
        if(sub.stream.hasVideo && ![maincontainerSub.stream.connection.connectionId isEqual:sub.stream.connection.connectionId]){
            UIView * subcriberViewInScroll=[[UIView alloc] initWithFrame:CGRectMake(xAxis, 0, 100, _scrollView.frame.size.height)];
            [subcriberViewInScroll setClipsToBounds:YES];
            [sub.view setFrame:CGRectMake(0,0 ,subcriberViewInScroll.frame.size.width, subcriberViewInScroll.frame.size.height)];
            [subcriberViewInScroll addSubview:sub.view];
            subcriberViewInScroll.tag=tag;
            subcriberViewInScroll.layer.cornerRadius=5;
            subcriberViewInScroll.layer.masksToBounds = true;
            [subcriberViewInScroll addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnScrollerViews:)]];
          [_scrollView addSubview:subcriberViewInScroll];
        }else{
            if(keys.count!=1){
            [self addDefaultImage:sub
                            xAxis:xAxis
                            widht:100
                           height: _scrollView.frame.size.height
                        container:@"sub" tagValue:tag];
            }
            
        }//else
    
}//addRecyclerView

float defaultImgInitialInScrollViewX;
int defaultImgInitialInScrollTag;

-(void)addDefaultImage:(OTSubscriber *)sub
                 xAxis:(double )xAxis
                 widht:(double )width
                height:(double )height
             container:(NSString *)container
              tagValue:(int )tag
{
    NSString * imageName=(sub.stream.hasVideo)? @"empty" :@"avatar";
    UIImageView *image=[[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
     image.frame = CGRectMake(xAxis, 0,width,height);
    if([maincontainerSub.stream.connection.connectionId isEqual:sub.stream.connection.connectionId]){
        image.layer.borderWidth = 0.8;
       // [image setBackgroundColor:[UIColor whiteColor]];
    }else{
        [image setBackgroundColor:[UIColor darkGrayColor]];
    }
   
    
    if(self.scrollContainerView.frame.size.width!=width){ image.layer.borderColor=[[UIColor redColor] CGColor]; }
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, image.frame.size.width,image.frame.size.height )];
    if(!sub.stream.hasVideo){
    UILabel *videoMutelabel=[[UILabel alloc] initWithFrame:CGRectMake(0,0, label.frame.size.width,label.frame.size.height/4)];
    videoMutelabel.textColor=[UIColor redColor];
    videoMutelabel.textAlignment = NSTextAlignmentCenter;
    videoMutelabel.text=([container isEqualToString:@"main"])? @"Video muted" :@"Muted";
    [label addSubview:videoMutelabel];
    }
    label.textColor=(sub.stream.hasVideo)? [UIColor blackColor]:[UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text=sub.stream.name;
    [image addSubview:label];
    image.tag=tag;
    image.layer.cornerRadius=5;
    image.layer.masksToBounds=true;
    image.userInteractionEnabled=YES;
    if(![maincontainerSub.stream.connection.connectionId isEqual:sub.stream.connection.connectionId]){
        [image addGestureRecognizer: [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnScrollerViews:)]];
    }else{
        defaultImgInitialInScrollViewX=xAxis;
        defaultImgInitialInScrollTag=tag;
    }
    //[self addTapActionToUIview:image];
    if([container isEqual:@"main"]){
        [self.scrollContainerView addSubview:image];
    }else{
        [_scrollView addSubview:image];
    }
}//addDefaultImage

- (IBAction)enableAndDisableOfScrollContainerAudioBtn:(id)sender {
    
    if(maincontainerSub.subscribeToAudio==YES){
        [self adjustSubscriberAudio:NO subscriber:maincontainerSub button:_scrollContainerAudioBtn];
    }else{
        [self adjustSubscriberAudio:YES subscriber:maincontainerSub button:_scrollContainerAudioBtn];
    }
}

-(void)adjustSubscriberAudio:(Boolean )value subscriber:(OTSubscriber *)sub button:(UIButton *)button{
    sub.subscribeToAudio=value;
    if(value){
        [button setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
    }else{
        [button setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
    }
}

- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    NSLog(@"subscriber could not connect to stream");
}

//NSString* selectedItem;
bool disabled;
int indexValue;
- (void)subscriberVideoDisabled:(OTSubscriber *)subscriber reason:(OTSubscriberVideoEventReason)reason{
    NSLog(@"subscriber video disabled. ---   %@",subscriber);
    disabled=YES;
    if(keys !=nil){
    int index=(int)[keys indexOfObject:subscriber.stream.connection.connectionId];
    indexValue=index;
    NSLog(@" ----------- %d",index);
    [_allSubcribersPresentVideos setObject:@"yes" forKey:subscriber.stream.connection.connectionId];
        if(changeveiw){
            [self shuffle];
        }else {
            [self recyclerView];
        }
    }
}
- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
  NSLog(@"subscriber video enabled. ---   %@",subscriber);
    disabled=NO;
    if(keys !=nil){
       int index=(int)[keys indexOfObject:subscriber.stream.connection.connectionId];
       indexValue=index;
       [_allSubcribersPresentVideos setObject:@"no" forKey:subscriber.stream.connection.connectionId];
       if(changeveiw){[self shuffle];}else {[self recyclerView]; }
    }
}

#pragma mark - Other Interactions
- (IBAction)toggleAudioSubscribe:(id)sender
{
    if (_publisher.publishAudio == YES) {
        _publisher.publishAudio = NO;
        [self.audioSubUnsubButton setImage:[UIImage imageNamed:@"ic_pause_audio"] forState:UIControlStateNormal];
        
    } else {
        _publisher.publishAudio = YES;
        [self.audioSubUnsubButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
    }
    
}
/*dealloc*/
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
}//dealloc
#pragma mark - Helper Methods
- (IBAction)endCallAction:(UIButton *)button{
    sessionDisconnect=YES;
    if (_session) {
        // disconnect session
        NSLog(@"disconnecting....");
        [self destroyAll];
    }
}
/*--------toggleVideo------*/
- (IBAction)toggleVideo:(id)sender {
    if (_publisher.publishVideo == YES) {
        _publisher.publishVideo = NO;
        [self.videoSubUnsubButton setImage:[UIImage imageNamed:@"ic_pause_video"] forState:UIControlStateNormal];
        [self.publisherDeaultImage setHidden:NO];
    } else {
        _publisher.publishVideo = YES;
        [self.videoSubUnsubButton setImage:[UIImage imageNamed:@"ic_play_video"] forState:UIControlStateNormal];
        [self.publisherDeaultImage setHidden:YES];
    }
}//toggleVideo
/*---------toggleMuteUnmuteAllButton------*/
- (IBAction)toggleMuteUnmuteAllButton:(id)sender {
    
    if([_muteUnmuteAllButton.titleLabel.text isEqualToString:@"Mute all"]){
        [_muteUnmuteAllButton setTitle:@"Unmute all" forState:UIControlStateNormal];
        [self enableAndDisableAllSubscriberAudios:false];
    }else{
        [_muteUnmuteAllButton setTitle:@"Mute all" forState:UIControlStateNormal];
        [self enableAndDisableAllSubscriberAudios:true];
    }
}//toggleMuteUnmuteAllButton

/*------connection created ---------*/
- (void)  session:(OTSession *)session
connectionCreated:(OTConnection *)connection
{
     sessionDisconnect=NO;
    NSLog(@"----session connectionCreated------- %@",connection
          .connectionId);
  
}//connection created
/*--------------connection destroyed-------*/
- (void)    session:(OTSession *)session
connectionDestroyed:(OTConnection *)connection
{
            // [self.messegeForUser setHidden:NO];
    NSLog(@"session connectionDestroyed (%@)", connection.data);
   
    if(_allSubscribers.count==0){[_messegeForUser setHidden:NO]; //[self.defaultimage setHidden:YES]; //[self.subscriberOneAudioAdjustBtn setHidden:YES];
        
    }
    if(_allSubcribersPresentVideos.count>0){
        [_allSubcribersPresentVideos removeObjectForKey:connection.connectionId];
    }
    
}//connectionDestroyed
@end

