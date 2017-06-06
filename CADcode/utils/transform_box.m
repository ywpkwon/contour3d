function transform = transform_box(cp, box, center_type, CLASS_NAME)

% INPUT
% cp ... point to put the box, default: [0,0,0]
% box.faces(1, :) ... front face
% box.faces(2, :) ... ground face
% center_type = 1 for center of mass of cube (default)
% center_type = 2 for center of the ground face

% OUTPUT
% new cordinates: 
% box.vertices = transform.sc*box.vertices*transform.R + repmat(transform.t, [size(box.vertices, 1), 1]);

if isempty(cp)
    cp = zeros(1,3);
end;

if nargin < 3
    center_type = 1;
end;

num = number_vertices(box);
vertices = box.vertices(num, :);

switch center_type
    case 1
       cb = vertices(1, :) + 0.5 * (vertices(7, :) - vertices(1, :)); 
    case 2
       i_ground = 2;
       cb = mean(box.vertices(box.faces(i_ground, :)', :), 1); 
    otherwise
       disp('Unknown center type!')
end;

a = vertices(2, :) - vertices(6, :); anorm = norm(a); a = a / norm(a);
b = vertices(2, :) - vertices(1, :); bnorm = norm(b); b = b / norm(b);
c = vertices(3, :) - vertices(2, :); cnorm = norm(c); c = c / norm(c);
switch CLASS_NAME
    case 'car'
        s = 1.8;  % the length of box will be set to s
        n1 = bnorm; 
    case 'bed'
        s = 1.9;
        n1 = anorm;
    case 'sofa'
        s = 1.3;
        n1 = cnorm;
    case 'cabinet'
        s = 0.6;
        n1 = anorm;
    case 'armchair'
        s = 1.3;
        n1 = cnorm;
    case 'table'
        s = 1.1;
        n1 = cnorm;
    otherwise
        s = 1;
        n1 = (anorm*bnorm*cnorm)^(1/3);
end;
n2 = s;
%n1 = (anorm*bnorm*cnorm)^(1/3); n2 = 100;
points = repmat(cb, [4, 1]) + n1 * [0, 0, 0; a; b; c];
points2 = repmat(cp, [4, 1]) + n2 * [0, 0, 0; [0, -1, 0]; [1, 0, 0]; [0, 0, 1]];

[d, p, transf] = procrustes(points2,points);

transform = struct('t', transf.c(1, :), 'R', transf.T, 'sc', transf.b);