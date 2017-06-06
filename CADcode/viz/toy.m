load('mesh')

camera = [0; 0; 10];
p=0;
t=0;
d=10;        % image plane

M = [cos(p) sin(p) 0
-sin(p)*sin(t) cos(p)*sin(t) -cos(t)
-sin(p)*cos(t) cos(p)*cos(t) sin(t)];

M = [0 0 1; 0 -1 0; 1 0 0];
M = [-1 0 0; 0 0 1; 0 1 0];


Rt = [M [0;0;0]; 0 0 0 1];

vertices = mesh.vertices';
vertices(2,:) = vertices(2,:)+200;

% vertices = vertices - repmat(camera, 1, size(vertices,2));
verticesh = [vertices-repmat(camera,1,size(vertices,2)); ones(1, size(vertices,2))];
camera_coord = Rt * verticesh;

projection = [1 0 0 0; 0 1 0 0; 0 0 1/d 0];

image_coord = projection * camera_coord;
image_coord = image_coord(1:2,:)./repmat(image_coord(3,:),2,1);

d_from_camera = sqrt(sum((vertices - repmat(camera,1,size(vertices,2))).^2,1));

figure; 

subplot(131);
scatter3(vertices(1,:), vertices(2,:), vertices(3,:), 2, d_from_camera); xlabel('x'); ylabel('y');
ylim([0, max(vertices(2,:))]);

subplot(132);
scatter3(camera_coord(1,:), camera_coord(2,:), camera_coord(3,:), 2, d_from_camera); xlabel('x'); ylabel('y');

subplot(133);
patch('faces',mesh.faces,'vertices',mesh.vertices,'facevertexcdata',d_from_camera', 'FaceColor','interp');


%%
figure
subplot(121);
scatter(image_coord(1,:), image_coord(2,:), 2, d_from_camera);

faces=mesh.faces;
face_dist = min(d_from_camera(faces),[], 2);
[~, face_sind] = sort(face_dist,'descend');

% newfaces = zeros(0,3);
% K = [];
% 
% xa = [];
% ya = [];
% for i=1:numel(face_sind)
%     face = faces(face_sind(i),:);
%     [xb, yb] = polybool('union', xa, ya, image_coord(1,face), image_coord(2,face));
%     if isequal(xb,xa) && isequal(yb,ya)
%         continue
%     else
%         xa = xb; ya = yb;
%         newfaces = [newfaces; face];
%     end
% end
subplot(122);
patch('faces',faces(face_sind,:),'vertices',image_coord','facevertexcdata',d_from_camera', 'FaceColor','interp');
hold on; plot(image_coord(1,K),image_coord(2,K),'r-')
%%
subplot(155);
x=HPR(camera_coord(1:3,:)', camera',1e-5);
scatter(image_coord(1,x), image_coord(2,x), 2, d_from_camera(x));


% 
% verticesh = [vertices, ones(size(vertices,1),1)]';
% E=[1 0 0 0; 0 1 0 0; 0 0 1 0];
% ih = E*verticesh;
% i = ih(1:2,:)./repmat(ih(3,:),2,1);