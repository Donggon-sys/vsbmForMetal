//
//  bright_Date.h
//  VSBM
//
//  Created by Chenruyi on 2025/6/2.
//

#ifndef bright_Date_h
#define bright_Date_h

#import <simd/simd.h>

typedef struct {
    simd_float3 right, forward, up, origin;
}Fragmentoptions;

typedef struct {
    simd_float3 right, forward, up, origin;
}Vertexoptions;

typedef struct {
    simd_float4 position;
}Date;

typedef struct {
    simd_float1 x;
    simd_float1 y;
}viewportSize;

enum VertexType{
    indexIn = 0,
    indexVertexOptions = 1,
    indexViewportSize = 2
};

enum FragmentType{
    indexLen = 0
};

#endif /* bright_Date_h */
