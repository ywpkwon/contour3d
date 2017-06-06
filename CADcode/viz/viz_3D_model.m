function h = viz_3D_model(mesh, camera, draw_points, draw_box, show_texture)

if ((nargin < 2) | (isempty(camera)))
    camera.viewpoint = [90, 0];
    if isfield(mesh, 'transform')
        camera.viewpoint = [36,6];
    end;
end;
if (nargin < 3)
    draw_points = 0;
end;
if (nargin < 4)
    draw_box = 1;
end;
if (nargin < 6)
    show_axes = 0;
end;

if (nargin < 5)
    show_texture = 0;
end;

if size(mesh.faces, 2) > 3
    sides = zeros(size(mesh.faces, 1), 3);
    for i = 1 : 3
        temp = mesh.vertices(mesh.faces(:, i + 1), :) - mesh.vertices(mesh.faces(:, 1), :);
        sides(:, i) = sqrt(sum(temp .* temp, 2));
    end;
    [u, v] = sort(sides, 2);
    v = v + 1;
    temp = [mesh.faces(:, 1), zeros(size(mesh.faces, 1), 3)];
    for i = 1 : 3
       u = v(:, i);
       x = sub2ind(size(mesh.faces), [1 : size(mesh.faces, 1)]', u);
       temp(:, i + 1) = mesh.faces(x);
    end;
    mesh.faces=  temp;
    mesh.faces = [mesh.faces(:, 1 : 3); mesh.faces(:, [2,3,4])];
end;
  
%tetramesh(T,vertices,'EdgeColor','none','FaceColor',[0,0.5,1],'FaceLighting','flat');
%trisurf(T,vertices(:,1),vertices(:,2),vertices(:,3),'EdgeColor','none','FaceColor','interp','FaceLighting','flat');
%trisurf(T,vertices(:,1),vertices(:,2),vertices(:,3),'EdgeColor','none','FaceColor',[0,0.5,1]);
if isfield(mesh, 'tdone') & mesh.tdone == 1
else
   mesh = transform_mesh2(mesh);
end;

if (draw_box == 2)
   alpha = 1;
else
    alpha = 0.4;
end;

if ((show_texture) & (isfield(mesh, 'colors')) & (size(mesh.colors, 1) == size(mesh.vertices, 1)))
   if isfield(mesh, 'm') & ~isfield(mesh, 'alpha')
       h = mplot(mesh.m);
   else
       if (0)
       mesh.faces=double(mesh.faces);
       mesh1 = refine_mesh(mesh);
       mesh.faces=mesh1.faces;
       mesh.vertices=mesh1.vertices;
       mesh.colors=mesh1.colors;
       end;
       alpha_mesh = 1;
       if isfield(mesh, 'alpha'), alpha_mesh = mesh.alpha; end;
       h = trisurf(mesh.faces,mesh.vertices(:,1),mesh.vertices(:,2),mesh.vertices(:,3),'EdgeColor','none','FaceLighting','flat','facevertexcdata',mesh.colors, 'FaceAlpha', alpha_mesh);%, 'AmbientStrength', 0.2, 'DiffuseStrength', 0.9, 'FaceAlpha', 0);%, 'vertexnormals', -mesh.normals);
   end;
elseif draw_box > 0
   h = trisurf(mesh.faces,mesh.vertices(:,1),mesh.vertices(:,2),mesh.vertices(:,3),'EdgeColor','none','FaceColor',[0,0.5,1],'FaceAlpha', alpha); 
else
   h = figure(); 
end;

if (draw_points)
    hold on;
    plot3(mesh.vertices(:, 1), mesh.vertices(:, 2), mesh.vertices(:, 3), '.', 'Color', [1,0.2,0])
end;
if (draw_box)
if ~isfield(mesh, 'bbox') 
    [cornerpoints, bbox] = fit_3D_bbox(mesh);
    mesh.bbox = bbox;
end;
hold on;
if ~isempty(mesh.bbox)
   plotminbox(mesh.bbox,'r', draw_box - 1)
end;
hold off
end;


%trisurf(T,vertices(:,1),vertices(:,2),vertices(:,3),'FaceColor',[1,0.1,0.2]);
%trisurf(T,vertices(:,1),vertices(:,2),vertices(:,3),'FaceColor',[1,0.4,0.2]);
%hold on
%plot3(vertices(:,1),vertices(:,2),vertices(:,3),'.','Color',[0,0.5,1])

view(camera.viewpoint(1),camera.viewpoint(2))
zoom(1.2)
if ~show_axes
   axis off;
else
   whitebg('w') 
   %axis on;
end;
axis equal;
axis vis3d;
material shiny;
material([0.2,0.9,0.1,0.5])
camlight('infinite')
%shading interp
%light('Position',[1 0 0],'Style','infinite');
%shading flat;
col = [0,0,0; 1,1,1];
set(gcf,'Color',col(2,:))
set(gcf,'Renderer','opengl','RendererMode','manual');
set(gcf,'DoubleBuffer','on');
k = 0;

for i = 1 : k
   view((i-1)*360/k,15)
   %camlight('headlight')
   %camlight(15,40)
   drawnow;
end;