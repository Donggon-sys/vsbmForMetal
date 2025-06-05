//
//  CSFragmentShader.metal
//  VSBM
//
//  Created by Chenruyi on 2025/5/26.
//

#include <metal_stdlib>
#define PI 3.14159265358979324
#define M_L 0.3819660113
#define M_R 0.6180339887
#define MAXR 8
#define SOLVER 8
using namespace metal;

typedef struct {
    float4 position[[position]];
    float3 color;
    float3 right, forward, up, origin;
    float3 dir, localdir;
}DateOut;



float kernal(float3 ver);

fragment float4 CSFragmentShader(DateOut In[[stage_in]],
                           constant float &len[[buffer(0)]]){
    float3 ver, n, reflect_n, color;
    int sign;
    float v, v1, v2;
    float r1, r2, r3, r4, m1, m2, m3;
    const float step = 0.002;
    
    color.r = 0.0;
    color.g = 0.0;
    color.b = 0.0;
    sign = 0;
    v1 = kernal(In.origin + In.dir*(step*len));
    v2 = kernal(In.origin);
    for(int k = 2;k < 1002;k++){
        ver = In.origin + In.dir * (step*len*float(k));
        v = kernal(ver);
        if (v > 0.0 && v1 < 0.0) {
            r1 = step * len*float(k - 1);
            r2 = step * len*float(k);
            m1 = kernal(In.origin + In.dir * r1);
            m2 = kernal(In.origin + In.dir * r2);
            for (int l = 0; l < SOLVER; l++) {
                r3 = r1 * 0.5 + r2 * 0.5;
                m3 = kernal(In.origin + In.dir * r3);
                if (m3 > 0.0) {
                    r2 = r3;
                    m2 = m3;
                }
                else {
                    r1 = r3;
                    m1 = m3;
                }
            }
            if (r3 < 2.0 * len) {
                  sign=1;
               break;
            }
         }
         if (v < v1&&v1>v2&&v1 < 0.0 && (v1*2.0 > v || v1 * 2.0 > v2)) {
            r1 = step * len*float(k - 2);
            r2 = step * len*(float(k) - 2.0 + 2.0*M_L);
            r3 = step * len*(float(k) - 2.0 + 2.0*M_R);
            r4 = step * len*float(k);
            m2 = kernal(In.origin + In.dir * r2);
            m3 = kernal(In.origin + In.dir * r3);
            for (int l = 0; l < MAXR; l++) {
               if (m2 > m3) {
                  r4 = r3;
                  r3 = r2;
                  r2 = r4 * M_L + r1 * M_R;
                  m3 = m2;
                  m2 = kernal(In.origin + In.dir * r2);
               }
               else {
                  r1 = r2;
                  r2 = r3;
                  r3 = r4 * M_R + r1 * M_L;
                  m2 = m3;
                  m3 = kernal(In.origin + In.dir * r3);
               }
            }
            if (m2 > 0.0) {
               r1 = step * len*float(k - 2);
               r2 = r2;
               m1 = kernal(In.origin + In.dir * r1);
               m2 = kernal(In.origin + In.dir * r2);
               for (int l = 0; l < SOLVER; l++) {
                  r3 = r1 * 0.5 + r2 * 0.5;
                  m3 = kernal(In.origin + In.dir * r3);
                  if (m3 > 0.0) {
                     r2 = r3;
                     m2 = m3;
                  }
                  else {
                     r1 = r3;
                     m1 = m3;
                  }
               }
               if (r3 < 2.0 * len&&r3> step*len) {
                      sign=1;
                  break;
               }
            }
            else if (m3 > 0.0) {
               r1 = step * len*float(k - 2);
               r2 = r3;
               m1 = kernal(In.origin + In.dir * r1);
               m2 = kernal(In.origin + In.dir * r2);
               for (int l = 0; l < SOLVER; l++) {
                  r3 = r1 * 0.5 + r2 * 0.5;
                  m3 = kernal(In.origin + In.dir * r3);
                  if (m3 > 0.0) {
                     r2 = r3;
                     m2 = m3;
                  }
                  else {
                     r1 = r3;
                     m1 = m3;
                  }
               }
               if (r3 < 2.0 * len&&r3> step*len) {
                      sign=1;
                  break;
               }
            }
         }
         v2 = v1;
         v1 = v;
      }
      if (sign==1) {
         ver = In.origin + In.dir*r3 ;
              r1=ver.x*ver.x+ver.y*ver.y+ver.z*ver.z;
         n.x = kernal(ver - In.right * (r3*0.00025)) - kernal(ver + In.right  * (r3*0.00025));
          n.y = kernal(ver - In.up * (r3*0.00025)) - kernal(ver + In.up * (r3*0.00025));
         n.z = kernal(ver + In.forward * (r3*0.00025)) - kernal(ver - In.forward * (r3*0.00025));
         r3 = n.x*n.x+n.y*n.y+n.z*n.z;
         n = n * (1.0 / sqrt(r3));
         ver = In.localdir;
         r3 = ver.x*ver.x+ver.y*ver.y+ver.z*ver.z;
         ver = ver * (1.0 / sqrt(r3));
         reflect_n = n * (-2.0*dot(ver, n)) + ver;
         r3 = reflect_n.x*0.276+reflect_n.y*0.920+reflect_n.z*0.276;
         r4 = n.x*0.276+n.y*0.920+n.z*0.276;
         r3 = max(0.0,r3);
         r3 = r3 * r3*r3*r3;
         r3 = r3 * 0.45 + r4 * 0.25 + 0.3;
             n.x = sin(r1*10.0)*0.5+0.5;
             n.y = sin(r1*10.0+2.05)*0.5+0.5;
             n.z = sin(r1*10.0-2.05)*0.5+0.5;
         color = n*r3;
      }
        
    return float4(color.r,color.g,color.b,1.0);
}

float kernal(float3 ver){
    float3 a;
    float b, c, d, e;
    a = ver;
    for(int i = 0;i < 5;i++){
        b = length(a);
        c = atan2(a.y, a.x)*8.0;
        e = 1.0 / b;
        d = acos(a.z / b)*8.0;
        b = pow(b, 8.0);
        a = float3(b*sin(d)*cos(c), b*sin(d)*sin(c), b*cos(d)) + ver;
        if(b > 6.0){
            break;
        }
    }
    return 4.0 - a.x*a.x - a.y*a.y - a.z*a.z;
}
