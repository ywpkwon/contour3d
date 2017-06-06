function plotminbox(bbox,col, draw_box, vertex_number)
% plotminbox: Plot box in 3d
% usage: plotminbox(cornerpoints, color)
%
% arguments: (input)
%  cornerpoints - all eight cornerpoints (8 x 3) of the box in 3d
%                 format like output of minboundbox:
%                 first 4 points define one side of box
%                 second 4 points opposing side in same direction of rotation
%
% color - (OPTIONAL) color string like in description of PLOT command
%
%        DEFAULT: 'b'
%
% Example usages see help text of minboundbox.
%
% See also: minboundbox
%
% Author: Johannes Korsawe
% E-mail: johannes.korsawe@volkswagen.de
% Release: 1.0
% Release date: 09/01/2008
% code edited by Sanja Fidler

if nargin == 1,col = 'b';end
if (nargin < 3)
    draw_box = 0;
end;
if nargin < 4
    vertex_number = 1;
end;

isboxformat = 1;
if isfield(bbox, 'vertices')
   cornerpoints = bbox.vertices;
else
    cornerpoints = bbox;
    isboxformat = 0;
end;
hx = cornerpoints(:,1);hy = cornerpoints(:,2);hz = cornerpoints(:,3);
lw = 1.5;

plot_edges(hx, hy, hz, lw,col)

if draw_box == 1
    if isboxformat
        for i = 1 : size(bbox.faces, 1)
            draw_transp_rect(cornerpoints(bbox.faces(i, :)', :), i, i)
        end;
    else
        draw_transp_rect(cornerpoints(1 : 3, :), 1, 4)
        draw_transp_rect(cornerpoints(5 : 7, :), 2, 5)
        draw_transp_rect(cornerpoints([1,2,6]', :), 3, 6)
        draw_transp_rect(cornerpoints([2,3,7]', :), 4, 3)
        draw_transp_rect(cornerpoints([3,4,8], :), 5, 1)
        draw_transp_rect(cornerpoints([1,4,8], :), 6, 2)
    end;
end;

if draw_box == 2
    hold on;
    e_colors = [0.2, 0.8, 0;  0, 0.8, 0.8;  0.8,0.8,0; 0.6,0,0.8; 0, 0.1, 0.8;  0.8, 0.8, 0.8; 0.8, 0., 0; 0,0.5,0];
    colors = [0.5, 1, 0;  0, 1, 1;  1,1,0; 0.8,0,1; 0, 0.2, 1;  1, 1., 1; 1, 0., 0; 0,0.7,0];
    sizes = [12*ones(4,1);8*ones(4,1)];
    for i = 1 : size(cornerpoints, 1)
        plot3(cornerpoints(i, 1), cornerpoints(i, 2), cornerpoints(i, 3), 's', 'MarkerEdgeColor', e_colors(i, :), 'MarkerFaceColor', colors(i, :),...
            'MarkerSize',sizes(i),'LineWidth',2);
    end;
end;
hold off;

if draw_box < 0
    if draw_box == -2
       plot_edges(hx, hy, hz, lw, [0,0.5,1])
       for i = 1 : size(bbox.faces, 1)
           draw_rect(cornerpoints(bbox.faces(i, :)', :))
       end;
    end;
    %plot3(cornerpoints(:,1),cornerpoints(:,2),cornerpoints(:,3),'.r')
    plot3(cornerpoints(vertex_number, 1),cornerpoints(vertex_number, 2),cornerpoints(vertex_number, 3),'.r')
    hold off
end;

function draw_transp_rect(cornerpoints, i_color, face_num, alpha)

if nargin < 4
   alpha = 0.6;
end;
beta = 0.5;
[x, y, z, na, nb] = get_plane(cornerpoints);
n = min(na, nb);
%[xs, ys, zs, na1, nb1] = get_plane([cornerpoints(2, :) + beta * (n / na) * (cornerpoints(1, :) - cornerpoints(2, :)); cornerpoints(2, :); ...
%                         cornerpoints(2, :) + beta * (n / nb) * (cornerpoints(3, :) - cornerpoints(2, :))]);

hold on;
col = [0, 1, 1; 1, 0., 0.3; 1,1,0; 0.3, 1, 0; 1,0,1; 0.3, 0, 1];
cdata = ones(size(x, 1), size(x, 2), 3);
for i = 1 : 3
    cdata(:, :, i) = col(i_color, i);
end;
surf(x, y, z, 'CData', cdata, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceAlpha', alpha, 'AmbientStrength', 1, 'FaceLighting', 'none', 'BackFaceLighting', 'lit');
%surf(xs, ys, zs, 'CData', cdata, 'FaceColor', 'flat', 'EdgeColor', 'none', 'AmbientStrength', 1, 'FaceLighting', 'flat', 'BackFaceLighting', 'lit');
if (alpha)
   pos = cornerpoints(2, :) + beta * (cornerpoints(1, :) + cornerpoints(3, :) - 2 * cornerpoints(2, :));
   text(pos(1,1), pos(1,2), pos(1,3), int2str(face_num), 'Color', [1,1,1], 'FontSize', 20, 'FontWeight', 'bold');
end;
%grid off;
hold off


function draw_rect(cornerpoints)

[x, y, z, na, nb] = get_plane(cornerpoints);
n = min(na, nb);
%[xs, ys, zs, na1, nb1] = get_plane([cornerpoints(2, :) + beta * (n / na) * (cornerpoints(1, :) - cornerpoints(2, :)); cornerpoints(2, :); ...
%                         cornerpoints(2, :) + beta * (n / nb) * (cornerpoints(3, :) - cornerpoints(2, :))]);

hold on;
col = [0, 0.5, 1];
cdata = ones(size(x, 1), size(x, 2), 3);
for i = 1 : 3
    cdata(:, :, i) = col(i);
end;
surf(x, y, z, 'CData', cdata, 'FaceColor', 'flat', 'EdgeColor', 'none', 'FaceLighting', 'none');


function [x, y, z, na, nb] = get_plane(cornerpoints)

a = cornerpoints(2, :) - cornerpoints(1, :); na = norm(a);
b = cornerpoints(3, :) - cornerpoints(2, :); nb = norm(b);

[x, y] = meshgrid(0 : na / 10 : na, 0 : nb / 10 : nb); z = zeros(size(x));
[dx, dy] = size(x);

x = x(:);
y = y(:);
z = z(:);
[d, p, transform] = procrustes(cornerpoints(1:3, :),[na,nb,0;0,nb,0;0,0,0]);

c = transform.c;
T = transform.T;
b = transform.b;

X = b*[x,y,z]*T + repmat(c(1,:), [dx * dy, 1]);

x = X(:, 1); y = X(:, 2); z = X(:, 3);
x = reshape(x, [dx, dy]);
y = reshape(y, [dx, dy]);
z = reshape(z, [dx, dy]);

function plot_edges(hx, hy, hz, lw,col)

if nargin < 5
    col = [1,0,0];
end;
x=[hx(1);hx(2)];y=[hy(1);hy(2)];z=[hz(1);hz(2)];plot_col(x,y,z,lw,col); hold on;
x=[hx(2);hx(3)];y=[hy(2);hy(3)];z=[hz(2);hz(3)];plot_col(x,y,z,lw,col); hold on;
x=[hx(3);hx(4)];y=[hy(3);hy(4)];z=[hz(3);hz(4)];plot_col(x,y,z,lw,col); hold on;
x=[hx(4);hx(1)];y=[hy(4);hy(1)];z=[hz(4);hz(1)];plot_col(x,y,z,lw,col); hold on;
x=[hx(5);hx(6)];y=[hy(5);hy(6)];z=[hz(5);hz(6)];plot_col(x,y,z,lw,col); hold on;
x=[hx(6);hx(7)];y=[hy(6);hy(7)];z=[hz(6);hz(7)];plot_col(x,y,z,lw,col); hold on;
x=[hx(7);hx(8)];y=[hy(7);hy(8)];z=[hz(7);hz(8)];plot_col(x,y,z,lw,col); hold on;
x=[hx(8);hx(5)];y=[hy(8);hy(5)];z=[hz(8);hz(5)];plot_col(x,y,z,lw,col); hold on;
x=[hx(1);hx(5)];y=[hy(1);hy(5)];z=[hz(1);hz(5)];plot_col(x,y,z,lw,col); hold on;
x=[hx(2);hx(6)];y=[hy(2);hy(6)];z=[hz(2);hz(6)];plot_col(x,y,z,lw,col); hold on;
x=[hx(3);hx(7)];y=[hy(3);hy(7)];z=[hz(3);hz(7)];plot_col(x,y,z,lw,col); hold on;
x=[hx(4);hx(8)];y=[hy(4);hy(8)];z=[hz(4);hz(8)];plot_col(x,y,z,lw,col); hold off;

function plot_col(x,y,z,lw,col)

if isfloat(col)
   plot3(x,y,z,'LineWidth', lw, 'Color',col);
else
   plot3(x,y,z,col,'LineWidth', lw); 
end;