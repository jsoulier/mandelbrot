#version 450

void main() 
{
    vec2 position = vec2((gl_VertexIndex << 1) & 2, gl_VertexIndex & 2);
    gl_Position = vec4(position * 2.0f - 1.0f, 0.0f, 1.0f);
}