function mesh = get_3ds(m)

mesh.vertices = [];
mesh.faces = [];
mesh.colors = [];
mesh.spec = [];
pntr_v = 1;
components = struct('name', cell(length(m.layers), 1), 'vertid', cell(length(m.layers), 1), 'faceid', cell(length(m.layers), 1));

for i = 1 : length(m.layers)
    n = size(m.layers(i).vertices, 2);
    name = m.layers(i).name;
    components(i).name = name;
    if (n)
        nvert = size(mesh.vertices, 1);
        nfaces = size(mesh.faces, 1);
        mesh.vertices = [mesh.vertices; double(m.layers(i).vertices')];
        if (size(m.layers(i).facetidx, 1) > 3 & m.layers(i).facetidx(4, 1) > 0)
           mesh.faces = [mesh.faces; m.layers(i).facetidx' + pntr_v - 1];
        else
           mesh.faces = [mesh.faces; m.layers(i).facetidx(1:3,:)' + pntr_v - 1]; 
        end;
        components(i).vertid = [nvert + 1 : size(mesh.vertices, 1)]';
        components(i).faceid = [nfaces + 1 : size(mesh.faces, 1)]';
        mesh.colors = [mesh.colors; double(repmat(m.layers(i).diffuse, [n, 1]))];
        mesh.spec = [mesh.spec; double(repmat(m.layers(i).specular, [n, 1]))];
        pntr_v = size(mesh.vertices, 1) + 1;
    end;
    m.layers(i).vertices = double(m.layers(i).vertices);
end;

mesh.m = m;
mesh.components = components;