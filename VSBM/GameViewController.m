//
//  GameViewController.m
//  VSBM
//
//  Created by Chenruyi on 2025/5/26.
//

#import "GameViewController.h"
#import <simd/simd.h>
#include "bright_Date.h"

//var cx, cy;
//var glposition;
//var glright;
//var glforward;
//var glup;
//var glorigin;
//var glx;
//var gly;
//var gllen;
//var canvas;
//var gl;
//var date = new Date();
//var md = 0,mx,my;
//var t2,t1 = date.getTime();
//var mx = 0, my = 0, mx1 = 0, my1 = 0, lasttimen = 0;
//var ml = 0, mr = 0, mm = 0;
//var len = 1.6;
//var ang1 = 2.8;
//var ang2 = 0.4;
//var cenx = 0.0;
//var ceny = 0.0;
//var cenz = 0.0;

@implementation GameViewController
{
    MTKView *_view;
    
    int ml, mm, mr; //var ml = 0, mr = 0, mm = 0;
    CGFloat mx, my, mx1, mx2;//var mx = 0, my = 0
    float ang1, ang2;
    float len;
    float cx, cy;
    float cenx, ceny, cenz;
    id <MTLBuffer> _indexBuffer;
    id <MTLRenderPipelineState> RenderPSO;
    id <MTLCommandQueue> CommandQueue;
    Fragmentoptions fragmentOptions;
    Vertexoptions vertexOptions;
    viewportSize viewport;
}

Date input[] = {
    {{-1.0, -1.0, 0.0, 1.0}},
    {{ 1.0, -1.0, 0.0, 1.0}},
    {{ 1.0,  1.0, 0.0, 1.0}},
    {{-1.0,  1.0, 0.0, 1.0}}
};

uint16_t indexForTriangle[] = {
    0, 1, 2,
    1, 3, 2
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    ang1 = 2.8;
    ang2 = 0.4;
    len = 1.6;
    ml = 0; mm = 0; mr = 0;
    cx = 1024;cy = 1024;
    cenx = 0.0;ceny = 0.0;cenz = 0.0;

    _view = (MTKView *)self.view;

    _view.device = MTLCreateSystemDefaultDevice();

    if(!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
        self.view = [[NSView alloc] initWithFrame:self.view.frame];
        return;
    }
    CommandQueue = [_view.device newCommandQueue];
    MTLRenderPipelineDescriptor * PipelineDescriptor = [[MTLRenderPipelineDescriptor alloc]init];
    id <MTLLibrary> DefaultLibrary = [_view.device newDefaultLibrary];
    id <MTLFunction> vertexFunction = [DefaultLibrary newFunctionWithName:@"CSVertexShader" ];
    id <MTLFunction> fragmentFunction = [DefaultLibrary newFunctionWithName:@"CSFragmentShader" ];
    
    PipelineDescriptor.colorAttachments[0].pixelFormat = _view.colorPixelFormat;
    PipelineDescriptor.vertexFunction = vertexFunction;
    PipelineDescriptor.fragmentFunction = fragmentFunction;
    
    RenderPSO = [_view.device newRenderPipelineStateWithDescriptor:PipelineDescriptor error:nil];
    _indexBuffer = [_view.device newBufferWithBytes:indexForTriangle length:sizeof(indexForTriangle) options:MTLResourceStorageModeShared];
    
    _view.delegate = self;
    
}

- (void)mouseDown:(NSEvent *)event {
    ml = 1;
    mm = 0;
    
    //获取鼠标所在的(x,y)地址
    NSPoint mousePoint = [NSEvent mouseLocation];
    mx = mousePoint.x;
    my = mousePoint.y;
}

-(void)rightMouseDown:(NSEvent *)event{
    mr = 1;
    mm = 0;
    
    //获取鼠标所在的(x,y)地址
    NSPoint mousePoint = [NSEvent mouseLocation];
    mx = mousePoint.x;
    my = mousePoint.y;
}

-(void)mouseUp:(NSEvent *)event{
    ml = 0;
}

-(void)rightMouseUp:(NSEvent *)event{
    mr = 0;
}

-(void)mouseMoved:(NSEvent *)event{
    if (ml == 1) {
        ang1 += ([NSEvent mouseLocation].x - mx) * 0.002;
        ang2 += ([NSEvent mouseLocation].y - my) * 0.002;
        
        if ([NSEvent mouseLocation].x != mx | [NSEvent mouseLocation].y != my) {
            mm = 1;
        }
    }
    
    if (mr == 1) {
        float l = len * 4.0 / (cx + cy);
        cenx += l * (-([NSEvent mouseLocation].x - mx) * sin(ang1) - ([NSEvent mouseLocation].y - my) * sin(ang2) * cos(ang1));
        ceny += l * (([NSEvent mouseLocation].y - my) * cos(ang2));
        cenz += l * (([NSEvent mouseLocation].x - mx) * cos(ang1) - ([NSEvent mouseLocation].y - my) * sin(ang2) * sin(ang1));
        if ([NSEvent mouseLocation].x != mx | [NSEvent mouseLocation].y != my) {
            mm = 1;
        }
    }
}

-(void)scrollWheel:(NSEvent *)event{
    len *= exp(-0.001 * event.deltaY);
    NSLog(@"scrollwheel");
}

- (void)drawInMTKView:(nonnull MTKView *)view { 
    id <MTLCommandBuffer> commandBuffer = [CommandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    //设置
    ang1 = ang1 + 0.01;
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncode  = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        [renderEncode setViewport:(MTLViewport){0.0, 0.0, 1024.0, 1024.0, 0.0, 1.0}];
        [self completeVar];
        [renderEncode setVertexBytes:input length:sizeof(input) atIndex:indexIn];
        [renderEncode setVertexBytes:&vertexOptions length:sizeof(vertexOptions) atIndex:indexVertexOptions];
        [renderEncode setVertexBytes:&viewport length:sizeof(viewport) atIndex:indexViewportSize];
        [renderEncode setFragmentBytes:&len length:sizeof(len) atIndex:indexLen];
        
        [renderEncode setRenderPipelineState:RenderPSO];
        [renderEncode drawIndexedPrimitives:MTLPrimitiveTypeTriangle indexCount:sizeof(indexForTriangle) / sizeof(indexForTriangle[0]) indexType:MTLIndexTypeUInt16 indexBuffer:_indexBuffer indexBufferOffset:0 instanceCount:1];
        
        [renderEncode endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)completeVar{
    viewport.x = cx * 2.0 / (cx + cy);
    viewport.y = cy * 2.0 / (cx + cy);
    
    //len就不设置了
    fragmentOptions.origin.x = len * cos(ang1) * cos(ang2) + cenx;
    fragmentOptions.origin.y = len * sin(ang2) + ceny;
    fragmentOptions.origin.z = len * sin(ang1) * cos(ang2) + cenz;
    vertexOptions.origin = fragmentOptions.origin;
    
    fragmentOptions.right.x = sin(ang1);
    fragmentOptions.right.y = 0.0f;
    fragmentOptions.right.z = -cos(ang1);
    vertexOptions.right = fragmentOptions.right;
    
    fragmentOptions.up.x = -sin(ang2) * cos(ang1);
    fragmentOptions.up.y = cos(ang2);
    fragmentOptions.up.z = -sin(ang2) * sin(ang1);
    vertexOptions.up = fragmentOptions.up;
    
    fragmentOptions.forward.x = -cos(ang1) * cos(ang2);
    fragmentOptions.forward.y = sin(ang2);
    fragmentOptions.forward.z = -sin(ang1) * cos(ang2);
    vertexOptions.forward = fragmentOptions.forward;
    
//    vertexOptions. = fragmentOptions;
    
    
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    if (size.width > size.height) {
        viewport.x = size.height;
        viewport.y = size.height;
        cx = size.height;
        cy = size.height;
    }else{
        viewport.x = size.width;
        viewport.y = size.width;
        cx = size.width;
        cy = size.width;
    }
}


@end
