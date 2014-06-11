function [FeaTr, FeaTe, AnnoTr, AnnoTe] = do_generate_multiple_feature_nuswide(config_file)
%%% Function that generate multiple feature for NUS-WIDE dataset:
% 1, entire original training set
% 2, subset tranining set
% 3, entire test set

eval(config_file);

featNames = {'BoW', 'CH', 'CM55', 'CORR', 'EDH', 'Gist', 'WT'};
annoNames = {'taglist81'};
dataFolder = [IMAGE_ANNOTATION_DIR,'\'];
tic;

%%% second parse annotation files
for anno = annoNames
    anno = char(anno);
	matchStr = regexp(ls_win(dataFolder), ['\w*_train', anno], 'match');
    
    load(strcat(dataFolder, matchStr{1}));
	AnnoTr = double(valid_train_81(valid_train_81_index, :));
    
    matchStr = regexp(ls_win(dataFolder), ['\w*_test', anno], 'match');
	load(strcat(dataFolder, matchStr{1}));
    AnnoTe = double(valid_test_81(valid_test_81_index, :));
end


%%% first parse feature files, note that we need to remove 
%%% the zero-label samples in both train/test list
FeaTr = [];
FeaTe = [];
for feat = featNames
    % 循环读取每个feature, 按名称匹配。
    feat = char(feat);
    fprintf('... for feature type %s ... \n', feat);
    if ispc
        matchStr = regexp(ls_win(dataFolder), ['\w*_train', feat], 'match');
    elseif isunix
        matchStr = regexp(ls(dataFolder), ['\w*_train', feat], 'match');
    end
    
    load(strcat(dataFolder, matchStr{1}));
	currFeaTr = normalizeL2(valid_feature_matrix(valid_train_81_index, :));
	FeaTr = [FeaTr, currFeaTr];

    if ispc
        matchStr = regexp(ls_win(dataFolder), ['\w*_test', feat], 'match');
    elseif isunix
        matchStr = regexp(ls_win(dataFolder), ['\w*_test', feat], 'match');
    end
    
    load(strcat(dataFolder, matchStr{1}));
	currFeaTe = normalizeL2(valid_feature_matrix(valid_test_81_index, :));
	FeaTe = [FeaTe, currFeaTe];
end


toc;
end


% function X_out = normalizeL2(X_in)
%     X_out = X_in ./ norm(X_in, 2);
% end

function X_out = normalizeL2(X_in)
    [numImg, numDim] = size(X_in);
    X_out = zeros(numImg, numDim);
    for j = 1 : numImg
        summ = sqrt(sum(X_in(j,:).^2));
        if (summ > 0)
            X_out(j,:) = X_in(j,:)/summ;
        end
    end
end

function X_out = normalizeL1(X_in)
    X_out = X_in ./ norm(X_in, 1);
end