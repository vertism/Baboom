#import <UIKit/UIKit.h>
#import "GLView.h"

typedef enum
{
	NONE = 0,
	UP = 1,
	DOWN = 2,
	LEFT = 4,
	RIGHT = 8
}DIRECTION;

typedef enum
{
	TOP_SIDE = 1,
	BOTTOM_SIDE = 2,
	LEFT_SIDE = 4,
	RIGHT_SIDE = 8
}SIDE;

@interface GLViewController : UIViewController <GLViewDelegate>
{
	UILabel *infoRound;
	UILabel *infoPercent;
	UILabel *infoTime;
	UILabel *percentExpander;
	
	float playerX;
	float playerY;
	float enemyX;
	float enemyY;
	BOOL moving;
	DIRECTION enemyMoving;
	DIRECTION playerMoving;
	SIDE playerSide;
	CGPoint startPosition;
	NSMutableArray *aFilled;
	float percentComplete;
	float totalArea; 
	BOOL complete;
	BOOL fail;
	int round;
	float enemySpeed;
	float playerSpeed;
	float timeremaining;
	float timeElapsed;
	BOOL timerIsActive;
	NSDate *timerStartTime;
	int score;
	int linesDrawn;
}

- (void)glDrawCircle:(GLfloat)r x:(GLfloat)x y:(GLfloat)y filled:(BOOL)filled;
- (void)glDrawRect:(CGRect)rect;
- (void)drawBoundary;
- (void)drawPlayer;
- (void)drawEnemy;
- (void)detectCollision;
- (void)completedMove;
- (void)updateText;
- (void)alertSuccess;
- (void)alertFail;
- (void)alertOutOfTime;
- (void)showPercent;

@end
