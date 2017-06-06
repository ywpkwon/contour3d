Visualization and annotation code for CAD models

===== LICENSE =====

This code is copyright 2013 Sanja Fidler and is released for personal or academic use only.
The author of this software assumes no liability for its use and by downloading this software you agree to these terms.  

If you use the code or data please cite:

Sanja Fidler, Sven Dickinson, Raquel Urtasun
"3D Object Detection and Viewpoint Estimation with a Deformable 3D Cuboid Model." 
In NIPS 2012.


===== USAGE =====

- Set the paths in dataset_globals
- Run viz_3D_model_dir
- Use << and >> to browse the models
- Compute box will compute the 3D bounding box (it's already computed for the available data)
- Show texture=1 will show the textured CAD model
- Show box=1 shows the bounding box
- Show faces=1 shows the numbered faces of the box
- To annotate the orientation of the CAD models you can set 'front' and 'ground' edit boxes. The alignment
code will assume that the front face is always 1 and ground is always 2. So if this is not the case, please
put the face number of the front and ground in the corresponding edit boxes.
- class and instance edit boxes show you the class of the CAD object as well as a specific model (valid for cars)
- dims are real world dimensions (in mm): width, height, length. width is the width of the front face, height is the
height of the object and length is the width of the side face
- Save saves the model
- Delete model deletes the model
- Exit exists visualization

- Aligning the models in a directory can be done with: align_meshes_dir



