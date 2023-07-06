
import bpy
import os

bpy.context.scene.render.use_lock_interface = True


for obj in bpy.data.collections['blocking_4tiles_8neigh'].all_objects:
    obj.hide_render = True

i = 0
for obj in bpy.data.collections['blocking_4tiles_8neigh'].all_objects:
    obj.hide_render = False
    render_path = os.path.join(os.getcwd(), obj.name)
    print(render_path)
    bpy.context.scene.render.filepath = render_path
    #bpy.ops.render.render(write_still = True)
    obj.hide_render = True
    i += 1