//
//  OGVViewController.m
//  OgvKit
//
//  Created by Brion Vibber on 02/08/2015.
//  Copyright (c) 2014-2015 Brion Vibber. All rights reserved.
//

#import "OGVViewController.h"

#import "OGVExampleItem.h"

@interface OGVViewController ()

@end

@implementation OGVViewController
{
    NSArray *sources;

    NSInteger selectedSource;
    OGVExampleItem *source;

    NSArray *formats;
    NSString *format;

    NSArray *resolutions;
    int resolution;

    BOOL firstTime;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    sources = @[
                // Wikipedia stuff
                [[OGVExampleItem alloc] initWithTitle:@"Wikipedia VisualEditor"
                                             filename:@"Sneak Preview - Wikipedia VisualEditor.webm"],
                [[OGVExampleItem alloc] initWithTitle:@"¿Qué es Wikipedia?"
                                             filename:@"¿Qué es Wikipedia?.ogv"],
                [[OGVExampleItem alloc] initWithTitle:@"Wiki Makes Video (60fps)"
                                             filename:@"Wiki Makes Video Intro 4 26.webm"],

                // Third-party stuff
                [[OGVExampleItem alloc] initWithTitle:@"Open Access Empowers"
                                             filename:@"How_Open_Access_Empowered_a_16-Year-Old_to_Make_Cancer_Breakthrough.ogv"],
                [[OGVExampleItem alloc] initWithTitle:@"Curiosity's Seven Minutes of Terror"
                                             filename:@"Curiosity's Seven Minutes of Terror.ogv"],
                [[OGVExampleItem alloc] initWithTitle:@"Hamilton Mixtape (60fps)"
                                             filename:@"Hamilton_Mixtape_(12_May_2009_live_at_the_White_House)_Lin-Manuel_Miranda.ogv"],
                [[OGVExampleItem alloc] initWithTitle:@"Alaskan Huskies"
                                             filename:@"Alaskan_Huskies_-_Sled_Dogs_-_Ivalo_2013.ogv"],

                // Blender open movies
                [[OGVExampleItem alloc] initWithTitle:@"Sintel"
                                             filename:@"Sintel_movie_4K.webm"],
                [[OGVExampleItem alloc] initWithTitle:@"Tears of Steel"
                                             filename:@"Tears_of_Steel_1080p.webm"],
                [[OGVExampleItem alloc] initWithTitle:@"Big Buck Bunny (60fps)"
                                             filename:@"Big_Buck_Bunny_4K.webm"],

                // Short tests
                [[OGVExampleItem alloc] initWithTitle:@"Myopa (video only)"
                                             filename:@"Myopa_-_2015-05-02.webm"],

                // Audio tests
                //[[OGVExampleItem alloc] initWithTitle:@"Arigato (short audio)"
                //                             filename:@"Ja-arigato.oga"],
                [[OGVExampleItem alloc] initWithTitle:@"Bach C Major Prelude Werckmeister"
                                             filename:@"Bach_C_Major_Prelude_Werckmeister.ogg"]];

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"generic"];
    
    self.player.delegate = self;

    format = @"webm";
    resolution = 360;
    firstTime = YES;
    [self selectSource:0];
}

- (void)selectSource:(NSInteger)index
{
    selectedSource = index;
    if (selectedSource >= 0) {
        source = sources[index];

        [self updateFormats];
        [self updateResolutions];

        if ([resolutions count]) {
            self.player.sourceURL = [source URLforVideoFormat:format resolution:resolution];
        } else {
            self.player.sourceURL = [source URLforAudioFormat:format];
        }
        // @todo separate load & play...
        //[self.player play];
    }
}

- (IBAction)selectFormat:(id)sender {
    source.playbackPosition = self.player.playbackPosition;

    format = formats[self.formatSelector.selectedSegmentIndex];
    [self updateFormats];
    [self updateResolutions];
    [self selectSource:selectedSource];
}

- (void)updateFormats
{
    formats = [source formats];
    if (![formats containsObject:format]) {
        if ([formats containsObject:@"webm"]) {
            // prefer webm over ogv
            format = @"webm";
        } else {
            format = formats[0];
        }
    }
    
    [self.formatSelector removeAllSegments];
    for (int i = 0; i < [formats count]; i++) {
        NSString *title = formats[i];
        [self.formatSelector insertSegmentWithTitle:title
                                                atIndex:i
                                               animated:NO];
        if ([format isEqualToString:formats[i]]) {
            self.formatSelector.selectedSegmentIndex = i;
        }
    }
}

- (void)updateResolutions
{
    resolutions = [source resolutionsForFormat:format];

    int minRes = 0, maxRes = 0;
    if ([resolutions count]) {
        minRes = [resolutions[0] intValue];
        maxRes = [resolutions[[resolutions count] - 1] intValue];
        resolution = MAX(resolution, minRes);
        resolution = MIN(resolution, maxRes);

        [self.resolutionSelector removeAllSegments];
        for (int i = 0; i < [resolutions count]; i++) {
            int res = [resolutions[i] intValue];
            NSString *title = [NSString stringWithFormat:@"%dp", res];
            [self.resolutionSelector insertSegmentWithTitle:title
                                                    atIndex:i
                                                   animated:NO];
            if (resolution == res) {
                self.resolutionSelector.selectedSegmentIndex = i;
            }
        }
    } else {
        [self.resolutionSelector removeAllSegments];
        [self.resolutionSelector insertSegmentWithTitle:@"audio"
                                                atIndex:0
                                               animated:NO];
    }
}

- (IBAction)resolutionSelected:(id)sender {
    source.playbackPosition = self.player.playbackPosition;
    
    if ([resolutions count]) {
        resolution = [resolutions[self.resolutionSelector.selectedSegmentIndex] intValue];
    }

    [self selectSource:selectedSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"generic"];
    OGVExampleItem *item = sources[indexPath.item];
    cell.textLabel.text = item.title;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [sources count];
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (source) {
        source.playbackPosition = self.player.playbackPosition;
    }
    [self selectSource:indexPath.item];
}

#pragma mark - OGVPlayerDelegate methods

- (void)ogvPlayerDidLoadMetadata:(OGVPlayerView *)sender
{
    if (firstTime) {
        // don't autoplay on app launch, it's annoying!
        firstTime = NO;
    } else {
        if (source.playbackPosition > 0) {
            [self.player seek:source.playbackPosition];
        }

        [self.player play];
    }
}

- (void)ogvPlayerDidEnd:(OGVPlayerView *)sender
{
    source.playbackPosition = 0;

    NSInteger nextSource = selectedSource + 1;
    if (nextSource < [sources count]) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:nextSource inSection:0]
                                    animated:YES
                              scrollPosition:UITableViewScrollPositionNone];
        [self selectSource:nextSource];
    }
}

@end
