//
//  HelloWorldLayer.h
//  SpaceGame
//
//  Created by Stephen Asamoah on 28/05/2013.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

typedef enum {
    kEndReasonWin,
    kEndReasonLose
} EndReason;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
//    CCSpriteBatchNode *_batchNode;
//    CCSprite *_ship;
    float _shipPointsPerSecY;
    float _shipPointsPerSecX;
    
    CCArray *_asteroids;
    int _nextAsteroid;
    double _nextAsteroidSpawn;
    
    CCArray *_shipLasers;
    int _nextShipLaser;
    CCSprite *_nextBullets;
    
    int _lives;
    
    double _gameOverTime;
    bool _gameOver;
    CCParticleSystemQuad *_powerupEffects;
    CCParticleSystemQuad *_sunExplosionEffects;
    
    NSMutableArray *_bullets;
}
@property (nonatomic, strong) CCSprite *ship;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) CCMenuItemLabel *startItem;
@property (nonatomic, strong) CCMenu *mainMenu;
@property (nonatomic, strong) CCLabelTTF *gameTitleLabel;
@property (nonatomic, strong) CCParticleSystemQuad *mainPageParticle;
@property (nonatomic, strong) CCParticleSystemQuad *blueGalaxy;
@property (nonatomic, strong) CCParallaxNode *backgroundNode;
@property (nonatomic, strong) CCSprite *sun1;
@property (nonatomic, strong) CCSprite *sun2;
@property (nonatomic, strong) CCSprite *moon;
@property (nonatomic, strong) CCSprite *planetsunrise;
@property (nonatomic, strong) CCSprite *galaxy;
@property (nonatomic, strong) CCSprite *spacialanomaly;
@property (nonatomic, strong) CCSprite *spacialanomaly2;

@property (nonatomic, retain) CCSprite *nextBullets;
// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
