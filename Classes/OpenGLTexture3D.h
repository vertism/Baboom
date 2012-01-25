
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

@interface OpenGLTexture3D : NSObject {
	GLuint		texture[1];  
	NSString	*filename;
}
@property (nonatomic, retain) NSString *filename;
- (id)initWithFilename:(NSString *)inFilename width:(GLuint)inWidth height:(GLuint)inHeight;
- (void)bind;
+ (void)useDefaultTexture;
@end
