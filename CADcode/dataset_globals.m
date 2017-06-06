DATA_PATH = '/home/phantom/projects/3dcar/CADcode/data'; %fullfile(pwd, '/data');

global CLASS_NAME;   % default is 'car', you can also put numbers and the corresponding class from list below will be taken
dataset_classes = {'car', 'bed'};

if numel(CLASS_NAME) == 0
   CLASS_NAME = dataset_classes{1};
end;
if isinteger(CLASS_NAME) | isfloat(CLASS_NAME)
    try
       CLASS_NAME = dataset_classes{CLASS_NAME};
    end;
end;

% links to CAD models dataset
CAD_MODELS_PATH = fullfile(DATA_PATH, CLASS_NAME);

