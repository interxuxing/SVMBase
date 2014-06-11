function write_Wb2txt(mat_classifiers, mat_dir, txt_filename, txt_dir)
%% function write_Wb2txt(mat_classifiers) is to write learnt OVA svm
%   classifiers to a txt file, which can be further parsed in Julian's
%   C++ code
%
%   The format of the txt file is as follows:
%   b1 w11 w12 w13 .... w1d   ---> for classifier 1, b1 is bias, w11-w1d
%   are weights
%   b2 w21 w22 ....


%% first set some variables
mat_dir = './model/corel5k';
mat_classifiers = 'l2NormC0.125b1.mat';
txt_file = 'l2NormC0.125b1.txt';
txt_dir = mat_dir;

fid = fopen(fullfile(txt_dir, txt_file), 'w');


%% then parse the mat file and write to txt file following the rules
load(fullfile(mat_dir, mat_classifiers));

weights = W;
bias = b;

[numFeatures, numClassifiers] = size(weights);

for i = 1 : numClassifiers
    % write b and W of each classifier in each line
    fprintf(fid, '%f', b(i));
    for j = 1 : numFeatures
        fprintf(fid, ' %f', weights(j, i));
    end
    fprintf(fid, '\n');
    
    if 0 == mod(i, 50)
        fprintf('...write %d-th classifiers to txt file!\n', i);
    end
end

fprintf('Finish writing to txt file!\n')
fclose(fid);