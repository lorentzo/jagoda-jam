
## Godot Tile Map Setup.

1. Add `Tile map` node.
2. In `Tile map` settings (https://docs.godotengine.org/en/stable/tutorials/2d/using_tilesets.html#):
2.1. Set `Tile size` to 256x128 px.
2.3. Set `Tile shape` to `isometric`. 
2.3. Add `Physics layer`.
2.4. Add `Occlusion layer` (Under `Rendering`).
2.5. Make sure to enable `y-sort` under both `tile map` setting and `tile map` node.
3. Draw tiles from `TileMap` settings.

## Blender to Godot Tile Texture Workflow

Isometric tiles in Blender are created using:
* https://gamefromscratch.com/creating-isometric-tiles-in-blender/
* https://www.youtube.com/watch?v=mIS0CPy3f8g&t=1s

1. Create default plane in Blender.
2. Set camera to isometric.
3. Set resolution to 128x64.
4. Set Camera position: X: 10, Y: -10, Z: ~8.98.
5. Set Camera rotation (in deg) around axis: X: 60, Y: 0, Z: 45.
6. Set Camera ortographic scale to frame the plane (~2.83).
7. Change resolution to 128x128. Use 200% or more for rendering.
8. Set background to transparent.

Plane serves as blocking element for flat area.

Cube serves as blocking element for volume area.