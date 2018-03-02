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
OTPublisherDelegate,UIGestureRecognizerDelegate>
{
    OTSession *_session;
    OTPublisher *_publisher;
    OTSubscriber *_currentSubscriber;
    BOOL isFullScreen;
}
@property (weak, nonatomic) IBOutlet UIView *publisherView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UIView *subscriberView;
@property (weak, nonatomic) IBOutlet UIView *subscribersViewTwoLayout;
@property (weak, nonatomic) IBOutlet UIView *subscriberViewTwo1;
@property (weak, nonatomic) IBOutlet UIView *subscriberViewtwo2;
@property (weak, nonatomic) IBOutlet UIView *subscriberViewsFourLayout;
@property (weak, nonatomic) IBOutlet UIView *subscriberFour1;
@property (weak, nonatomic) IBOutlet UIView *subscriberFour2;
@property (weak, nonatomic) IBOutlet UIView *subscriberFour3;
@property (weak, nonatomic) IBOutlet UIView *subscriberFour4;
@property (weak, nonatomic) IBOutlet UIView *subscriberViewsThreeLayout;
@property (weak, nonatomic) IBOutlet UIView *subscriberThree1;
@property (weak, nonatomic) IBOutlet UIView *subscriberThree2;
@property (weak, nonatomic) IBOutlet UIView *subscriberThree3;
@property (strong, nonatomic) IBOutlet UIButton *exitBtn;
@property (weak, nonatomic) IBOutlet UIButton *swapCameraButton;

@property (strong, nonatomic) IBOutlet UIButton *audioSubUnsubButton;
@property (strong, nonatomic) IBOutlet UIButton *videoSubUnsubButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) IBOutlet UIImageView *defaultimage;
@property (weak, nonatomic) IBOutlet UIImageView *publisherDeaultImage;
@property (weak, nonatomic) IBOutlet UIImageView *subTwoLayerOneDefaultImage;
@property (weak, nonatomic) IBOutlet UIImageView *subTwoLayerTwoDefaultImage;


@property (strong, nonatomic) NSTimer *overlayTimer;
@property (nonatomic, strong) UIAlertController *alert;
@property (weak, nonatomic) IBOutlet UIImageView *subThreeLayerDefaultImg1;
@property (weak, nonatomic) IBOutlet UIImageView *subThreeLayerDefaultImg2;
@property (weak, nonatomic) IBOutlet UIImageView *subThreeLayerDefaultImg3;
@property (weak, nonatomic) IBOutlet UIImageView *subFourLayerDefault1;
@property (weak, nonatomic) IBOutlet UIImageView *subFourLayerDefault2;
@property (weak, nonatomic) IBOutlet UIImageView *subFourLayerDefault3;
@property (weak, nonatomic) IBOutlet UIImageView *subFourLayerDefault4;


@property (weak, nonatomic) IBOutlet UILabel *sessionReconnectingMsgLabel;

@property (weak, nonatomic) IBOutlet UIButton *subscriberOneAudioAdjustBtn;

@property (weak, nonatomic) IBOutlet UIButton *subTwoOneAudioAdjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *subTwoTwoAudioAdjustBtn;

@property (weak, nonatomic) IBOutlet UIButton *subThreeThreeAudioAdjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *subThreeTwoAudioAdjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *subThreeOneAudioAdjustBtn;

@property (weak, nonatomic) IBOutlet UIButton *subFourOneAudioAdjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *subFourTwoAudioAdjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *subFourThreeAudioAdjustBtn;
@property (weak, nonatomic) IBOutlet UIButton *subFourFourAudioAdjustBtn;


- (void)showReconnectingAlert;
- (void)dismissReconnectingAlert;
/*- (void)showAlertWithMessage:(NSString *)message
                       title:(NSString *)title
          showDissmissButton:(BOOL)showButton;*/
@property (weak, nonatomic) IBOutlet UILabel *timer;
@property (weak, nonatomic) IBOutlet UILabel *messegeForUser;
@property NSMutableDictionary *allSubscribers;//
@property NSMutableDictionary *allSubcribersPresentVideos;
@property NSMutableDictionary *allStreams;
@property NSMutableArray *allConnectionIds;
@end

@implementation LiveViewController
double countDownTimerMilliSeconds;
NSString *comingView;
int groupSize;
NSArray *buttons;
NSArray *audioButtons;
bool sessionDisconnect=NO;
- (void)viewDidLoad {
    [super viewDidLoad];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self setHidden];
    buttons=[NSArray arrayWithObjects:_exitBtn,_audioSubUnsubButton,_videoSubUnsubButton,_swapCameraButton,nil];
    audioButtons=[NSArray arrayWithObjects:_subscriberOneAudioAdjustBtn,_subTwoOneAudioAdjustBtn,_subTwoTwoAudioAdjustBtn,_subThreeThreeAudioAdjustBtn,_subThreeTwoAudioAdjustBtn,_subThreeOneAudioAdjustBtn,_subFourOneAudioAdjustBtn,_subFourTwoAudioAdjustBtn,_subFourThreeAudioAdjustBtn,_subFourFourAudioAdjustBtn, nil];
    [self setBorderForAudioButtons];
    _allSubscribers=[[NSMutableDictionary alloc] init];//initializing the variables
    _allStreams=[[NSMutableDictionary alloc] init];
    _allConnectionIds=[[NSMutableArray alloc] init];
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
    
    
    isFullScreen = NO;
    UIPanGestureRecognizer * pan1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveObject:)];
    pan1.minimumNumberOfTouches = 1;
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
- (void)enteringBackgroundMode:(NSNotification*)notification
{
    _publisher.publishVideo = NO;
}

- (void)leavingBackgroundMode:(NSNotification*)notification
{
     [self shuffle];
    _publisher.publishVideo = YES;
}
- (void) setHidden
{
    [self.sessionReconnectingMsgLabel setHidden:YES];
    [self.publisherDeaultImage setHidden:YES];
    [self.defaultimage setHidden:YES];
    [self.subscriberView setHidden:NO];
    [self.subscribersViewTwoLayout setHidden:YES];
    [self.subscriberViewsFourLayout setHidden:YES];
    [self.subscriberViewsThreeLayout setHidden:YES];
    [self.subFourLayerDefault1 setHidden:YES];
    [self.subFourLayerDefault2 setHidden:YES];
    [self.subFourLayerDefault3 setHidden:YES];
    [self.subFourLayerDefault4 setHidden:YES];
    [self.subThreeLayerDefaultImg1 setHidden:YES];
    [self.subThreeLayerDefaultImg2 setHidden:YES];
    [self.subThreeLayerDefaultImg3 setHidden:YES];
    [self.subTwoLayerOneDefaultImage setHidden:YES];
    [self.subTwoLayerTwoDefaultImage setHidden:YES];
    [self.subscriberOneAudioAdjustBtn setHidden:YES];
}//setHidden Function


- (IBAction)AdjustSubOneAudio:(id)sender {
    [self subOneAudio];
}
- (IBAction)AdjustSubTwoOneAudio:(id)sender {
    [self subOneAudio];
}
- (IBAction)AdjustSubTwoTwoAudio:(id)sender {
    [self subTwoAudio];
}
- (IBAction)AdjustSubThreeOneAudio:(id)sender {
    [self subOneAudio];
}
- (IBAction)AdjustSubThreeTwoAudio:(id)sender {
     [self subTwoAudio];
}
- (IBAction)AdjustSubThreeThreeAudio:(id)sender {
    [self subThreeAudio];
}
- (IBAction)AdjustSubFourOneAudio:(id)sender {
    [self subOneAudio];
}
- (IBAction)AdjustSubFourTwoAudio:(id)sender {
     [self subTwoAudio];
}
- (IBAction)AdjustSubFourThreeAudio:(id)sender {
     [self subThreeAudio];
}
- (IBAction)AdjustSubFourFourAudio:(id)sender {
    [self subFourAudio];
}

-(void)subOneAudio
{
    if(sub1.subscribeToAudio==YES){
        sub1.subscribeToAudio=NO;
        if(keys.count==1){[self subOneOneAudioButtonDisable];}else if(keys.count==2){ [self subTwoOneAudioButtonDisable];}else if(keys.count==3){ [self subThreeOneAudioDisable]; }else{[self subFourOneAudioDisable];};
    }else{
        sub1.subscribeToAudio=YES;
        if(keys.count==1){ [self subOneOneAudioButtonEnable];}else if(keys.count==2){ [self subTwoOneAudioButtonEnable];}else if(keys.count==3){[self subThreeOneAudioEnable];}else{ [self subFourOneAudioEnable];}
    }
}
-(void)subTwoAudio
{
    if(sub2.subscribeToAudio==YES){
        sub2.subscribeToAudio=NO;
        if(keys.count==2){[self subTwoTwoAudioButtonDisable];}else if(keys.count==3){[self subThreeTwoAudioDisable];}else{[self subFourTwoAudioDisable];}
    }else{
        sub2.subscribeToAudio=YES;
        if(keys.count==2){[self subTwoTwoAudioButtonEnable];}else if(keys.count==3){[self subThreeTwoAudioEnable];}else{ [self subFourTwoAudioEnable]; }
    }
}
-(void)subThreeAudio
{
    if(sub3.subscribeToAudio==YES){
        sub3.subscribeToAudio=NO;
        if(keys.count==3){[self subThreeThreeAudioDisable];}else{[self subFourThreeAudioDisable];}
    }else{
        sub3.subscribeToAudio=YES;
         if(keys.count==3){[self subThreeThreeAudioEnable];}else{ [self subFourThreeAudioEnable]; }
    }
}

-(void)subFourAudio
{
    if(sub4.subscribeToAudio==YES){
        sub4.subscribeToAudio=NO;
        [self subFourFourAudioDisable];
    }else{
        sub4.subscribeToAudio=YES;
        [self subFourFourAudioEnable];
    }
}


-(void)moveObject:(UIPanGestureRecognizer *)pan;
{
    _publisherView.center = [pan locationInView:_publisherView.superview];
    _publisherDeaultImage.center=[pan locationInView:_publisherDeaultImage.superview];
}

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

-(void)checkSubscribersList{
    if(_allSubscribers.count>0){
        [self shuffle];
    }
}

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
        [_session disconnect:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        /*  [_session disconnect:nil];
            [self cleanupPublisher];
            [self cleanupSubscriber];
            [self dismissViewControllerAnimated:YES completion:nil];
            [UIApplication sharedApplication].idleTimerDisabled = NO;
            return;*/
    
    }
    
}//updateCountdown
- (void)showReconnectingAlert
{
  /*  [self showAlertWithMessage:@"Session is reconnecting"
                         title:@""
            showDissmissButton:YES];*/
    [self.sessionReconnectingMsgLabel setHidden:NO];
}


- (void)dismissReconnectingAlert
{
    [self.sessionReconnectingMsgLabel setHidden:YES];
}

- (void)sessionDidBeginReconnecting:(OTSession *)session
{
    [self showReconnectingAlert];
}

- (void)sessionDidReconnect:(OTSession *)session
{
    [self dismissReconnectingAlert];
}

/*---showAlertWithMessage---
- (void)showAlertWithMessage:(NSString *)message
                       title:(NSString *)title
          showDissmissButton:(BOOL)showButton
{
       dispatch_async(dispatch_get_main_queue(), ^{
           self.alert = [UIAlertController alertControllerWithTitle:title
                                                            message:message
                                                     preferredStyle:UIAlertControllerStyleAlert];
           if (showButton) {
               UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK"
                                                                style:UIAlertActionStyleCancel
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [self.alert dismissViewControllerAnimated:YES completion:nil];
                                                              }];
               [self.alert addAction:action];
               
           }
           
           [self presentViewController:self.alert animated:YES completion:nil];
           
       });
   
}//showAlertWithMessage */


- (void)setupSession
{
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
    
}

- (void)setupPublisher
{
    // create one time publisher and style publisher
    OTPublisherSettings *settings = [[OTPublisherSettings alloc] init];
    settings.name = [UIDevice currentDevice].name;
    _publisher = [[OTPublisher alloc] initWithDelegate:self settings:settings];
    [_publisher.view setFrame:CGRectMake(0, 0, self.publisherView.frame.size.width, self.publisherView.frame.size.height)];
    [self.publisherView addSubview:_publisher.view];
    [_messegeForUser setHidden:NO];
}


// View Tapped When Hide Back and BottomView
- (void)viewTappedInLive:(UITapGestureRecognizer *)tgr {
    
    if (!isFullScreen) {
        [self.view layoutIfNeeded];
       //self.bottomViewHeight.constant = 0;
        [UIView animateWithDuration:0.5
                         animations:^{
                              [self.bottomView setHidden:YES];//[self.view layoutIfNeeded]; // Called on parent view
                              [self setHideAndShowAudioButtons:true];
                              [self.timer setHidden:YES];
                         }];
        
        isFullScreen = YES;
    }else{
        [self.view layoutIfNeeded];
        //self.bottomViewHeight.constant = 50;
        [UIView animateWithDuration:.5
                         animations:^{
                            [self.bottomView setHidden:NO];//   [self.view layoutIfNeeded]; // Called on parent view
                            [self setHideAndShowAudioButtons:false];
                             [self.timer setHidden:NO];
                         }];
        isFullScreen = NO;
    }
    
    if (self.overlayTimer) {
        [self.overlayTimer invalidate];
    }
    // start overlay hide timer
    self.overlayTimer =
    [NSTimer scheduledTimerWithTimeInterval:10
                                     target:self
                                   selector:@selector(overlayTimerAction)
                                   userInfo:nil
                                    repeats:NO];
    
}

- (void)overlayTimerAction
{
    // Hide views
    if (!isFullScreen) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self viewTappedInLive:[[self.view gestureRecognizers]
                                    objectAtIndex:0]];
        });
        
        //[[[self.view gestureRecognizers] objectAtIndex:0] sendActionsForControlEvents:UIControlEventTouchUpInside];
        
    }else{
        if (self.overlayTimer) {
            [self.overlayTimer invalidate];
        }
    }
}

-(void)setHideAndShowAudioButtons:(BOOL *)value{
    if(keys.count==1){
        [self.subscriberOneAudioAdjustBtn setHidden:value];
    }else if (keys.count==2){
        [self.subTwoOneAudioAdjustBtn setHidden:value];
        [self.subTwoTwoAudioAdjustBtn setHidden:value];
    }else if(keys.count==3){
        [self.subThreeOneAudioAdjustBtn setHidden:value];
        [self.subThreeTwoAudioAdjustBtn setHidden:value];
        [self.subThreeThreeAudioAdjustBtn setHidden:value];
    }else if(keys.count==4){
        [self.subFourOneAudioAdjustBtn setHidden:value];
        [self.subFourTwoAudioAdjustBtn setHidden:value];
        [self.subFourThreeAudioAdjustBtn setHidden:value];
        [self.subFourFourAudioAdjustBtn setHidden:value];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)createSubscriber:(OTStream *)stream
{
    // create subscriber
    _currentSubscriber = [[OTSubscriber alloc]
                          initWithStream:stream delegate:self];
    OTError *error = nil;
    [_session subscribe:_currentSubscriber error:&error];
    if (error)
    {
        //            [self showAlert:[error localizedDescription]];
    }
}


// Open Tok Delegates
# pragma mark - OTSession delegate callbacks

- (void) session:(OTSession *)mySession
   streamCreated:(OTStream *)stream {
    NSLog(@"Connection Meta Data  in mySession streamCreated : %@",stream.connection.data);
   // NSString *publisherId = [self.hybridParams safeObjectForKey:@"trainerUserid"];
    //NSString *streamPublisherId = [NSString stringWithFormat:@"%@",stream.connection.data];
    [self createSubscriber:stream];
}

- (void)sessionDidDisconnect:(OTSession *)session {
    sessionDisconnect=YES;
   /* [self.messegeForUser setHidden:NO];
    NSString* alertMessage =
    [NSString stringWithFormat:@"Session disconnected: (%@)",
     session.sessionId];
   // NSLog(@"sessionDidDisconnect (%@)", alertMessage);*/
    [self destroyAll];
}

-(void) destroyAll
{
    [_session disconnect:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [self cleanupPublisher];
    [_allSubscribers removeAllObjects];
    [_allStreams removeAllObjects];
    return;
}
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
}

- (void)session:(OTSession *)session didFailWithError:(OTError *)error {
}

- (void)session:(OTSession *)session streamDestroyed:(OTStream *)stream{
    NSLog(@"streamDestroyed %@", stream.connection.connectionId);
    OTSubscriber *subscriber = [_allSubscribers objectForKey:stream.connection.connectionId];
    [subscriber.view removeFromSuperview];
    [_allSubscribers removeObjectForKey:stream.connection.connectionId];
    if(_allSubscribers.count==0){
        [_messegeForUser setHidden:NO];
    }
    
    [self shuffle];
   
}
- (void)cleanupSubscriber
{
    [_currentSubscriber.view removeFromSuperview];
    _currentSubscriber = nil;
}

- (void)cleanupPublisher {
    [_publisher.view removeFromSuperview];
    _publisher = nil;
    // this is a good place to notify the end-user that publishing has stopped.
}

# pragma mark - OTPublisher delegate callbacks

// Publisher

- (void)publisher:(OTPublisherKit *)publisher
    streamCreated:(OTStream *)stream
{
    NSLog(@"Connection Meta Data  in publisher streamCreated -------: %@",stream.connection.data);
    /*if([_allConnectionIds containsObject:stream.connection.data]){
        [self showAlertWithMessage:@"Someone"
                             title:@"warning"
                showDissmissButton:YES];
    }else{
        [_allConnectionIds addObject:stream.connection.data];
    }*/
    
    
}
- (void)publisher:(OTPublisherKit*)publisher
  streamDestroyed:(OTStream *)stream
{
    if ([_currentSubscriber.stream.streamId isEqualToString:stream.streamId])
    {
        [self cleanupSubscriber];
    }
    
    [self cleanupPublisher];
}

- (void)publisher:(OTPublisher *)publisher didFailWithError:(OTError *)error
{
    NSLog(@"publisher didFailWithError %@", error);
    NSLog(@"publisher didFailWithError %@", error);
    [self cleanupPublisher];
    
}


# pragma mark - OTSubscriber delegate callbacks
int count=0;
bool streamDestroid=NO;
// Subscriber
- (void)subscriberDidConnectToStream:(OTSubscriberKit *)subscriber
{
    OTSubscriber *sub = (OTSubscriber *)subscriber;
    [_allSubscribers setObject:sub forKey:sub.stream.connection.connectionId];
    if(_allSubscribers.count>0){
        [_messegeForUser setHidden:YES];
    }
    [_allStreams setObject:sub.stream forKey:sub.stream.connection.connectionId];
    [self shuffle];
   //UIView *viewToAdd = sub.view;
    
  //  [_allConnectionIds addObject:sub.stream.connection.connectionId];
    NSLog(@"subscriberDidConnectToStream (%@)",
          subscriber.stream.connection.connectionId);
    
    NSLog(@"----session stream id ------- (%@)", sub.stream.connection.connectionId);

}//subscriberDidCon


OTSubscriber *sub1;
OTSubscriber *sub2;
OTSubscriber *sub3;
OTSubscriber *sub4;
NSArray *keys;
/*-------shuffle-----*/
-(void)shuffle
{
  keys=[_allSubscribers allKeys];
    if(keys.count==1){
       // [self.defaultimage setHidden:YES];
        [self.subscriberViewsFourLayout setHidden:YES];
        [self.subscriberViewsThreeLayout setHidden:YES];
        [self.subscribersViewTwoLayout setHidden:YES];
        [self.subscriberView setHidden:NO];
    }else if(keys.count==2){
        [self.subscriberViewsFourLayout setHidden:YES];
        [self.subscriberViewsThreeLayout setHidden:YES];
        [self.subscribersViewTwoLayout setHidden:YES];
        [self.subscribersViewTwoLayout setHidden:NO];
    }else if(keys.count==3){
        [self.subscriberViewsFourLayout setHidden:YES];
        [self.subscriberViewsThreeLayout setHidden:NO];
    }else if(keys.count==4){
       // [self.subscriberViewsThreeLayout removeFromSuperview];
        [self.subscriberViewsThreeLayout setHidden:YES];
        [self.subscriberViewsFourLayout setHidden:NO];
    }//keys if-else
    

    if(keys.count==1){
        sub1=[ _allSubscribers objectForKey:keys[0]];
        if(sub1.stream.hasVideo){[self.defaultimage setHidden:YES];}else{[self.defaultimage setHidden:NO];}
        if(sub1.subscribeToAudio==YES){ [self subOneOneAudioButtonEnable]; }else{[self subOneOneAudioButtonDisable];}
        [sub1.view setFrame:CGRectMake(0, 0 ,self.subscriberView.frame.size.width ,self.subscriberView.frame.size.height)];
        [self.subscriberView addSubview:sub1.view];
        [self.subscriberOneAudioAdjustBtn setHidden:NO];
    }else if(keys.count==2){
        sub1=[ _allSubscribers objectForKey:keys[0]];
        if(sub1.stream.hasVideo){[self.subTwoLayerOneDefaultImage setHidden:YES];}else{[self.subTwoLayerOneDefaultImage setHidden:NO];}
        if(sub1.subscribeToAudio==YES){[self subTwoOneAudioButtonEnable];}else{ [self subTwoOneAudioButtonDisable];}
        [sub1.view setFrame:CGRectMake(0, 0 ,self.subscriberViewTwo1.frame.size.width ,self.subscriberViewTwo1.frame.size.height)];
        [self.subscriberViewTwo1 addSubview:sub1.view];
        sub2=[ _allSubscribers objectForKey:keys[1]];
        if(sub2.stream.hasVideo){[self.subTwoLayerTwoDefaultImage setHidden:YES];}else{ [self.subTwoLayerTwoDefaultImage setHidden:NO];}
        if(sub2.subscribeToAudio==YES){ [self subTwoTwoAudioButtonEnable]; }else{   [self subTwoTwoAudioButtonDisable];}
        [sub2.view setFrame:CGRectMake(0, 0 ,self.subscriberViewtwo2.frame.size.width ,self.subscriberViewtwo2.frame.size.height)];
        [self.subscriberViewtwo2 addSubview:sub2.view];
    }else if(keys.count==3){
        sub1=[_allSubscribers objectForKey:keys[0]];
        if(sub1.stream.hasVideo){[self.subThreeLayerDefaultImg1 setHidden:YES];}else{ [self.subThreeLayerDefaultImg1 setHidden:NO];}
        if(sub1.subscribeToAudio==YES){[self subThreeOneAudioEnable];}else{ [self subThreeOneAudioDisable]; } //audio
        [sub1.view setFrame:CGRectMake(0, 0 ,self.subscriberThree1.frame.size.width ,self.subscriberThree1.frame.size.height)];
        [self.subscriberThree1 addSubview:sub1.view];
        sub2=[ _allSubscribers objectForKey:keys[1]];
        if(sub2.stream.hasVideo){[self.subThreeLayerDefaultImg2 setHidden:YES]; }else{[self.subThreeLayerDefaultImg2 setHidden:NO];}
        if(sub2.subscribeToAudio==YES){[self subThreeTwoAudioEnable];}else{[self subThreeTwoAudioDisable];}
        [sub2.view setFrame:CGRectMake(0, 0 ,self.subscriberThree2.frame.size.width ,self.subscriberThree2.frame.size.height)];
        [self.subscriberThree2 addSubview:sub2.view];
        sub3=[ _allSubscribers objectForKey:keys[2]];
        if(sub3.stream.hasVideo){[self.subThreeLayerDefaultImg3 setHidden:YES];}else{[self.subThreeLayerDefaultImg3 setHidden:NO];}
        if(sub3.subscribeToAudio==YES){ [self subThreeThreeAudioEnable]; }else{ [self subThreeThreeAudioDisable];}
        [sub3.view setFrame:CGRectMake(0, 0 ,self.subscriberThree3.frame.size.width ,self.subscriberThree3.frame.size.height)];
        [self.subscriberThree3 addSubview:sub3.view];
    }else if(keys.count==4){
        //[self hideAudioButtons];
        sub1=[ _allSubscribers objectForKey:keys[0]];
        if(sub1.stream.hasVideo){[self.subFourLayerDefault1 setHidden:YES]; }else{[self.subFourLayerDefault1 setHidden:NO]; }
        [sub1.view setFrame:CGRectMake(0, 0 ,self.subscriberFour1.frame.size.width ,self.subscriberFour1.frame.size.height)];
        [self.subscriberFour1 addSubview:sub1.view];
        if(sub1.subscribeToAudio==YES){[self subFourOneAudioEnable];}else{[self subFourOneAudioDisable];}
        sub2=[ _allSubscribers objectForKey:keys[1]];
        if(sub2.stream.hasVideo){[self.subFourLayerDefault2 setHidden:YES]; }else{[self.subFourLayerDefault2 setHidden:NO]; }
        [sub2.view setFrame:CGRectMake(0, 0 ,self.subscriberFour2.frame.size.width ,self.subscriberFour2.frame.size.height)];
        [self.subscriberFour2 addSubview:sub2.view];
        if(sub2.subscribeToAudio==YES){[self subFourTwoAudioEnable];}else{[self subFourTwoAudioDisable];}
        sub3=[ _allSubscribers objectForKey:keys[2]];
        if(sub3.stream.hasVideo){[self.subFourLayerDefault3 setHidden:YES]; }else{[self.subFourLayerDefault3 setHidden:NO]; }
        [sub3.view setFrame:CGRectMake(0, 0 ,self.subscriberFour3.frame.size.width ,self.subscriberFour3.frame.size.height)];
        [self.subscriberFour3 addSubview:sub3.view];
         if(sub3.subscribeToAudio==YES){[self subFourThreeAudioEnable];}else{[self subFourThreeAudioDisable];}
        sub4=[ _allSubscribers objectForKey:keys[3]];
        if(sub4.stream.hasVideo){[self.subFourLayerDefault4 setHidden:YES]; }else{[self.subFourLayerDefault4 setHidden:NO]; }
        [sub4.view setFrame:CGRectMake(0, 0 ,self.subscriberFour4.frame.size.width ,self.subscriberFour4.frame.size.height)];
        [self.subscriberFour4 addSubview:sub4.view];
         if(sub4.subscribeToAudio==YES){[self subFourFourAudioEnable];}else{[self subFourFourAudioDisable];}
    }
}//shuffle




-(void) subOneOneAudioButtonEnable
{
    [self.subscriberOneAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subOneOneAudioButtonDisable
{
    [self.subscriberOneAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subTwoOneAudioButtonEnable
{
    [self.subTwoOneAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subTwoTwoAudioButtonEnable
{
    [self.subTwoTwoAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subTwoOneAudioButtonDisable
{
    [self.subTwoOneAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subTwoTwoAudioButtonDisable
{
     [self.subTwoTwoAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subThreeOneAudioEnable
{
     [self.subThreeOneAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subThreeTwoAudioEnable
{
     [self.subThreeTwoAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subThreeThreeAudioEnable
{
    [self.subThreeThreeAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subThreeOneAudioDisable
{
     [self.subThreeOneAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subThreeTwoAudioDisable
{
     [self.subThreeTwoAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subThreeThreeAudioDisable
{
    [self.subThreeThreeAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subFourOneAudioEnable
{
     [self.subFourOneAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subFourTwoAudioEnable
{
    [self.subFourTwoAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subFourThreeAudioEnable
{
     [self.subFourThreeAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subFourFourAudioEnable
{
    [self.subFourFourAudioAdjustBtn setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
}
-(void) subFourOneAudioDisable
{
     [self.subFourOneAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subFourTwoAudioDisable
{
    [self.subFourTwoAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subFourThreeAudioDisable
{
     [self.subFourThreeAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}
-(void) subFourFourAudioDisable
{
    [self.subFourFourAudioAdjustBtn setImage:[UIImage imageNamed:@"noAudio"] forState:UIControlStateNormal];
}


- (void)subscriber:(OTSubscriber *)subscriber didFailWithError:(OTError *)error
{
    NSLog(@"subscriber could not connect to stream");
}

//NSString* selectedItem;
bool disabled;
int indexValue;
- (void)subscriberVideoDisabled:(OTSubscriber *)subscriber
                         reason:(OTSubscriberVideoEventReason)reason
{
    [self.defaultimage setHidden:NO];
    NSLog(@"subscriber video disabled. ---   %@",subscriber);
    disabled=YES;
    if(keys !=nil){
    int index=(int)[keys indexOfObject:subscriber.stream.connection.connectionId];
    indexValue=index;
    //selectedItem=views[index];
    NSLog(@" ----------- %d",index);
    [_allSubcribersPresentVideos setObject:@"yes" forKey:subscriber.stream.connection.connectionId];
    [self adjustSubscribers];
    }
}
- (void)subscriberVideoEnabled:(OTSubscriberKit *)subscriber reason:(OTSubscriberVideoEventReason)reason {
  NSLog(@"subscriber video enabled. ---   %@",subscriber);
   // [self.defaultimage setHidden:YES];
     disabled=NO;
    if(keys !=nil){
     int index=(int)[keys indexOfObject:subscriber.stream.connection.connectionId];
    indexValue=index;
       [_allSubcribersPresentVideos setObject:@"no" forKey:subscriber.stream.connection.connectionId];
     [self adjustSubscribers];
    }
}

-(void)adjustSubscribers
{
    if(keys.count==1){
        if(disabled){ [self.defaultimage setHidden:NO]; }else{ [self.defaultimage setHidden:YES];}
    }else if(keys.count==2){
        if(indexValue==0){
            if(disabled){ [self.subTwoLayerOneDefaultImage setHidden:NO]; }else{ [self.subTwoLayerOneDefaultImage setHidden:YES];}
        }else if(indexValue==1){
            if(disabled){[self.subTwoLayerTwoDefaultImage setHidden:NO]; }else{ [self.subTwoLayerTwoDefaultImage setHidden:YES];}
        }//else if
    }else if(keys.count==3){
        if(indexValue==0){
            if(disabled){[self.subThreeLayerDefaultImg1 setHidden:NO]; }else{ [self.subThreeLayerDefaultImg1 setHidden:YES];}
        }else if(indexValue==1){
            if(disabled){[self.subThreeLayerDefaultImg2 setHidden:NO]; }else{[self.subThreeLayerDefaultImg2 setHidden:YES];}
        }else if(indexValue==2){
            if(disabled){[self.subThreeLayerDefaultImg3 setHidden:NO]; }else{[self.subThreeLayerDefaultImg3 setHidden:YES];}
        }
    }else if(keys.count==4){
        if(indexValue==0){
            if(disabled){[self.subFourLayerDefault1 setHidden:NO]; }else{ [self.subFourLayerDefault1 setHidden:YES]; }
        }else if (indexValue==1){
            if(disabled){ [self.subFourLayerDefault2 setHidden:NO];}else{ [self.subFourLayerDefault2 setHidden:YES]; }
        }else if (indexValue==2){
            if(disabled){[self.subFourLayerDefault3 setHidden:NO]; }else{ [self.subFourLayerDefault3 setHidden:YES]; }
        }else if (indexValue==3){
            if(disabled){[self.subFourLayerDefault4 setHidden:NO]; }else{ [self.subFourLayerDefault4 setHidden:YES]; }
        }
    }
}

#pragma mark - Other Interactions
- (IBAction)toggleAudioSubscribe:(id)sender
{
    if (_publisher.publishAudio == YES) {
        _publisher.publishAudio = NO;
        //        self.audioSubUnsubButton.selected = YES;
        [self.audioSubUnsubButton setImage:[UIImage imageNamed:@"ic_pause_audio"] forState:UIControlStateNormal];
        
    } else {
        _publisher.publishAudio = YES;
        //        self.audioSubUnsubButton.selected = NO;
        [self.audioSubUnsubButton setImage:[UIImage imageNamed:@"unmute"] forState:UIControlStateNormal];
    }
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:UIApplicationDidBecomeActiveNotification
     object:nil];
}

/*- (void)viewDidDisappear:(BOOL)animated
 {
 [super viewDidDisappear:animated];
 [self cleanupPublisher];
 [self cleanupSubscriber];
 }*/

#pragma mark - Helper Methods
- (IBAction)endCallAction:(UIButton *)button
{
    sessionDisconnect=YES;
    if (_session) {
        // disconnect session
        NSLog(@"disconnecting....");
        [self destroyAll];
        /* [_session disconnect:nil];
        [self cleanupPublisher];
        [self cleanupSubscriber];
        [self dismissViewControllerAnimated:YES completion:nil];
        [UIApplication sharedApplication].idleTimerDisabled = NO;
        _allSubscribers=nil;
        return;*/
    }
}
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
    
}

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
   
    if(_allSubscribers.count==0){[_messegeForUser setHidden:NO]; [self.defaultimage setHidden:YES]; [self.subscriberOneAudioAdjustBtn setHidden:YES];}
    if(_allSubcribersPresentVideos.count>0){
        [_allSubcribersPresentVideos removeObjectForKey:connection.connectionId];
    }
    
}//connectionDestroyed



@end

