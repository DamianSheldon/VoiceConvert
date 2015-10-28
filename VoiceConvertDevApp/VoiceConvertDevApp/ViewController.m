//
//  ViewController.m
//  AmrConvertAndRecord
//
//  Created by Jeans on 3/29/13.
//  Copyright (c) 2013 Jeans. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "ViewController.h"

@interface ViewController ()<AVAudioPlayerDelegate>

@end

@implementation ViewController
{
    MPMoviePlayerViewController *_currentAudioPlayerViewController;
}

@synthesize recorderVC,player,originWav,convertAmr,convertWav;
@synthesize palyAMR;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //初始化录音vc
    recorderVC = [[ChatVoiceRecorderVC alloc]init];
    recorderVC.vrbDelegate = self;
    
    //初始化播放器
    player = [[AVAudioPlayer alloc] init];
    
    //添加长按手势
    UILongPressGestureRecognizer *longPrees = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(recordBtnLongPressed:)];
    longPrees.delegate = self;
    [_recordBtn addGestureRecognizer:longPrees];
    [longPrees release];
}

- (void)dealloc{
    [recorderVC release];
    [player release];
    [originWav release];
    [convertWav release];
    [convertWav release];
    [_recordBtn release];
    [_amrTowavLabel release];
    [_wavToamrLabel release];
    [_originWavLabel release];
    [super dealloc];
}
- (void)viewDidUnload {
    [recorderVC release];
    recorderVC = nil;
    [player release];
    player = nil;
    [originWav release];
    originWav = nil;
    [convertWav release];
    convertWav = nil;
    [convertWav release];
    convertWav = nil;
    [self setRecordBtn:nil];
    [self setAmrTowavLabel:nil];
    [self setWavToamrLabel:nil];
    [self setOriginWavLabel:nil];
    [super viewDidUnload];
}
#pragma mark - 长按录音
- (void)recordBtnLongPressed:(UILongPressGestureRecognizer*) longPressedRecognizer{
    //长按开始
    if(longPressedRecognizer.state == UIGestureRecognizerStateBegan) {
        //设置文件名
        self.originWav = [VoiceRecorderBaseVC getCurrentTimeString];
        //开始录音
        [recorderVC beginRecordByFileName:self.originWav];
        
    }//长按结束
    else if(longPressedRecognizer.state == UIGestureRecognizerStateEnded || longPressedRecognizer.state == UIGestureRecognizerStateCancelled){
        
    }
}
#pragma mark - 播放原wav
- (IBAction)playOriginWavBtnPressed:(id)sender {
    if (originWav.length > 0) {
        player = [player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"]] error:nil];
        [player play];
    }
}
#pragma mark - wav转amr
- (IBAction)wavToAmrBtnPressed:(id)sender {
    if (originWav.length > 0){
        NSDate *date = [NSDate date];
        self.convertAmr = [originWav stringByAppendingString:@"wavToAmr"];
        
        //转格式
        [VoiceConverter wavToAmr:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"] amrSavePath:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"]];
        
        [self setLabelByFilePath:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"] fileName:convertAmr convertTime:[[NSDate date] timeIntervalSinceDate:date] label:_wavToamrLabel];
    }
}
#pragma mark - amr转wav
- (IBAction)amrToWavBtnPressed:(id)sender {
    if (convertAmr.length > 0){
        NSDate *date = [NSDate date];
        self.convertWav = [originWav stringByAppendingString:@"amrToWav"];
        
        //转格式
        [VoiceConverter amrToWav:[VoiceRecorderBaseVC getPathByFileName:convertAmr ofType:@"amr"] wavSavePath:[VoiceRecorderBaseVC getPathByFileName:convertWav ofType:@"wav"]];
        
        [self setLabelByFilePath:[VoiceRecorderBaseVC getPathByFileName:convertWav ofType:@"wav"] fileName:convertWav convertTime:[[NSDate date] timeIntervalSinceDate:date] label:_amrTowavLabel];
    }
}
#pragma mark - 播放转换后wav
- (IBAction)playConvertWavBtnPressed:(id)sender {
    if (convertWav.length > 0){
        player = [player initWithContentsOfURL:[NSURL URLWithString:[VoiceRecorderBaseVC getPathByFileName:convertWav ofType:@"wav"]] error:nil];
        [player play];
    }
}

- (IBAction)play:(id)sender {
    
    if (originWav.length > 0) {
        [self presentAudioPlayerViewControllerWithURL:[NSURL fileURLWithPath:[VoiceRecorderBaseVC getPathByFileName:originWav ofType:@"wav"]]];
    }
}

#pragma mark - VoiceRecorderBaseVC Delegate Methods
//录音完成回调，返回文件路径和文件名
- (void)VoiceRecorderBaseVCRecordFinish:(NSString *)_filePath fileName:(NSString*)_fileName{
    NSLog(@"录音完成，文件路径:%@",_filePath);
    [self setLabelByFilePath:_filePath fileName:_fileName convertTime:0 label:_originWavLabel];
}

#pragma mark - 根据文件设置label
- (void)setLabelByFilePath:(NSString*)_filePath fileName:(NSString*)_fileName convertTime:(NSTimeInterval)_convertTime label:(UILabel*)_label{

    NSInteger size = [self getFileSize:_filePath]/1024;
    _label.text = [NSString stringWithFormat:@"文件名：%@\n文件大小：%dkb\n",_fileName,size];
    
    NSRange range = [_filePath rangeOfString:@"wav"];
    if (range.length > 0) {
        AVAudioPlayer *play = [[AVAudioPlayer alloc]initWithContentsOfURL:[NSURL URLWithString:_filePath] error:nil];
        _label.text = [_label.text stringByAppendingFormat:@"文件时长:%f\n",play.duration];
    }
    
    if (_convertTime > 0)
        _label.text = [_label.text stringByAppendingFormat:@"转换时间：%f",_convertTime];
}
#pragma mark - 获取文件大小
- (NSInteger) getFileSize:(NSString*) path{
    NSFileManager * filemanager = [[[NSFileManager alloc]init] autorelease];
    if([filemanager fileExistsAtPath:path]){
        NSDictionary * attributes = [filemanager attributesOfItemAtPath:path error:nil];
        NSNumber *theFileSize;
        if ( (theFileSize = [attributes objectForKey:NSFileSize]) )
            return  [theFileSize intValue];
        else
            return -1;
    }
    else{
        return -1;
    }
}

- (void)presentAudioPlayerViewControllerWithURL:(NSURL *)url
{
    // Setup player
    _currentAudioPlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:url];
    [_currentAudioPlayerViewController.moviePlayer prepareToPlay];
    _currentAudioPlayerViewController.moviePlayer.shouldAutoplay = YES;
    _currentAudioPlayerViewController.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    _currentAudioPlayerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // Remove the movie player view controller from the "playback did finish" notification observers
    // Observe ourselves so we can get it to use the crossfade transition
    [[NSNotificationCenter defaultCenter] removeObserver:_currentAudioPlayerViewController
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_currentAudioPlayerViewController.moviePlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(audioFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_currentAudioPlayerViewController.moviePlayer];
    
    // Show
    [self presentViewController:_currentAudioPlayerViewController animated:YES completion:nil];
}

- (void)audioFinishedCallback:(NSNotification*)notification {
    
    // Remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:_currentAudioPlayerViewController.moviePlayer];
    
    // Clear up
    [self clearCurrentAudio];
    
    // Dismiss
    BOOL error = [[[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue] == MPMovieFinishReasonPlaybackError;
    if (error) {
        // Error occured so dismiss with a delay incase error was immediate and we need to wait to dismiss the VC
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)clearCurrentAudio {
    if (!_currentAudioPlayerViewController) return;
    _currentAudioPlayerViewController = nil;
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error
{
    UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"audioPlayerDecodeErrorDidOccur" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] autorelease];
    
    [alertView show];
}

@end
