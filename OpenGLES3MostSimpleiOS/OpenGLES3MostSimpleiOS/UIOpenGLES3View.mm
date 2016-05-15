//
//  UIOpenGLES3View.m
//  OpenGLES3
//
//  Created by KAJIWARA SUMIO on 2016/05/07.
//  Copyright © 2016年 KAJIWARA SUMIO. All rights reserved.
//

#import "UIOpenGLES3View.h"

#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>

#define CHECK_GL_ERROR() ({ GLenum __error = glGetError(); if(__error) printf("OpenGL error 0x%04X in %s %d\n", __error, __FUNCTION__, __LINE__); })

@interface UIOpenGLES3View () {
    EAGLContext *eaglContext_;
    
    GLuint defaultFramebuffer_;
    GLuint colorRenderbuffer_;
    GLuint depthBuffer_;
}
@end

@implementation UIOpenGLES3View

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void) initialize
{
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:YES], kEAGLDrawablePropertyRetainedBacking,
                                    kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    eaglContext_ = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    [EAGLContext setCurrentContext:eaglContext_];
    
    glGenFramebuffers(1, &defaultFramebuffer_);
    NSAssert( defaultFramebuffer_, @"Can't create default frame buffer");
    
    glGenRenderbuffers(1, &colorRenderbuffer_);
    NSAssert( colorRenderbuffer_, @"Can't create default render buffer");
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer_);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer_);
    
    [eaglContext_ renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer];
    
    NSAssert(glCheckFramebufferStatus( GL_FRAMEBUFFER ) == GL_FRAMEBUFFER_COMPLETE, @"invalid framebuffer");
        
    CHECK_GL_ERROR();
}

-(void) terminate
{
    if (defaultFramebuffer_) {
        glDeleteFramebuffers(1, &defaultFramebuffer_);
        defaultFramebuffer_ = 0;
    }
    
    if (colorRenderbuffer_) {
        glDeleteRenderbuffers(1, &colorRenderbuffer_);
        colorRenderbuffer_ = 0;
    }
    
    if ([EAGLContext currentContext] == eaglContext_)
        [EAGLContext setCurrentContext:nil];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    [self render];
}

-(void) render
{
    [EAGLContext setCurrentContext:eaglContext_];
    
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer_);
    
    glClearColor ( 1.0f, 1.0f, 1.0f, 0.0f );
    
    glClear(GL_COLOR_BUFFER_BIT);
    
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer_);
    if([eaglContext_ presentRenderbuffer:GL_RENDERBUFFER])
    {
        CHECK_GL_ERROR();
    }
}

@end
