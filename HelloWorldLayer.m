//
//  HelloWorldLayer.m
//  SpaceGame
//
//  Created by Stephen Asamoah on 28/05/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "SimpleAudioEngine.h"
#import "CCParallaxNode-Extras.h"
//#import "CCParallaxNode-Extras.h"
#import "Projectile.h"



// Needed to obtain the Navigation Controller
#import "AppDelegate.h"

#pragma mark - HelloWorldLayer

#define kNumAsteroids  15
#define kNumLazer 5

// HelloWorldLayer implementation
@implementation HelloWorldLayer

// Helper class method that creates a Scene with the HelloWorldLayer as the only child.
+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super's" return value
	if( (self=[super init]) ) {
		
		// create and initialize a Label
		self.gameTitleLabel = [CCLabelTTF labelWithString:@"Space Exploit" fontName:@"Marker Felt" fontSize:64];

		// ask director for the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
	
		// position the label on the center of the screen
		self.gameTitleLabel.position =  ccp( size.width /2 , size.height/2 );
		
		// add the label as a child to this Layer
		[self addChild: self.gameTitleLabel];
		
        CCLabelBMFont *labelstart;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            labelstart = [CCLabelBMFont labelWithString:@"Play Game" fntFile:@"Arial.fnt"];
        } else {
            labelstart = [CCLabelBMFont labelWithString:@"Play Game" fntFile:@"Arial.fnt"];
        }
        
//        CGSize win = [[CCDirector sharedDirector] winSize];
        self.startItem = [CCMenuItemLabel itemWithTarget:labelstart selector:@selector(gameStart)];
//        self.startItem.scale = 0.9;
//        self.startItem.position = ccp(win.width/2, win.height * 0.35);
        
//        CCMenu *menu = [CCMenu menuWithItems:self.startItem, nil];
//        menu.position = CGPointZero;
//        [self addChild:menu z:0];
//        
//        [self addChild:labelstart];
		
		//
		// Leaderboards and Achievements
		//
		
		// Default font size will be 28 points.
		[CCMenuItemFont setFontSize:28];
        
//        self.mainPageParticle = [CCParticleSystemQuad particleWithFile:@"Stars1.plist"];
//        [self addChild:self.mainPageParticle z:1];
        self.blueGalaxy = [CCParticleSystemQuad particleWithFile:@"HomeParticles.plist"];
        [self addChild:self.blueGalaxy z:-1];
		
		// Achievement Menu Item using blocks
		CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
			
			
			GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
			achivementViewController.achievementDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:achivementViewController animated:YES];
			
			[achivementViewController release];
		}
									   ];

		// Leaderboard Menu Item using blocks
		CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
			
			
			GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
			leaderboardViewController.leaderboardDelegate = self;
			
			AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
			
			[[app navController] presentModalViewController:leaderboardViewController animated:YES];
			
			[leaderboardViewController release];
		}
									   ];
        
        CCMenuItem *startItem = [CCMenuItemFont itemWithString:@"Play Game" block:^(id sender){
            [self gameStart];
        }];
		
		self.mainMenu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, startItem, nil];
		
		[self.mainMenu alignItemsHorizontallyWithPadding:20];
		[self.mainMenu setPosition:ccp( size.width/2, size.height/2 - 50)];
		
		// Add the menu to the layer
		[self addChild:self.mainMenu];

	}
	return self;
}

-(void)gameStart
{
    self.gameTitleLabel.visible = NO;
    self.blueGalaxy.visible = NO;
    self.mainMenu.visible = NO;
    
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"SpaceExploitSprites.pvr.ccz"];
    [self addChild:self.batchNode];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"SpaceExploitSprites.plist"];
    
    self.ship = [CCSprite spriteWithSpriteFrameName:@"Spaceship.png"];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    self.ship.position = ccp(winSize.width * 0.1, winSize.height * 0.5);
    [self.batchNode addChild:self.ship z:1];
    
    // 1) Create the CCParallaxNode
    self.backgroundNode = [CCParallaxNode node];
    [self addChild:self.backgroundNode z:-1];
    
    // 2) Create the sprites we'll add to the CCParallaxNode
    self.sun1 = [CCSprite spriteWithSpriteFrameName:@"moon6.png"];
//    self.sun2 = [CCSprite spriteWithSpriteFrameName:@"moon6.png"];
    self.planetsunrise = [CCSprite spriteWithSpriteFrameName:@"earthSprite.png"];
    self.galaxy  = [CCSprite spriteWithSpriteFrameName:@"bg_galaxy.png"];
    self.spacialanomaly = [CCSprite spriteWithSpriteFrameName:@"bg_spacialanomaly.png"];
    self.spacialanomaly2= [CCSprite spriteWithSpriteFrameName:@"bg_spacialanomaly2.png"];
    self.moon = [CCSprite spriteWithSpriteFrameName:@"moonSprite.png"];
    
    // 3) Determine relative movement speeds for space dust and background
    CGPoint moonSpeed = ccp(0.02, 0.02);
    CGPoint bgSpeed = ccp(0.05, 0.05);
    
    // 4) Add children to CCParallaxNode
    
    [self.backgroundNode addChild:self.sun1 z:-1 parallaxRatio:moonSpeed positionOffset:ccp(0, winSize.height/2)];
//    [self.backgroundNode addChild:self.sun2 z:-1 parallaxRatio:moonSpeed positionOffset:ccp(_sun1.contentSize.width, winSize.height/2)];
    [self.backgroundNode addChild:self.galaxy z:-1 parallaxRatio:bgSpeed positionOffset:ccp(0, winSize.height *0.7)];
    
    [self.backgroundNode addChild:self.moon z:-1 parallaxRatio:bgSpeed positionOffset:ccp(winSize.width/2, winSize.height * 0.5)];
    
    [self.backgroundNode addChild:self.planetsunrise z:-1 parallaxRatio:bgSpeed positionOffset:ccp(600, winSize.height * 0.7)];
    [self.backgroundNode addChild:self.spacialanomaly z:-1 parallaxRatio:bgSpeed positionOffset:ccp(900,winSize.height * 0.3)];
    [self.backgroundNode addChild:self.spacialanomaly2 z:-1 parallaxRatio:bgSpeed positionOffset:ccp(1500,winSize.height * 0.9)];
    
//    NSArray *particlesArray = [NSArray arrayWithObjects:@"TestParticles.plist", @"TestParticles2.plist", @"Stars1.plist", @"Stars2.plist", @"Stars3.plist", nil];
//    for (NSString *particles in particlesArray) {
//        CCParticleSystemQuad *particleEffect = [CCParticleSystemQuad particleWithFile:particles];
//        [self addChild:particleEffect z:1];
//        
//    }
    
    _asteroids = [[CCArray alloc] initWithCapacity:kNumAsteroids];
    for (int i = 0; i<kNumAsteroids; ++i) {
        CCSprite *asteroids = [CCSprite spriteWithSpriteFrameName:@"asteroid01.png"];
        asteroids.visible = NO;
        [_batchNode addChild:asteroids];
        [_asteroids addObject:asteroids];
    }
    
    _shipLasers = [[CCArray alloc] initWithCapacity:kNumLazer];
    for (int i = 0; i<kNumLazer; ++i) {
        CCSprite *shipLazers = [CCSprite spriteWithSpriteFrameName:@"bullets.png"];
        shipLazers.visible = NO;
        [_batchNode addChild:shipLazers];
        [_shipLasers addObject:shipLazers];
    }
    
    _lives = 1;
    double curTime = CACurrentMediaTime();
    _gameOverTime = curTime + 30.0;
    
    
    self.isTouchEnabled = YES;
    
    [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"SpaceGame.caf" loop:YES];
    
    [[SimpleAudioEngine sharedEngine] preloadEffect:@"laser_ship.caf"];
    

    [self scheduleUpdate];
    self.isAccelerometerEnabled = YES;

}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
    
#define kFilteringFactor 0.1
#define kRestAccelX -0.6
#define kShipMaxPointsPerSec (winSize.height*0.5)
#define kMaxDiffX 0.2
    
    UIAccelerationValue rollingX;// rollingY, rollingZ;
    
    rollingX = (acceleration.x * kFilteringFactor);// + (rollingX * (1.0 - kFilteringFactor));
    //  rollingY = (acceleration.y * kFilteringFactor) +  (1.0 - kFilteringFactor);
    //  rollingZ = (acceleration.z * kFilteringFactor) +  (1.0 - kFilteringFactor);
    
    float accelX = acceleration.x - rollingX;
    // float accelY = acceleration.y - rollingY;
    // float accelZ = acceleration.z - rollingZ;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    float accelDiff = accelX - kRestAccelX;
    float accelFraction = accelDiff / kMaxDiffX;
    float pointsPerSec = kShipMaxPointsPerSec * accelFraction;
    
    _shipPointsPerSecY = pointsPerSec;
    
}

- (float)randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

- (void)restartTapped:(id)sender {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:[HelloWorldLayer scene]]];
}
- (void)endScene:(EndReason)endReason {
    
    if (_gameOver) return;
    _gameOver = true;
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message = nil;
    if (endReason == kEndReasonWin) {
        message = @"You win!";
    } else if (endReason == kEndReasonLose) {
        message = @"You lose!";
    }
    
    CCLabelBMFont *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    } else {
        label = [CCLabelBMFont labelWithString:message fntFile:@"Arial.fnt"];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelBMFont *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];
    } else {
        restartLabel = [CCLabelBMFont labelWithString:@"Restart" fntFile:@"Arial.fnt"];
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}
// Add new update method
- (void)update:(ccTime)dt {
    
    CGPoint backgroundScrollVel = ccp(-1000, 0);
    _backgroundNode.position = ccpAdd(_backgroundNode.position, ccpMult(backgroundScrollVel, dt));
    
    // Add at end of your update method
    NSArray *spaceDusts = [NSArray arrayWithObjects:_sun1, nil];
    for (CCSprite *spaceDust in spaceDusts) {
        if ([self.backgroundNode convertToWorldSpace:spaceDust.position].x < -spaceDust.contentSize.width) {
            [self.backgroundNode incrementOffset:ccp(2*spaceDust.contentSize.width,0) forChild:spaceDust];
        }
    }
    
    NSArray *backgrounds = [NSArray arrayWithObjects:_moon, _planetsunrise, _galaxy, _spacialanomaly, _spacialanomaly2, nil];
    for (CCSprite *background in backgrounds) {
        if ([self.backgroundNode convertToWorldSpace:background.position].x < -background.contentSize.width) {
            [self.backgroundNode incrementOffset:ccp(2000,0) forChild:background];
        }
    }
    
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    float maxY = winSize.height - _ship.contentSize.height/2;
    float minY = _ship.contentSize.height/2;
    
    float newY = _ship.position.y + (_shipPointsPerSecY * dt);
    newY = MIN(MAX(newY, minY), maxY);
    _ship.position = ccp(_ship.position.x, newY);
    
    
    double curTime = CACurrentMediaTime();
    
    
    if (curTime > _nextAsteroidSpawn) {
        
        float randSecs = [self randomValueBetween:0.20 andValue:1.0];
        _nextAsteroidSpawn = randSecs + curTime;
        
        float randY = [self randomValueBetween:0.0 andValue:winSize.height];
        float randDuration = [self randomValueBetween:2.0 andValue:10.0];
        
        CCSprite *asteroid = [_asteroids objectAtIndex:_nextAsteroid];
        _nextAsteroid++;
        if (_nextAsteroid >= _asteroids.count) _nextAsteroid = 0;
        
        [asteroid stopAllActions];
        asteroid.position = ccp(winSize.width+asteroid.contentSize.width/2, randY);
        asteroid.visible = YES;
        [asteroid runAction:[CCSequence actions:
                             [CCMoveBy actionWithDuration:randDuration position:ccp(-winSize.width-asteroid.contentSize.width, 0)],
                             [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                             nil]];
        
    }
    
    for (CCSprite *asteroid in _asteroids) {
        if (!asteroid.visible) continue;
        
        for (CCSprite *shipLaser in _shipLasers) {
            if (!shipLaser.visible) continue;
            
            if (CGRectIntersectsRect(shipLaser.boundingBox, asteroid.boundingBox)) {
                [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_small.caf"];
                shipLaser.visible = NO;
                asteroid.visible = NO;
                continue;
            }
        }
        
        if (CGRectIntersectsRect(_ship.boundingBox, asteroid.boundingBox)) {
            [[SimpleAudioEngine sharedEngine] playEffect:@"explosion_small.caf"];
            asteroid.visible = NO;
            [_ship runAction:[CCBlink actionWithDuration:1.0 blinks:9]];
            _lives--;
        }
    }
    
    if (_lives <= 0) {
        [_ship stopAllActions];
        _ship.visible = FALSE;
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"explosion_large.caf"];
        _sunExplosionEffects = [CCParticleSystemQuad particleWithFile:@"SunExplosion.plist"];
        
        _sunExplosionEffects.position = _ship.position;
        [self addChild:_sunExplosionEffects z:1];
        
        _powerupEffects.visible = NO;
        [self endScene:kEndReasonLose];
    } else if (curTime >= _gameOverTime) {
        [self endScene:kEndReasonWin];
    }
    
    
}
- (void)setInvisible:(CCNode *)node {
    node.visible = NO;
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (_nextBullets != nil) return;
    
    [[SimpleAudioEngine sharedEngine] playEffect:@"laser_ship.caf"];
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    CCSprite *shipLaser = [_shipLasers objectAtIndex:_nextShipLaser];
    _nextShipLaser++;
    if (_nextShipLaser >= _shipLasers.count) _nextShipLaser = 0;
    
    shipLaser.position = ccpAdd(_ship.position, ccp(shipLaser.contentSize.width/2, 0));
    shipLaser.visible = YES;
    [shipLaser stopAllActions];
    [shipLaser runAction:[CCSequence actions:
                          // [CCRotateTo actionWithDuration:rotateDuration angle:cocosAngle],
                          [CCMoveBy actionWithDuration:0.5 position:ccp(winSize.width, 0)],
                          [CCCallFuncN actionWithTarget:self selector:@selector(setInvisible:)],
                          nil]];

}
-(void)spriteMoveFinished:(id)sender {
    
	CCSprite *sprite = (CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	
	if (sprite.tag == 1) { // target
		[_bullets removeObject:sprite];
		
	} else if (sprite.tag == 2) { // projectile
		[_bullets removeObject:sprite];
	}
	
}
- (void)finishShoot {
    
    // Ok to add now - we've finished rotation!
    _nextBullets.visible = FALSE;
    
    // Release
    self.nextBullets = nil;
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}
@end
