/*
game ideas
reveal photo 
 
achievement ideas

75% exactly
80%+
85%+
90%+
95%+
win in 1
win in 10+ lines
cover exactly 50%

 */
#import <AVFoundation/AVFoundation.h>
#import "GLViewController.h"
#import "ConstantsAndMacros.h"
#import "OpenGLCommon.h"

@implementation GLViewController

typedef enum
{
	OUT_OF_TIME,
	SUCCESS,
	FAIL
}alertType;

const int BOUNDARY_MINX = 10;
const int BOUNDARY_MINY = 60;
const int BOUNDARY_MAXX = 310;
const int BOUNDARY_MAXY = 470;

const float BACK_RED = 0.2;
const float BACK_GREEN = 0.2;
const float BACK_BLUE = 0.2;
const float BACK_ALPHA = 1.0;
const float ENEMY_RED = 1.0;
const float ENEMY_GREEN = 0.208;
const float ENEMY_BLUE = 0.545;
const float ENEMY_ALPHA = 1.0;
const float PLAYER_RED = 0.004;
const float PLAYER_GREEN = 0.690;
const float PLAYER_BLUE = 0.941;
const float PLAYER_ALPHA = 1.0;
const float TEXT_RED = 0.682;
const float TEXT_GREEN = 0.933;
const float TEXT_BLUE = 0.0;
const float TEXT_ALPHA = 1.0;

const float TIME_LIMIT = 60.0;

int playerMinX;
int playerMinY;
int playerMaxX;
int playerMaxY;
int enemyMinX;
int enemyMinY;
int enemyMaxX;
int enemyMaxY;

- (id)initWithCoder:(NSCoder*)coder 
{
	infoRound = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 100, 25)];
	infoRound.font = [UIFont boldSystemFontOfSize:20];
	infoRound.textColor = [UIColor colorWithRed:TEXT_RED green:TEXT_GREEN blue:TEXT_BLUE alpha:TEXT_ALPHA];
	infoRound.backgroundColor = [UIColor clearColor];
	
	infoTime = [[UILabel alloc] initWithFrame:CGRectMake(110, 30, 80, 25)];
	infoTime.font = [UIFont boldSystemFontOfSize:30];
	infoTime.textColor = [UIColor colorWithRed:TEXT_RED green:TEXT_GREEN blue:TEXT_BLUE alpha:TEXT_ALPHA];
	infoTime.backgroundColor = [UIColor clearColor];
	infoTime.textAlignment = UITextAlignmentRight;
	
	infoPercent = [[UILabel alloc] initWithFrame:CGRectMake(230, 30, 80, 25)];
	infoPercent.font = [UIFont boldSystemFontOfSize:20];
	infoPercent.textColor = [UIColor colorWithRed:TEXT_RED green:TEXT_GREEN blue:TEXT_BLUE alpha:TEXT_ALPHA];
	infoPercent.backgroundColor = [UIColor clearColor];
	infoPercent.textAlignment = UITextAlignmentRight;
	
	percentExpander = [[UILabel alloc] initWithFrame:CGRectMake(150, 220, 20, 20)];
	percentExpander.font = [UIFont boldSystemFontOfSize:12];
	percentExpander.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
	percentExpander.backgroundColor = [UIColor clearColor];
	percentExpander.textAlignment = UITextAlignmentCenter;
	percentExpander.enabled = NO;
	
	timeElapsed = 0;
	score = 0;
	
	NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/main.m4a", [[NSBundle mainBundle] resourcePath]]];
	AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
	player.numberOfLoops = -1;
	[player play];
	
	return self;
}

- (void)drawView:(UIView *)theView
{	
	
	if (!moving && 
			 (
			  (timerIsActive && (timeElapsed - [timerStartTime timeIntervalSinceNow] > TIME_LIMIT)) ||
			  (!timerIsActive && timeElapsed > TIME_LIMIT)
			 )
		)
	{
		[self.view stopAnimation];
		[self alertOutOfTime];
	}
	else if (fail)
	{
		timerIsActive = NO;
		timeElapsed -= ([timerStartTime timeIntervalSinceNow] * 10) / 10;
		[self.view stopAnimation];
		[self alertFail];
	}
	else
	{
		glClearColor(BACK_RED, BACK_GREEN, BACK_BLUE, BACK_ALPHA);
		glClear(GL_COLOR_BUFFER_BIT);
		
		[self drawBoundary];
		[self drawPlayer];
		if (percentComplete >= 75)
		{
			[self drawBoundary];
			[self drawPlayer];
		}
		[self drawEnemy];
		[self updateText];
	}
	if (complete)
	{
		score += pow(percentComplete - 50.0,2) * round;
		[self updateText];
		timerIsActive = NO;
		timeElapsed -= ([timerStartTime timeIntervalSinceNow] * 10) / 10;
		[self.view stopAnimation];
		[self showPercent];
		//[self alertSuccess];
	}
}

- (void)showPercent
{
	percentExpander.enabled = YES;
	[percentComplete setText:[NSString stringWithFormat:@"%d", percentComplete]];
	[self.view startAnimation];
}

- (void)alertSuccess
{
	UIAlertView *completeAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Level %d", round] message:[NSString stringWithFormat:@"Well Done! Level Passed.\n%.2f%% Filled", percentComplete] delegate:self cancelButtonTitle:@"Next Level" otherButtonTitles:nil];
	completeAlert.tag = SUCCESS;
	[completeAlert show];
	[completeAlert release];
}

- (void)alertFail
{
	UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Level %d", round] message:@"That was not good enough!." delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
	failAlert.tag = FAIL;
	[failAlert show];
	[failAlert release];
}

- (void)alertOutOfTime
{
	NSString *message;
	int highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HIGHSCORE"];
	if (highScore < score)
	{
		[[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"HIGHSCORE"];
		message = [NSString stringWithFormat:@"Game Over.\nYou Scored %d Points.\n That's A New High Score!", score];
	}
	else
	{
		message = [NSString stringWithFormat:@"Game Over.\nYou Scored %d Points.\nYour High Score Is %d.", score, highScore];
	}
	UIAlertView *outOfTimeAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Level %d", round] message:message delegate:self cancelButtonTitle:@"Try Again" otherButtonTitles:nil];
	outOfTimeAlert.tag = OUT_OF_TIME;
	[outOfTimeAlert show];
	[outOfTimeAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	switch (alertView.tag)
	{
		case FAIL:
			round--;
			playerSpeed /= 1.1;
			enemySpeed /= 1.15;
			break;
		case OUT_OF_TIME:
			round = 0;
			score = 0;
			timerIsActive = NO;
			timeElapsed = 0;
			break;
	}

	[self.view startAnimation];
}


- (void)drawBoundary
{
	GLfloat square[8] = 
	{
		BOUNDARY_MINX, BOUNDARY_MINY,
		BOUNDARY_MAXX, BOUNDARY_MINY,
		BOUNDARY_MAXX, BOUNDARY_MAXY,
		BOUNDARY_MINX, BOUNDARY_MAXY,
	};
    
    glColor4f(PLAYER_RED, PLAYER_GREEN, PLAYER_BLUE, PLAYER_ALPHA);
    glVertexPointer(2, GL_FLOAT, 0, square);
    glDrawArrays(GL_LINE_LOOP, 0, 4);
	
	//float alpha = percentComplete/75.0;
	//NSLog(@"Alpha = %.2f", alpha);
	
	//glColor4f(PLAYER_RED, PLAYER_GREEN, PLAYER_BLUE, alpha);
	
	for (int i = 0; i < [aFilled count]; i++)
	{
		NSValue *rect = [aFilled objectAtIndex:i];
		[self glDrawRect:[rect CGRectValue]];
	}
	
	if (percentComplete >= 75)
		complete = YES;
}

- (void)drawPlayer
{	
	glColor4f(PLAYER_RED, PLAYER_GREEN, PLAYER_BLUE, PLAYER_ALPHA);
	
	if (!complete)
	{
		if (!moving)
		{
			if (playerY <= playerMinY)
			{	
				playerY = playerMinY;
				if (playerX >= playerMinX && playerX < playerMaxX)
				{
					playerX += 2 + (0.2 * round);
					playerSide = TOP_SIDE;
				}
				else
				{
					playerY += 2 + (0.2 * round);
					playerSide = RIGHT_SIDE;
				}
			}
			else if (playerY >= playerMaxY)
			{
				playerY = playerMaxY;
				if (playerX > playerMinX)
				{
					playerX -= 2 + (0.2 * round);
					playerSide = BOTTOM_SIDE;
				}	
				else
				{
					playerY -= 2 + (0.2 * round);
					playerSide = LEFT_SIDE;
				}
			}
			else if (playerX <= playerMinX)
			{
				playerX = playerMinX;
				playerY -= 2 + (0.2 * round);
				playerSide = LEFT_SIDE;
			}
			else
			{
				playerX = playerMaxX;
				playerY += 2 + (0.2 * round);
				playerSide = RIGHT_SIDE;
			}
		}
		else
		{
			CGRect rect;
			switch (playerMoving)
			{
				case UP:
					if (playerY > playerMinY)
						playerY -= 2 + (0.2 * round);
					else
					{
						if (enemyX > playerX)
						{
							rect = CGRectMake(BOUNDARY_MINX, BOUNDARY_MINY, playerX - BOUNDARY_MINX, BOUNDARY_MAXY - BOUNDARY_MINY);
							playerMinX = playerX;
							enemyMinX = playerX + 5;
						}
						else
						{
							rect = CGRectMake(playerX, BOUNDARY_MINY, BOUNDARY_MAXX - playerX, BOUNDARY_MAXY - BOUNDARY_MINY);
							playerMaxX = playerX;
							enemyMaxX = playerX - 5;
						}
						[self completedMove];
						[aFilled addObject:[NSValue valueWithCGRect:rect]];
					}
					break;
					
				case DOWN:
					if (playerY < playerMaxY)
						playerY += 2 + (0.2 * round);
					else
					{
						if (enemyX > playerX)
						{
							rect = CGRectMake(BOUNDARY_MINX, BOUNDARY_MINY, playerX - BOUNDARY_MINX, BOUNDARY_MAXY - BOUNDARY_MINY);
							playerMinX = playerX;
							enemyMinX = playerX + 5;
						}
						else
						{
							rect = CGRectMake(playerX, BOUNDARY_MINY, BOUNDARY_MAXX - playerX, BOUNDARY_MAXY - BOUNDARY_MINY);
							playerMaxX = playerX;
							enemyMaxX = playerX - 5;
						}
						[self completedMove];
						[aFilled addObject:[NSValue valueWithCGRect:rect]];
					}
					break;
					
				case LEFT:
					if (playerX > playerMinX)
						playerX -= 2 + (0.2 * round);
					else
					{
						if (enemyY > playerY)
						{
							rect = CGRectMake(BOUNDARY_MINX, BOUNDARY_MINY, BOUNDARY_MAXX - BOUNDARY_MINX, playerY - BOUNDARY_MINY);
							playerMinY = playerY;
							enemyMinY = playerY + 5;
						}
						else
						{
							rect = CGRectMake(BOUNDARY_MINX, playerY, BOUNDARY_MAXX - BOUNDARY_MINX, BOUNDARY_MAXY - playerY);
							playerMaxY = playerY;
							enemyMaxY = playerY - 5;
						}
						[self completedMove];
						[aFilled addObject:[NSValue valueWithCGRect:rect]];
					}
					break;
					
				case RIGHT:
					if (playerX < playerMaxX)
						playerX += 2 + (0.2 * round);
					else
					{
						if (enemyY > playerY)
						{
							rect = CGRectMake(BOUNDARY_MINX, BOUNDARY_MINY, BOUNDARY_MAXX - BOUNDARY_MINX, playerY - BOUNDARY_MINY);
							playerMinY = playerY;
							enemyMinY = playerY + 5;
						}
						else
						{
							rect = CGRectMake(BOUNDARY_MINX, playerY, BOUNDARY_MAXX - BOUNDARY_MINX, BOUNDARY_MAXY - playerY);
							playerMaxY = playerY;
							enemyMaxY = playerY - 5;
						}
						[self completedMove];
						[aFilled addObject:[NSValue valueWithCGRect:rect]];
					}
					break;
			}
		}
		
		if (moving)
		{
			GLfloat line[4] = 
			{
				startPosition.x, startPosition.y,
				playerX, playerY
			};
			glVertexPointer(2, GL_FLOAT, 0, line);
			glDrawArrays(GL_LINE_STRIP, 0, 2);
		}
	}
	
	//glColor4f(1.0, 1.0, 0.0, 1.0);
	[self glDrawCircle:4 x:playerX y:playerY filled:YES];
	
}

- (void)drawEnemy
{	
	glColor4f(ENEMY_RED, ENEMY_GREEN, ENEMY_BLUE, ENEMY_ALPHA);
	if (!complete)
	{
		if (enemyY >= enemyMaxY || (enemyMoving & UP && enemyY > enemyMinY))
		{
			enemyY -= 1 + (0.3 * round);
			enemyMoving &= ~DOWN;
			enemyMoving |= UP;
		}
		else
		{
			enemyY += 1 + (0.3 * round);
			enemyMoving &= ~UP;
			enemyMoving |= DOWN;
		}
		
		if (enemyX >= enemyMaxX || (enemyMoving & LEFT && enemyX > enemyMinX))
		{
			enemyX -= 1 + (0.3 * round);
			enemyMoving &= ~RIGHT;
			enemyMoving |= LEFT;
		}
		else
		{
			enemyX += 1 + (0.3 * round);
			enemyMoving &= ~LEFT;
			enemyMoving |= RIGHT;
		}
		[self detectCollision];
	}
	
	[self glDrawCircle:4 x:enemyX y:enemyY filled:YES];
}

- (void)detectCollision
{
	if (moving)
	{
		if (playerX - (1 + (0.3 * round)) < enemyX && enemyX < playerX + (1 + (0.3 * round)))
		{
			switch (playerMoving)
			{
				case UP:
					if (playerY <= enemyY)
						fail = YES;
					break;
				case DOWN:
					if (enemyY <= playerY)
						fail = YES;
					break;
				case LEFT:
				case RIGHT:
					if (playerY == enemyY)
						fail = YES;
					break;
			}
		}
		else if (playerY - (1 + (0.3 * round))  < enemyY && enemyY < playerY + (1 + (0.3 * round)) )
		{
			switch (playerMoving)
			{
				case UP:
				case DOWN:
					if (playerX == enemyX)
						fail = YES;
					break;
				case LEFT:
					if (playerX <= enemyX)
						fail = YES;
					break;
				case RIGHT:
					if (enemyX <= playerX)
						fail = YES;
					break;
			}
		}
		if (fail)
			NSLog(@"Collision!");
	}
}

- (void)completedMove
{
	playerMoving = NONE;
	moving = NO;
	
	score += round * 100;
	
	percentComplete = ((totalArea - ((playerMaxX - playerMinX) * (playerMaxY - playerMinY))) / totalArea) * 100;
	NSLog(@"complete: %.2f", percentComplete);
}

- (void)updateText
{
	float timeRemaining = MAX(0, TIME_LIMIT - timeElapsed);
	if (timerIsActive)
		timeRemaining = MAX(0, TIME_LIMIT - timeElapsed + (([timerStartTime timeIntervalSinceNow] * 10) / 10));
		
	[infoRound setText:[NSString stringWithFormat:@"Level %d", round]];
	if (timeRemaining < 10.05)
		infoTime.textColor = [UIColor colorWithRed:ENEMY_RED green:ENEMY_GREEN blue:ENEMY_BLUE alpha:ENEMY_ALPHA];
	[infoTime setText:[NSString stringWithFormat:@"%.1f", timeRemaining]];
	//[infoPercent setText:[NSString stringWithFormat:@"%.2f%%", percentComplete]];
	[infoPercent setText:[NSString stringWithFormat:@"%d", score]];
}

- (void)setupView:(GLView*)view
{
	glViewport(0, 0, 320, 480);
	glLoadIdentity();
	glOrthof(0, 320, 480, 0, -1, 1);  
	glDisable(GL_DEPTH_TEST);
	glMatrixMode(GL_MODELVIEW);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	[self.view addSubview:infoRound];
	[self.view addSubview:infoPercent];
	[self.view addSubview:infoTime];
	infoTime.textColor = [UIColor colorWithRed:TEXT_RED green:TEXT_GREEN blue:TEXT_BLUE alpha:TEXT_ALPHA];
	
	linesDrawn = 0;
	
	round++;
	
	playerMinX = BOUNDARY_MINX;
	playerMinY = BOUNDARY_MINY;
	playerMaxX = BOUNDARY_MAXX;
	playerMaxY = BOUNDARY_MAXY;
	enemyMinX = BOUNDARY_MINX + 5;
	enemyMinY = BOUNDARY_MINY + 5;
	enemyMaxX = BOUNDARY_MAXX - 5;
	enemyMaxY = BOUNDARY_MAXY - 5;
	
	if (round == 1)
	{
		playerSpeed = 2;
		enemySpeed = 1;
	}
	else
	{
		playerSpeed *= 1.08;
		enemySpeed *= 1.12;
	}
	
	fail = NO;
	complete = NO;
	moving = NO;
	
	int rnd = random() % 4;
	switch (rnd)
	{
		case 0:
			playerX = playerMinX;
			playerY = random() % (playerMaxY - playerMinY) + playerMinY;
			break;
		case 1:
			playerX = playerMaxX;
			playerY = random() % (playerMaxY - playerMinY) + playerMinY;
			break;
		case 2:
			playerY = playerMinY;
			playerX = random() % (playerMaxX - playerMinX) + playerMinX;
			break;
		case 3:
			playerY = playerMaxY;
			playerX = random() % (playerMaxX - playerMinX) + playerMinX;
			break;
	}		
	enemyX = random() % (enemyMaxX - enemyMinX) + enemyMinX;
	enemyY = random() % (enemyMaxY - enemyMinY) + enemyMinY;
	enemyMoving = (random() % 2 + 1) + (random() % 2 + 1) * 4;
	percentComplete = 0;
	totalArea = (BOUNDARY_MAXX - BOUNDARY_MINX) * (BOUNDARY_MAXY - BOUNDARY_MINX);
	aFilled = [[NSMutableArray alloc] init];
	
	int timeLimit;
	if (round < 5)
		timeLimit = 30;
	else if (round < 10)
		timeLimit = 25;
	else if (round < 15)
		timeLimit = 20;
	else if (round < 20)
		timeLimit = 15;
	else if (round < 30)
		timeLimit = 10;
	else
		timeLimit = 5;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (!timerIsActive)
	{
		timerIsActive = YES;
		timerStartTime = [[NSDate alloc] initWithTimeIntervalSinceNow:0]; 
	}
	
	UITouch *touch = [touches anyObject];
    // startTouchPosition is an instance variable
    //CGPoint touchPosition = [touch locationInView:self.view];
	if (!moving)
	{
		linesDrawn++;
		startPosition = CGPointMake(playerX, playerY);
		moving = YES;
		switch(playerSide)
		{
			case TOP_SIDE:
				playerMoving = DOWN;
				break;
				
			case LEFT_SIDE:
				playerMoving = RIGHT;
				break;
				
			case BOTTOM_SIDE:
				playerMoving = UP;
				break;
				
			case RIGHT_SIDE:
				playerMoving = LEFT;
				break;
		}
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touchesMoved");
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSLog(@"touchesEnded");
}

- (void)glDrawCircle:(GLfloat)r x:(GLfloat)x y:(GLfloat)y filled:(BOOL)filled
{ 
	int segments = 12;
	float theta = (2 * 3.14) / segments; 
	float tangetial_factor = tanf(theta);//calculate the tangential factor 
	float radial_factor = cosf(theta);//calculate the radial factor 
	float width = r;//we start at angle = 0 
	float height = 0; 
	int count = 0; 
	float* vertices = (float*)malloc(sizeof(float) * 2 * segments);
    
	for(int i = 0; i < segments; i++) 
	{ 
		vertices[count++] = x + width;
		vertices[count++] = y + height;
        
		//calculate the tangential vector 
		//remember, the radial vector is (x, y) 
		//to get the tangential vector we flip those coordinates and negate one of them 
		float tx = -height; 
		float ty = width; 
        
		//add the tangential vector 
		width += tx * tangetial_factor; 
		height += ty * tangetial_factor; 
        
		//correct using the radial factor 
		width *= radial_factor; 
		height *= radial_factor; 
	} 
	glVertexPointer (2, GL_FLOAT , 0, vertices); 
	glDrawArrays ((filled) ? GL_TRIANGLE_FAN : GL_LINE_LOOP, 0, segments);
}

- (void)glDrawRect:(CGRect)rect
{
	float vertices[8] = 
	{
		rect.origin.x, rect.origin.y,
		rect.origin.x, rect.origin.y + rect.size.height,
		rect.origin.x + rect.size.width, rect.origin.y,
		rect.origin.x + rect.size.width, rect.origin.y + rect.size.height
	};
	
	glVertexPointer (2, GL_FLOAT , 0, vertices); 
	glDrawArrays (GL_TRIANGLE_STRIP, 0, 4);
}

@end
