shader_type canvas_item;

uniform vec4 color : source_color = vec4(1.);

#define PHASES 0. // 1.: constrained random phases at vertices. 0. : all phases = 0. 
#define hash(p)  fract(sin( (.1+p) *  78.233 ) * 43758.5453 - PHASES )

float line(vec2 p, vec2 a,vec2 b) { 
    p -= a;
	b -= a;
    float h = clamp(dot(p, b) / dot(b, b), 0., 1.);
    return length(p - b * h);
}

float S(float v, float r) {
	//if (v < 0.005) return 1.0;
	//else return 0.;
	return smoothstep(1.5 / r , 0., v);
	//return mix(1.2 / r, 0., v);
}

float L(vec2 P1, vec2 P2, float a1, float a2, float T, vec2 U) {
	float l  = length(P2-P1);
	float Ta =  l / ( floor(l/T) -PHASES*(fract(a1-a2+.5)-.5) );
	l = cos( 6.283*( length(U-P1)/Ta +PHASES*a1 ) );
	return clamp( .5 + .5*l/fwidth(l) , 0., 1. );
}

void fragment() {
	//vec2 R = (1.0 / SCREEN_PIXEL_SIZE).xy;
	vec2 R = vec2(501, 155);
	vec2 o = 2.0/R;
	//R = vec2(501., 155.);
    vec2 U = UV;
    vec2 P0 = vec2(o.x, o.y);
    vec2 P1 = vec2(o.x, 1.0-o.y);
    vec2 P2 = vec2(1.0-o.x, 1.0-o.y);
    vec2 P3 = vec2(1.0-o.x, o.y);
         
    float Ta;
    float l;
    float Ty = 30./R.y;
	float Tx = 30./R.x;
	float a0 = hash(0.);
	float a1 = hash(1.);
	float a2 = hash(2.);
	float a3 = hash(3.);
	float d01 = line(U,P0,P1);
	float d12 = line(U,P1,P2);
	float d23 = line(U,P2,P3);
	float d30 = line(U,P3,P0);
	float m = min( min(d01,d12), min(d23,d30) );

	if (m == d01) 
		COLOR = vec4(S(d01,R.x) * L(P0,P1,a0,a1,Ty,U));
	else if (m == d12) 
		COLOR = vec4(S(d12,R.y) * L(P1,P2,a1,a2,Tx,U));
	else if (m == d23) 
		COLOR = vec4(S(d23,R.x) * L(P2,P3,a2,a3,Ty,U));
	else 
		COLOR = vec4(S(d30,R.y) * L(P3,P0,a3,a0,Tx,U));    
		
	COLOR = vec4(color.rgb, COLOR.a * color.a);
}