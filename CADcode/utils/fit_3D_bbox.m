function [cornerpoints, bbox] = fit_3D_bbox(mesh)

w = warning ('off','all');
try
mesh = remove_outliers2(mesh);
end;
try
mesh = unique_points(mesh);
end;
%sides = get_triangle_stat(mesh);
%mesh = remove_outliers(mesh, sides);
%mesh = reducepatch(mesh, 0.5);
mesh = reducepatch(mesh, 0.7);


x = mesh.vertices(:, 1);
y = mesh.vertices(:, 2);
z = mesh.vertices(:, 3);
[rotmat,cornerpoints,volume,surface,edgelength] = minboundbox(x,y,z,'v',1);
bbox = box_from_cornerpoints(cornerpoints);
bbox = number_box_faces(bbox, [1, 2]');
%plotminbox(cornerpoints,'b')
w = warning ('on','all');


function mesh = remove_outliers2(mesh)
% removes sides with areas less than 5 percentiles

if isfield(mesh, 'outliers')
    outliers = mesh.outliers;

    vertices = [1 : size(mesh.vertices, 1)]';
    vertices(outliers) = 0;
    [ind] = find(mesh.faces);
    mesh.faces(ind) = vertices(mesh.faces(ind));
    x = find(all(mesh.faces, 2));
    mesh.faces = mesh.faces(x, :);

    [x, y, vert] = find(mesh.faces);
    [ind] = find(mesh.faces);

    [v, m, n] = unique(vert);
    mesh.vertices = mesh.vertices(v, :);
    mesh.faces(ind) = n;
end;

function mesh = unique_points(mesh)

[u, m, v] = unique(mesh.vertices, 'rows');
[x, y, vert] = find(mesh.faces);
[ind] = find(mesh.faces);
mesh.vertices = u;
mesh.faces(ind) = v(vert);