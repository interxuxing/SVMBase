function [FeaTr, FeaTe, AnnoTr, AnnoTe] = do_generate_multiple_feature(config_file)
%% Function that generate multiple feature for:
% 1, entire original training set
% 2, subset tranining set
% 3, entire test set

eval(config_file);
featNames = {'DenseSift.hvecs','DenseSiftV3H1.hvecs','DenseHue.hvecs','DenseHueV3H1.hvecs','Gist.fvec','HarrisSift.hvecs','HarrisSiftV3H1.hvecs',...
        'HarrisHue.hvecs','HarrisHueV3H1.hvecs','Hsv.hvecs32','HsvV3H1.hvecs32','Lab.hvecs32','LabV3H1.hvecs32','Rgb.hvecs32','RgbV3H1.hvecs32'};
annoNames = {'annot.hvecs'};
dataFolder = [IMAGE_ANNOTATION_DIR,'\'];
tic;

%% first parse feature files
FeaTr = [];
FeaTe = [];
for feat = featNames
    % 循环读取每个feature, 按名称匹配。
    % 在window下， 可以用以下方法来实现 A = dir(dataFolder); B = struct2cell(A); 
    % C =B(1,:); regexp(C, ...)
    feat = char(feat);
    fprintf('... for feature type %s ... \n', feat);
    if ispc
        matchStr = regexp(ls_win(dataFolder), ['\w*_train_', feat], 'match');
    elseif isunix
        matchStr = regexp(ls(dataFolder), ['\w*_train_', feat], 'match');
    end
    tmp = double(vec_read(strcat(dataFolder, matchStr{1})));
	currFeaTr = normalizeL2(tmp);
	FeaTr = [FeaTr, currFeaTr];

    if ispc
        matchStr = regexp(ls_win(dataFolder), ['\w*_test_', feat], 'match');
    elseif isunix
        matchStr = regexp(ls_win(dataFolder), ['\w*_test_', feat], 'match');
    end
	tmp = double(vec_read(strcat(dataFolder, matchStr{1})));
	currFeaTe = normalizeL2(tmp);
	FeaTe = [FeaTe, currFeaTe];
end

%% second parse annotation files
for anno = annoNames
    anno = char(anno);
	matchStr = regexp(ls_win(dataFolder), ['\w*_train_', anno], 'match');
    tmp = vec_read(strcat(dataFolder, matchStr{1}));
	AnnoTr = double(tmp);
    
    matchStr = regexp(ls_win(dataFolder), ['\w*_test_', anno], 'match');
	tmp = vec_read(strcat(dataFolder, matchStr{1}));
    AnnoTe = double(tmp);
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