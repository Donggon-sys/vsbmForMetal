//
//  GameViewController.h
//  VSBM
//
//  Created by Chenruyi on 2025/5/26.
//

#import <Cocoa/Cocoa.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <MetalKit/MetalKit.h>

// Our macOS view controller.
@interface GameViewController : NSViewController <MTKViewDelegate>

-(void)mouseDown:(NSEvent *)event;
-(void)rightMouseDown:(NSEvent *)event;
-(void)mouseUp:(NSEvent *)event;

@end
