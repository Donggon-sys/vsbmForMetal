//
//  GameViewController.m
//  VSBM
//
//  Created by Chenruyi on 2025/5/26.
//

#import "GameViewController.h"
#import <simd/simd.h>
#include "bright_Date.h"

@implementation GameViewController
{
    MTKView *_view;
    
    bool ml, mm, mr;
    CGFloat mx, my, mx1, mx2;
    float ang1, ang2;
    float len;
    float cx, cy;
    double cenx, ceny, cenz;
    id <MTLBuffer> _indexBuffer;
    id <MTLRenderPipelineState> RenderPSO;
    id <MTLCommandQueue> CommandQueue;
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
    2, 3, 0
};

- (void)viewDidLoad
{
    [super viewDidLoad];
    ang1 = 2.8;
    ang2 = 0.4;
    len = 1.6;

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
    
    NSTrackingAreaOptions options = NSTrackingMouseMoved | NSTrackingActiveAlways;
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect:self.view.bounds options:options owner:self userInfo:nil];
    [self.view addTrackingArea:trackingArea];

    _view.delegate = self;
    
}



-(void)rightMouseDragged:(NSEvent *)event{
    CGFloat deltaX = [event deltaX];
    CGFloat deltaY = [event deltaY];
    
    float l = len * 4.0 / (cx + cy);
//    cenx += l * (-([event locationInWindow].x - mx) * sin(ang1) - ([event locationInWindow].y - my) * sin(ang2) * cos(ang1));
//    ceny += l * (([event locationInWindow].y - my) * cos(ang2));
//    cenz += l * (([event locationInWindow].x - mx) * cos(ang1) - ([event locationInWindow].y - my) * sin(ang2) * sin(ang1));
    
    cenx += l * ((deltaX) * sin(ang1) - (deltaY) * sin(ang2) * cos(ang1));
    ceny += l * ((deltaY) * cos(ang2));
    cenz += l * ((deltaX) * cos(ang1) - (deltaY) * sin(ang2) * sin(ang1));
    
}

-(void)mouseDragged:(NSEvent *)event{
    CGFloat deltaX = [event deltaX];
    CGFloat deltaY = [event deltaY];
    
//    ang1 += ([event locationInWindow].x - mx) * 0.002;
//    ang2 += ([event locationInWindow].y - my) * 0.002;
    ang1 += (deltaX) * 0.002;
    ang2 += (deltaY) * 0.002;
}

-(void)scrollWheel:(NSEvent *)event{
//    NSLog(@"打印！");
    CGFloat deltaY = [event deltaY];
    if (deltaY > 0) {
        len = len * exp(0.001 * 20);
    }else{
        len = len * exp(-0.001 * 20);
    }
}

- (void)drawInMTKView:(nonnull MTKView *)view { 
    id <MTLCommandBuffer> commandBuffer = [CommandQueue commandBuffer];
    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
    
    ang1 = ang1 + 0.01;
    if (renderPassDescriptor != nil) {
        id<MTLRenderCommandEncoder> renderEncode  = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        
        [renderEncode setViewport:(MTLViewport){0.0, 0.0, cx, cy, 0.0, 1.0}];
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
    
    
    vertexOptions.origin.x = len * cos(ang1) * cos(ang2) + cenx;
    vertexOptions.origin.y = len * sin(ang2) + ceny;
    vertexOptions.origin.z = len * sin(ang1) * cos(ang2) + cenz;
    
    vertexOptions.right.x = sin(ang1);
    vertexOptions.right.y = 0.0f;
    vertexOptions.right.z = -cos(ang1);

    vertexOptions.up.x = -1 * sin(ang2) * cos(ang1);
    vertexOptions.up.y = cos(ang2);
    vertexOptions.up.z = -1 * sin(ang2) * sin(ang1);

    vertexOptions.forward.x = -1 * cos(ang1) * cos(ang2);
    vertexOptions.forward.y = -1 * sin(ang2);
    vertexOptions.forward.z = -1 * sin(ang1) * cos(ang2);

}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {
    if (size.width > size.height) {
        cx = size.height;
        cy = size.height;
    }else{
        cx = size.width;
        cy = size.width;
    }
}


@end
