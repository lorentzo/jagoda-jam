
import bpy
import os
import mathutils

bpy.context.scene.render.use_lock_interface = True

collection_names = [
    "rocks"
    ]

for collection_name in collection_names:

    # Make sure that all objects are visible to render.
    for obj in bpy.data.collections[collection_name].all_objects:
        obj.hide_render = False

    i = 0
    for obj in bpy.data.collections[collection_name].all_objects:
        # Store standard location of current object.
        standard_location = mathutils.Vector(obj.location)
        # Move current object to camera.
        obj.location = mathutils.Vector((0,0,standard_location[2]))
        # Create render path.
        render_path = os.path.join(os.getcwd(), collection_name + "_" + str(i))
        print(render_path)
        bpy.context.scene.render.filepath = render_path
        # Render.
        bpy.context.scene.render.engine = 'CYCLES'
        bpy.ops.render.render(write_still = True)
        # Restore object location.
        obj.location = standard_location
        # Increase counter for naming.
        i = i + 1