//
//  CSVertexShader.metal
//  VSBM
//
//  Created by Chenruyi on 2025/5/26.
//

#include <metal_stdlib>
using namespace metal;

typedef struct {
    float4 position[[position]];
    float3 color;
    float3 right, forward, up, origin;
    float3 dir, localdir;
}DateOut;

typedef struct {
    float4 position;
}Date;

typedef struct {
    float3 right, forward, up, origin;
}options;

vertex DateOut CSVertexShader(uint vertexID [[vertex_id]],
                              constant Date* In[[buffer(0)]],
                              constant options& opt[[buffer(1)]],
                              constant float2& f[[buffer(2)]]){
    DateOut out;
    out.position = In[vertexID].position;
    out.dir = opt.forward + opt.right*In[vertexID].position.x*f.x + opt.up*In[vertexID].position.y*f.y;
    out.localdir.x = In[vertexID].position.x*f.x;
    out.localdir.y = In[vertexID].position.y*f.y;
    out.localdir.z = -1.0;
    out.right = opt.right;
    out.up = opt.up;
    out.origin = opt.origin;
    out.forward = opt.forward;
    return out;
}
