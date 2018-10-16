
#import "InterfaceView.h"
#import "PlayerView.h"
#import "VBPlayer.h"

static NSUInteger kToolbarPlaybackButtonItemIndex = 1;
static void *kPlayerStatusObserveContext = &kPlayerStatusObserveContext;

@interface InterfaceView () <VBPlayerDelegate>

@property (strong, nonatomic) VBPlayer *player;
@property (strong, nonatomic) PlayerView *playerView;
@property (strong, nonatomic) UIToolbar *toolbar;
@property (strong, nonatomic) UIBarButtonItem *playButton;
@property (strong, nonatomic) UIBarButtonItem *stopButton;

@property (strong, nonatomic) UILabel* currentTimeLabel;
@property (strong, nonatomic) UILabel* remainingTimeLabel;
@property (strong, nonatomic) UISlider* timeSeekSlider;
@property (strong, nonatomic) UIButton* cancelBtn;

@property (assign, nonatomic) BOOL isStream;
@property (strong, nonatomic) NSTimer* myTimer;
@property (strong, nonatomic)NSString* urlStr;

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
@end

@implementation InterfaceView

- (id)initWithFrame:(CGRect)theFrame str:(NSString*) urlString
{
    self = [super initWithFrame:theFrame];
    
    if (self)
    {
        [self initObject:urlString];
    }
    return self;
}

- (void)initObject:(NSString*) urlString
{
    
    self.backgroundColor = [UIColor colorWithRed:57/255.0 green:57/255.0 blue:58/255.0 alpha:1.0];
//    self.accessibilityFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
                            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.isStream = NO;
    self.urlStr = urlString;
    
    self.playerView = [[PlayerView alloc] initWithFrame:self.bounds];
    self.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:self.playerView];

    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.bounds.size.height - 45.0f, self.bounds.size.width, 45.0f)];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin |
                                    UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                    UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.toolbar.barStyle = UIBarStyleDefault;
    [self.toolbar sizeToFit];

    // Set toolbar items
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:[[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace)
                    target:nil action:nil] ];
    self.playButton = [[UIBarButtonItem alloc]
                     initWithBarButtonSystemItem:(UIBarButtonSystemItemPlay)
                     target:self action:@selector(togglePlayback:)];
    self.stopButton = [[UIBarButtonItem alloc]
                      initWithBarButtonSystemItem:(UIBarButtonSystemItemPause)
                      target:self action:@selector(togglePlayback:)];
    [items addObject:self.playButton];
    [items addObject:[[UIBarButtonItem alloc]
                    initWithBarButtonSystemItem:(UIBarButtonSystemItemFlexibleSpace)
                    target:nil action:nil]];
    self.toolbar.items = items;
    
    [self addSubview:self.toolbar];
    
  
  // Init loading view
  self.loadingView = [[UIActivityIndicatorView alloc]
                      initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleWhiteLarge)];
  self.loadingView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin
                                       | UIViewAutoresizingFlexibleRightMargin
                                       | UIViewAutoresizingFlexibleBottomMargin
                                       | UIViewAutoresizingFlexibleTopMargin);
    
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin |
                                        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.cancelBtn setFrame:CGRectMake(self.bounds.size.width - 85.0f, 30.0f, 80.0f, 30.0f)];
    [self.cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.cancelBtn setBackgroundColor:[UIColor clearColor]];
    [self.cancelBtn addTarget:self action:@selector(actionCancel:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.cancelBtn];
    
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, self.bounds.size.height - 100.0f, 40.0f, 30.0f)];
    self.currentTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleTopMargin;
    [self.currentTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.currentTimeLabel setTextColor:[UIColor whiteColor]];
    [self.currentTimeLabel setText:@"0:00"];
    [self addSubview:self.currentTimeLabel];
    
    self.remainingTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - 50.0f, self.bounds.size.height - 100.0f, 40.0f, 30.0f)];
    self.remainingTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                                                UIViewAutoresizingFlexibleTopMargin;
    [self.remainingTimeLabel setBackgroundColor:[UIColor clearColor]];
    [self.remainingTimeLabel setTextColor:[UIColor whiteColor]];
    [self.remainingTimeLabel setText:@"0:00"];
    [self addSubview:self.remainingTimeLabel];

    self.timeSeekSlider = [[UISlider alloc] initWithFrame:CGRectMake(70.0f, self.bounds.size.height - 100.0f, self.bounds.size.width - 140.0f, 30.0f)];
    self.timeSeekSlider.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight |
                            UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
                            UIViewAutoresizingFlexibleTopMargin;
    [self.timeSeekSlider setMinimumValue:0.0f];
    [self.timeSeekSlider setMaximumValue:1.0f];
    [self.timeSeekSlider setValue:0.0f];
    [self.timeSeekSlider addTarget:self action:@selector(actionTimeSeekSliderChanging:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.timeSeekSlider];
    
}

- (void)togglePlayback:(UIBarButtonItem *)sender
{
    NSMutableArray *items = [self.toolbar.items mutableCopy];

    if (sender == self.playButton)
    {
        [self start];
        [items replaceObjectAtIndex:kToolbarPlaybackButtonItemIndex withObject:self.stopButton];
    }
    else
    {
        [self stop];
        [items replaceObjectAtIndex:kToolbarPlaybackButtonItemIndex withObject:self.playButton];
  }
    
  self.toolbar.items = items;
}

- (void)start {
    
    if (!self.isStream)
    {
        [self setLoadingVisible:YES];
        
        self.player = [[VBPlayer alloc]
                       // Viblast: You can also try with your favourite HLS or DASH stream :)
                       initWithCDN:self.urlStr];
        
        // self.player = [[VBPlayer alloc]
        //                // Viblast: You can also try with your favourite HLS or DASH stream :)
        //                initWithCDN:@"https://barakyah-vod.secdn.net/barakyah-vod/play/mp4:sestore1/barakyah/newsystem/dev_SpaceX-CRS12-Launches-to-the-International-Space-Stationmp4_1532640706091.mp4/manifest_mpm4sav_mvtime.mpd"];
        // self.player.delegate = self;
        
        [self.player addObserver:self
                      forKeyPath:@"status"
                         options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial)
                         context:kPlayerStatusObserveContext];
        
        
        self.myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f
                                                        target:self
                                                      selector:@selector(_timerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
        

    }
    else
    {
        [self.player play];
    }
}

- (void)_timerFired:(NSTimer *)timer
{
    if (self.isStream)
    {
        CMTime currentTime = self.player.currentTime;
        CGFloat fSec = CMTimeGetSeconds(currentTime);
        int nMin = (int)fSec / 60;
        int nSec = (int)fSec % 60;
        
        [self.currentTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", nMin, nSec]];
        
        
        CMTime duration = self.player.duration;
        CGFloat fDuration = CMTimeGetSeconds(duration);
        CGFloat fRemainingTime = fDuration - fSec;
        
        nMin = (int)fRemainingTime / 60;
        nSec = (int)fRemainingTime % 60;
        [self.remainingTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", nMin, nSec]];
        
        
        [self.timeSeekSlider setValue:fSec];
    }
}

- (void)stop
{
    [self setLoadingVisible:NO];
    
    [self.player pause];
    
//  [self.player removeObserver:self forKeyPath:@"status"];
  
//  self.player = nil;
}

- (void)setLoadingVisible:(BOOL)visible {
  if (!visible) {
    [self.loadingView stopAnimating];
    [self.loadingView removeFromSuperview];
  } else {
    self.loadingView.center = CGPointMake(CGRectGetWidth(self.playerView.bounds)/2.0,
                                          CGRectGetHeight(self.playerView.bounds)/2.0);
    [self.playerView addSubview:self.loadingView];
    [self.playerView bringSubviewToFront:self.loadingView];
    [self.loadingView startAnimating];
  }
}


- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
  if (context == kPlayerStatusObserveContext) {
    switch (self.player.status) {
      case VBPlayerStatusUnknown: {
        break;
      }
      case VBPlayerStatusReadyToPlay: {
          
          if (!self.isStream)
          {
              [self setLoadingVisible:NO];
              
              [self.player setDisplayLayer:[self.playerView displayLayer]];
              [self.player play];

              CGFloat fTime = CMTimeGetSeconds(self.player.duration);
              int nMin = (int) fTime / 60;
              int nSec = (int) fTime % 60;
              [self.remainingTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", nMin, nSec]];

              [self.timeSeekSlider setMaximumValue:fTime];
              
              self.isStream = YES;
          }
          
        break;
      }
      case VBPlayerStatusFailed: {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error"
                              message:[self.player.error localizedDescription]
                              delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles: nil];
        [alert show];
        
        // Restore playback interface
        NSMutableArray *items = [self.toolbar.items mutableCopy];
        [items replaceObjectAtIndex:kToolbarPlaybackButtonItemIndex withObject:self.playButton];
        self.toolbar.items = items;
        break;
      }
    }
  }
}

- (void)playerDidEnterStall:(VBPlayer *)player {
  [self setLoadingVisible:YES];
}

- (void)playerDidExitStall:(VBPlayer *)player {
  [self setLoadingVisible:NO];
}


#pragma mark -
#pragma mark - Cancel Button

-(void) actionCancel:(id) sender
{
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.myTimer invalidate];
        [self.player pause];
        [self removeFromSuperview];
        
    });
}

-(void) actionTimeSeekSliderChanging:(id) sender
{
    if (self.isStream)
    {
        CGFloat value = self.timeSeekSlider.value;
        
        CMTime duration = self.player.duration;
        
        [self.player seekToTime:CMTimeMakeWithSeconds(value, duration.timescale)];
    }
}


@end
