//
//  ESRenderView.m
//  OpenGL-ES2.0
//
//  Created by TuLigen on 16/9/21.
//  Copyright © 2016年 TuLigen. All rights reserved.
//

#import "ESRenderView.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
@interface ESRenderView()
{
    BOOL        _hasBeenCurrent;
    BOOL		_autoresize;
    float       _scale;
    GLuint      _depthFormat;
    GLuint      _stencilFormat;
    EAGLContext *_context;
    GLuint      _framebuffer;
    GLuint      _renderbuffer;
    GLuint      _depthbuffer;
    
    int         _enableMSAA;
    int         _enableFramebufferDiscard;
    GLuint      _msaaMaxSamples;
    GLuint      _msaaFrameBuffer;
    GLuint      _msaaColourBuffer;
    GLuint      _msaaDepthBuffer;
    GLuint      _stencilBuffer;
    CGSize      _size;
}
@end

GLuint           _positionSlot;
GLuint           _colorSlot;

@interface ESRenderView(Render)
{
    
}
@end


@implementation ESRenderView(Render)

//定义一些数据///////////////////////////////////////////////////
typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

const Vertex Vertices[] = {
    {{ 0.9, -0.9,  0}, {1, 0, 0, 1}},   //红
    {{ 0.5,  0.7,  0}, {0, 1, 0, 1}},   //绿
    {{-0.9,  0.9,  0}, {0, 0, 1, 1}},   //蓝
    {{-0.5, -0.7,  0}, {0, 0, 0, 1}}    //黑
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};

- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

//2.0的版本 需要设置 Shader
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
}


@end





@implementation ESRenderView
{
    NSTimer *timer;
}
+(Class) layerClass
{
    //重要点，将普通图层转到EAGL图层
    return [CAEAGLLayer class];
}

-(void) viewWillDisappear
{
    [timer invalidate];
    timer = nil;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        [self setup];
    }
    return self;
}

/**
 *  初始化
 */
-(BOOL) setup
{
    _depthFormat = 0;
    int iMSAA = 2;
    _enableMSAA = false;
    _msaaMaxSamples = iMSAA << 1;
    UIScreen *screen = [UIScreen mainScreen];
    _scale = [screen scale];
    
    CAEAGLLayer *eaglLayer = (CAEAGLLayer*)[self layer];
    NSDictionary *properties = @{kEAGLDrawablePropertyRetainedBacking:@NO,kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8};
    
    eaglLayer.drawableProperties = properties;
    
    _context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if( _context == nil ) return NO;
    
    if(! [self createSurface] )return NO;
    
    self.userInteractionEnabled = YES;
    
    [self setMultipleTouchEnabled:YES];
    
    [self compileShaders];
    
    [self render];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1/60.f
                                             target:self
                                           selector:@selector(render)
                                           userInfo:nil repeats:YES];
    
    return YES;
}

-(BOOL) createSurface
{
    CAEAGLLayer*			eaglLayer = (CAEAGLLayer*)[self layer];
    GLuint					oldRenderbuffer;
    GLuint					oldFramebuffer;
    
    if(![EAGLContext setCurrentContext:_context]) {
        return NO;
    }
    
    if([self respondsToSelector:@selector(contentScaleFactor)]) {
        self.contentScaleFactor = _scale;
    }
    else {
        self.bounds = CGRectMake(0,0, self.bounds.size.width * _scale, self.bounds.size.height * _scale);
        self.transform = CGAffineTransformScale(self.transform, 1 / _scale, 1 / _scale);
    }
    
    GLint width, height;
    
    
    glGetIntegerv(GL_RENDERBUFFER_BINDING, (GLint *) &oldRenderbuffer);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, (GLint *) &oldFramebuffer);
    
    glGenRenderbuffers(1, &_renderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    
    if(![_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer])
    {
        glDeleteRenderbuffers(1, &_renderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER_BINDING, oldRenderbuffer);
        return NO;
    }
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    glGenFramebuffers(1, &_framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _renderbuffer);
    if (_depthFormat)
    {
        glGenRenderbuffers(1, &_depthbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _depthbuffer);
        if(_stencilFormat)
        {
            glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8_OES, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthbuffer);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _depthbuffer);
        }
        else
        {
            glRenderbufferStorage(GL_RENDERBUFFER, _depthFormat, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthbuffer);
        }
    }
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    //MSAA
    const GLubyte *str = glGetString(GL_EXTENSIONS);
    
    _enableMSAA = (strstr((const char *)str, "GL_APPLE_framebuffer_multisample") != NULL);
    _enableFramebufferDiscard = (strstr((const char *)str, "GL_EXT_discard_framebuffer") != NULL);
    
    if (_msaaMaxSamples && _enableMSAA)
    {
        GLint maxSamplesAllowed,samplesToUse;
        glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed);
        samplesToUse = _msaaMaxSamples < maxSamplesAllowed ? _msaaMaxSamples : maxSamplesAllowed;
        
        if(samplesToUse) {
            glGenFramebuffers(1, &_msaaFrameBuffer);
            glBindFramebuffer(GL_FRAMEBUFFER, _msaaFrameBuffer);
            
            glGenRenderbuffers(1, &_msaaColourBuffer);
            glBindRenderbuffer(GL_RENDERBUFFER, _msaaColourBuffer);
            glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse, GL_RGBA8_OES, width, height);
            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _msaaColourBuffer);
            
            if (_depthFormat)
            {
                glGenRenderbuffers(1, &_msaaDepthBuffer);
                glBindRenderbuffer(GL_RENDERBUFFER, _msaaDepthBuffer);
                if(_stencilFormat)
                {
                    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse, GL_DEPTH24_STENCIL8_OES, width, height);
                    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
                    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
                }
                else
                {
                    glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse, _depthFormat, width, height);
                    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _msaaDepthBuffer);
                }
            }
            if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
                NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
                return NO;
            }
        }
    }
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }
    
    _size.width = width;
    _size.height = height;
    if(!_hasBeenCurrent) {
        glViewport(0, 0, width, height);
        glScissor(0, 0, width, height);
        _hasBeenCurrent = YES;
    }
    else {
        glBindFramebuffer(GL_FRAMEBUFFER, oldFramebuffer);
    }
    glBindRenderbuffer(GL_RENDERBUFFER, oldRenderbuffer);
    
    //    CHECK_GL_ERROR();
    
    //    [_delegate didResizeEAGLSurfaceForView:self];
    
    return YES;
}
- (void) destroySurface
{
    EAGLContext *oldContext = [EAGLContext currentContext];
    
    if (oldContext != _context)
        [EAGLContext setCurrentContext:_context];
    
    
    if(_depthFormat) {
        glDeleteRenderbuffers(1, &_depthbuffer);
        _depthbuffer = 0;
    }
    
    glDeleteRenderbuffers(1, &_renderbuffer);
    _renderbuffer = 0;
    
    glDeleteFramebuffers(1, &_framebuffer);
    
    _framebuffer = 0;
    if (oldContext != _context)
        [EAGLContext setCurrentContext:oldContext];
}
- (void) setCurrentContext
{
    if(![EAGLContext setCurrentContext:_context]) {
        printf("Failed to set current context %p in %s\n", _context, __FUNCTION__);
    }
}

- (BOOL) isCurrentContext
{
    return ([EAGLContext currentContext] == _context ? YES : NO);
}

- (void) clearCurrentContext
{
    if(![EAGLContext setCurrentContext:nil])
        printf("Failed to clear current context in %s\n", __FUNCTION__);
}
- (void) BeginRender
{
    if(_msaaMaxSamples && _enableMSAA)
    {
        glBindFramebuffer(GL_FRAMEBUFFER, _msaaFrameBuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, _msaaColourBuffer);
    }
    else
    {
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
    }
}

- (void) EndRender
{
    //[self swapBuffers];
    //MSAA
    if(_msaaMaxSamples && _enableMSAA)
    {
        glDisable(GL_SCISSOR_TEST);
        glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _msaaFrameBuffer);
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _framebuffer);
        glResolveMultisampleFramebufferAPPLE();
    }
    
    if(_enableFramebufferDiscard){
        GLenum attachments[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT };
        glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 3, attachments);
    }
    
    glBindRenderbuffer(GL_RENDERBUFFER, _renderbuffer);
    if(![_context presentRenderbuffer:GL_RENDERBUFFER])
        printf("Failed to swap renderbuffer in %s\n", __FUNCTION__);
}

-(void) render
{

    [self BeginRender];
    [self setupVBOs];
    CGRect rect = [self bounds];
    glViewport( 0,0,(GLsizei)rect.size.width,(GLsizei)rect.size.height );
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.0, 1.0, 1.0, 1.0);

    
    // 2. 设置绘图的顶点和点的颜色
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    static int  i = 0;
    if(i % 2 == 0)
    {
        // 3. 绘图
        glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
    }
    else
    {
        glDrawArrays(GL_LINES, 0, 4);
    }

    [self EndRender];
}
- (void) setAutoresizesEAGLSurface:(BOOL)autoresizesEAGLSurface;
{
    _autoresize = autoresizesEAGLSurface;
    
    if(_autoresize)
        
        [self layoutSubviews];
}
- (void) layoutSubviews
{
    CGRect bounds = [self bounds];
    
    if(_autoresize && ((roundf(bounds.size.width) != _size.width) || (roundf(bounds.size.height) != _size.height))) {
        [self destroySurface];
#if __DEBUG__
        REPORT_ERROR(@"Resizing surface from %fx%f to %fx%f", _size.width, _size.height, roundf(bounds.size.width), roundf(bounds.size.height));
#endif
        [self createSurface];
    }
}
@end