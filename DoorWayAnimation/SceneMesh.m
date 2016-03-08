//
//  SceneMesh.m
//  StartAgain
//
//  Created by Huang Hongsen on 5/18/15.
//  Copyright (c) 2015 com.microstrategy. All rights reserved.
//

#import "SceneMesh.h"

@implementation SceneMesh

- (instancetype) initWithView:(UIView *)view columnCount:(NSInteger)columnCount rowCount:(NSInteger)rowCount splitTexturesOnEachGrid:(BOOL)splitTexture columnMajored:(BOOL)columnMajored
{
    self = [super init];
    if (self) {
        if (splitTexture) {
            [self generateVerticesAndIndicesForSplitTextureForView:view columnCount:columnCount rowCount:rowCount columnMajored:columnMajored];
        } else {
            [self generateVerticesAndIndicesForView:view columnCount:columnCount rowCount:rowCount];
        }
        _verticesData = [NSData dataWithBytes:vertices length:self.verticesSize];
        _indicesData = [NSData dataWithBytes:indices length:self.indicesSize];
    }
    return self;
}

- (instancetype) initWithVerticesData:(NSData *)verticesData indicesData:(NSData *)indicesData
{
    self = [super init];
    if (self) {
        self.verticesData = verticesData;
        self.indicesData = indicesData;
    }
    return self;
}

- (void) prepareToDraw
{
    if (vertexBuffer == 0 && [self.verticesData length] > 0) {
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, [self.verticesData length], [self.verticesData bytes], GL_STATIC_DRAW);
    }
    if (indexBuffer == 0 && [self.indicesData length] > 0) {
        glGenBuffers(1, &indexBuffer);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, [self.indicesData length], [self.indicesData bytes], GL_STATIC_DRAW);
    }
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, sizeof(SceneMeshVertex), NULL + offsetof(SceneMeshVertex, position));
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, sizeof(SceneMeshVertex), NULL + offsetof(SceneMeshVertex, normal));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(SceneMeshVertex), NULL + offsetof(SceneMeshVertex, texCoords));
    
    glEnableVertexAttribArray(3);
    glVertexAttribPointer(3, 3, GL_FLOAT, GL_FALSE, sizeof(SceneMeshVertex), NULL + offsetof(SceneMeshVertex, columnStartPosition));
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
}

- (void) drawIndicesWithMode:(GLenum)mode startIndex:(GLuint)index indicesCount:(size_t)indicesCount
{
    glDrawArrays(mode, index, (GLint)indicesCount);
}

- (void) makeDynamicAndUpdateWithVertices:(const SceneMeshVertex *)verticies numberOfVertices:(size_t)numberOfVertices
{
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(SceneMeshVertex) * numberOfVertices, verticies, GL_DYNAMIC_DRAW);
}

- (void) tearDown
{
    if (vertexBuffer != 0) {
        glDeleteBuffers(1, &vertexBuffer);
    }
    if (indexBuffer != 0) {
        glDeleteBuffers(1, &indexBuffer);
    }
}

- (void) drawEntireMesh
{
    glDrawElements(GL_TRIANGLES, (int)self.indexCount, GL_UNSIGNED_SHORT, NULL);
}

- (void) destroyGL
{
    [self tearDown];
}

#pragma mark - Generate vertices and indices
- (void) generateVerticesAndIndicesForSplitTextureForView:(UIView *)view columnCount:(NSInteger)columnCount rowCount:(NSInteger)rowCount columnMajored:(BOOL)columnMajor
{
    _vertexCount = columnCount * rowCount * 4;
    _indexCount = columnCount * rowCount * 6;
    _verticesSize = _vertexCount * sizeof(SceneMeshVertex);
    _indicesSize = _indexCount * sizeof(GLushort);
    
    vertices = malloc(_verticesSize);
    indices = malloc(_indicesSize);
    
    if (columnMajor) {
        [self generateColumnMajoredVerticesForSplitTextureForView:view columnCount:columnCount rowCount:rowCount];
    } else {
        [self generateRowMajoredVerticesForSplitTextureForView:view columnCount:columnCount rowCount:rowCount];
    }
    
    NSInteger index = 0;
    for (int x = 0; x < columnCount; x++) {
        for (int y = 0; y < rowCount; y++) {
            index = x * rowCount + y;
            indices[index * 6 + 0] = index * 4;
            indices[index * 6 + 1] = index * 4 + 1;
            indices[index * 6 + 2] = index * 4 + 2;
            indices[index * 6 + 3] = index * 4 + 2;
            indices[index * 6 + 4] = index * 4 + 1;
            indices[index * 6 + 5] = index * 4 + 3;
        }
    }
}

- (void) generateColumnMajoredVerticesForSplitTextureForView:(UIView *)view columnCount:(NSInteger)columnCount rowCount:(NSInteger)rowCount
{
    NSInteger index = 0;
    CGFloat ux = 1.f / columnCount;
    CGFloat uy = 1.f / rowCount;
    for (int x = 0; x < columnCount; x++) {
        CGFloat vx = ux * x;
        for (int y = 0; y < rowCount; y++) {
            CGFloat vy = uy * y;
            index = (x * rowCount + y) * 4;
            vertices[index + 0].position = GLKVector3Make(vx * view.bounds.size.width, vy * view.bounds.size.height, 0);
            vertices[index + 0].texCoords = GLKVector2Make(vx, 1 - vy);
            
            vertices[index + 1].position = GLKVector3Make((vx + ux) * view.bounds.size.width, vy * view.bounds.size.height, 0);
            vertices[index + 1].texCoords = GLKVector2Make(vx + ux, 1 - vy);
            
            vertices[index + 2].position = GLKVector3Make(vx * view.bounds.size.width, (vy + uy) * view.bounds.size.height, 0);
            vertices[index + 2].texCoords = GLKVector2Make(vx, 1 - (vy + uy));
            
            vertices[index + 3].position = GLKVector3Make((vx + ux) * view.bounds.size.width, (vy + uy) * view.bounds.size.height, 0);
            vertices[index + 3].texCoords = GLKVector2Make(vx + ux, 1 - (vy + uy));
            
            vertices[index + 0].columnStartPosition = vertices[index + 0].position;
            vertices[index + 1].columnStartPosition = vertices[index + 0].position;
            vertices[index + 2].columnStartPosition = vertices[index + 0].position;
            vertices[index + 3].columnStartPosition = vertices[index + 0].position;
        }
    }
    for (int i = 0; i < self.vertexCount; i++) {
        SceneMeshVertex vertex = vertices[i];
        NSLog(@"Vertex[%d].columnStartPosition = (%g, %g, %g)", i, vertex.columnStartPosition.x, vertex.columnStartPosition.y, vertex.columnStartPosition.z);
    }
}

- (void) generateRowMajoredVerticesForSplitTextureForView:(UIView *)view columnCount:(NSInteger)columnCount rowCount:(NSInteger)rowCount
{
    NSInteger index = 0;
    CGFloat ux = 1.f / columnCount;
    CGFloat uy = 1.f / rowCount;
    for (int y = 0; y < rowCount; y++) {
        CGFloat vy = uy * y;
        for (int x = 0; x < columnCount; x++) {
            CGFloat vx = ux * x;
            index = y * columnCount + x;
            vertices[index + 0].position = GLKVector3Make(vx * view.bounds.size.width, vy * view.bounds.size.height, 0);
            vertices[index + 0].texCoords = GLKVector2Make(vx, 1 - vy);
            
            vertices[index + 1].position = GLKVector3Make(vy * view.bounds.size.width, (vy + uy) * view.bounds.size.height, 0);
            vertices[index + 1].texCoords = GLKVector2Make(vx, 1 - (vy + uy));
            
            vertices[index + 2].position = GLKVector3Make((vx + ux) * view.bounds.size.width, vy * view.bounds.size.height, 0);
            vertices[index + 2].texCoords = GLKVector2Make(vx + ux, 1 - vy);
            
            vertices[index + 3].position = GLKVector3Make((vx + ux) * view.bounds.size.width, (vy + uy) * view.bounds.size.height, 0);
            vertices[index + 3].texCoords = GLKVector2Make(vx + ux, 1 - (vy + uy));
            
            vertices[index + 0].columnStartPosition = vertices[index + 0].position;
            vertices[index + 1].columnStartPosition = vertices[index + 0].position;
            vertices[index + 2].columnStartPosition = vertices[index + 0].position;
            vertices[index + 3].columnStartPosition = vertices[index + 0].position;
        }
    }
}

- (void) generateVerticesAndIndicesForView:(UIView *)view columnCount:(NSInteger)columnCount rowCount:(NSInteger)rowCount
{
    
}
@end
