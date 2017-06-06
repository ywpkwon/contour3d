function align_meshes_dir(dir_in, dir_out)
% performs ICP + generalized Procrustes analysis to align 3D CAD models in
% directory dir_in, and stores them to directory dir_out
% eg, dir_in ='C:\science\data\3D\cars\matlab';
% dir_out = dir_in;

if ((nargin < 1) || (isempty(dir_in)))
    dataset_globals;
    dir_in = CAD_MODELS_PATH;
end;

if nargin < 2
    dir_out = dir_in;
end;

files = dir(fullfile(dir_in, '*_mesh.mat'));
if isempty(files)
    return;
end;
if ~(exist(dir_out, 'dir'))
    mkdir(dir_out);
end;

step = 1; % align boxes
align_meshes_temp(dir_in, dir_out, files, step);

function align_meshes_temp(dir_in, dir_out, files, step)

dataset_globals;
batchsize = 4;
num = ceil(length(files) / batchsize);
cp = [0,0,0];
center_type = 2;
sel_file = 1;
filename = files(sel_file).name;
filename_out = get_file_out(filename, dir_out);
data = load(filename_out);
prototype = data.mesh;
if isfield(prototype, 'transform')
    prototype.vertices = transform_vertices(prototype.transform, prototype.vertices);
end;


for k = 1 : num
    pardata = struct('mesh', {}, 'mesh_viz', {}, 'filename_out', {}, 'transform', {}, 'model_file', {});
    % sequential reading from disk
    for j = 1 : batchsize
        i = (k - 1) * batchsize + j;
        if (i <= length(files))
            filename = files(i).name;
            filename_out = get_file_out(filename, dir_out);
            filename = fullfile(dir_in, filename);
            if ((i <= length(files)) & (exist(filename_out, 'file')))
                data = load(filename_out);
                pardata(j).mesh = data.mesh;
                if isfield(data, 'mesh_viz')
                   pardata(j).mesh_viz = data.mesh_viz;
                else
                   pardata(j).mesh_viz = [];  
                end;
                pardata(j).filename_out = filename_out;
                if isfield(data, 'transform')
                   pardata(j).transform = data.transform;
                else
                    pardata(j).transform = [];
                end;
                if isfield(data, 'model_file')
                    pardata(j).model_file = data.model_file;
                else
                    pardata(j).model_file = fullfile(dir_in, filename);
                end;
            end;
        end;
    end;
    
    % paralel
    parfor j = 1 : batchsize
        i = (k - 1) * batchsize + j;
        if (i <= length(files))
        try    
            filename = files(i).name;
            filename_out = get_file_out(filename, dir_out);
            filename = fullfile(dir_in, filename);
            fprintf('Aligning: %s (', filename)
            tic;
            [path,name,ext]=fileparts(filename);
            mesh = pardata(j).mesh;
            if ~isfield(mesh, 'm')
                p = findstr(name, '_mesh');
                name=name(1,1:p(1)-1);
                file1=fullfile(dir_out, '..', '3ds', [name '.3ds']);
                [mesh1] = read_3d_model(file1);

                if (~(mesh.vertices(1,:)==mesh1.vertices(1,:)) | ~(size(mesh.vertices, 1)==size(mesh1.vertices, 1)))
                    aa=1;
                end;
                mesh.m = mesh1.m;
            end;
            mesh_viz = pardata(j).mesh_viz;
            transform = pardata(j).transform;
            if ((~isfield(mesh, 'bbox')) | (isempty(mesh.bbox)))
               [cornerpoints, bbox] = fit_3D_bbox(mesh.vertices);
               mesh.bbox = bbox;
                %mesh.bbox = [];
            end;  
            switch step
                case 1  % align boxes
                   transform = transform_box(cp, mesh.bbox, center_type, CLASS_NAME);
                case 2  % align models to first model in directory
                   transform = mesh.transform;
                   mesh_temp = mesh;
                   mesh_temp.vertices = transform_vertices(transform, mesh.vertices);
                   new_transform = align_meshes(prototype, mesh_temp);
            end;
            %mesh.transform=[];
            mesh.transform{step} = transform;
            pardata(j).mesh = mesh;
            pardata(j).filename_out = filename_out;
            %pardata(j).transform=[];
            pardata(j).transform{step} = transform;
            e = toc;
            fprintf('%0.4f)\n',e);
        catch err,
            fprintf('not valid model file)\n');
        end;
        end;
    end;
    
    % sequential writing to disk
    for j = 1 : batchsize
        i = (k - 1) * batchsize + j;
        if ((i <= length(files)) & (j <= length(pardata)) & (~isempty(pardata(j).mesh)))
            mesh = pardata(j).mesh;
            mesh_viz = pardata(j).mesh_viz;
            filename_out = pardata(j).filename_out;
            transform = pardata(j).transform;
            model_file = pardata(j).model_file;
            save(filename_out, 'mesh', 'mesh_viz', 'transform', 'model_file')
        end;
    end;
end;


function files_new = get_files(files, dir_out)

files_new = struct('name', {});
pntr = 1;
fprintf('Checking files...\n')

for i = 1 : length(files)
    filename = files(i).name;
    [path, name, ext] = fileparts(filename);
    filename_out = fullfile(dir_out, [name '_mesh.mat']);
    if exist(filename_out, 'file')
        try
            load(filename_out, 'mesh', 'mesh_viz')
            if (1)%(~isfield(mesh, 'bbox')) | (isempty(mesh.bbox)) | (~isfield(mesh.bbox, 'vertices')))
                files_new(pntr).name = filename;
                pntr = pntr + 1;
            else
                fprintf('File %s already exists\n', filename)
            end;
        end;
    end;
end;            


function filename_out = get_file_out(filename, dir_out)

[path, name, ext] = fileparts(filename);
filename_out = fullfile(dir_out, [name '.mat']);


function vertices = transform_vertices(transform, vertices)

for i = 1 : length(transform)
   vertices = transform{i}.sc*vertices*transform{i}.R + repmat(transform{i}.t, [size(vertices, 1), 1]);
end;