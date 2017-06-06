load('mesh')

vertices = mesh.vertices';
vertices(2,:) = vertices(2,:)+200;

camera = [0 0 0];
d_from_camera = sqrt(sum((vertices - repmat(camera',1,size(vertices,2))).^2,1));

figure
patch('faces',mesh.faces,'vertices', vertices','facevertexcdata',d_from_camera', 'FaceColor','interp');
% hold on;
% scatter3(camera(1), camera(2), camera(3));
% 
% ax=gca;
% ax.CameraPosition = camera;
% ax.CameraUpVector = [0 1 0];
% ax.CameraTarget = [1; 0; 0];
xlabel('x'); ylabel('y')
% ax.CameraUpVector = [0 1 0];
camproj('perspective')
% set(gca, 'CameraViewAngle', 0)
campos([35 0 50]);
camtarget([35 10 50])
camup([0 0 1]);