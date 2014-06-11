% "trainAnnotations", "testAnnotations", "trainFeatures", "testFeatures" need 
% to be loaded.
clc;
clear all;
datasets = {'corel5k', 'iaprtc12', 'mirflickr','nuswide'};
eval('./config/globalconfig.m');

datasetName = datasets{dataset_index};
config_file = sprintf('config_file_%s.mat', datasetName);
eval(fullfile('./config', config_file));

modelDir = MODEL_DIR;
logfileDir = LOGFILE_DIR;
if ~exist(modelDir, 'dir')
    mkdir(modelDir);
    mkdir(fullfile(modelDir, datasetName));
end
if ~exist(logfileDir, 'dir')
    mkdir(logfileDir);
end

if 4 == dataset_index %%%% for nuswide
    [trainFeatures, testFeatures, trainAnnotations, testAnnotations] = do_generate_multiple_feature_nuswide(config_file);
else %%% for traditional datasets
    [trainFeatures, testFeatures, trainAnnotations, testAnnotations] = do_generate_multiple_feature(config_file);
end



%%%% Training with pegasos method
randSeed = 1;
randn('state',randSeed);
rand('state',randSeed);
vl_twister('state',randSeed);


numOfTrainImages = size(trainAnnotations,1);
numOfTestImages = size(testAnnotations,1);
numOfLabels = size(trainAnnotations,2);
ftrDim = size(trainFeatures,2);

% step = [-4:1:-0];
step = [-2];
C = 2.^step;

logfileName = sprintf('%s_log_svm.txt', datasetName);
fid = fopen(fullfile(logfileDir, logfileName), 'w');

for i = 1:length(C)
    CI = C(i);
    fprintf('Pegaso method for C: %f \n', CI);
    fprintf(fid, 'Pegaso method for C: %f \n', CI);
    %%%% Training
    lambda = 1/(CI*numOfTrainImages);
    W = zeros(ftrDim,numOfLabels);
    b = zeros(numOfLabels,1);
    sigA = zeros(numOfLabels,1);
    sigB = zeros(numOfLabels,1);
    biasMultiplier = 1;
    parfor ci = 1:numOfLabels
        Y = zeros(1,numOfTrainImages) - 1;
        target = zeros(1,numOfTrainImages);
        currPosImages = find(trainAnnotations(:,ci)==1);
        for j = 1:length(currPosImages)
            Y(currPosImages(j)) = 1;
            target(currPosImages(j)) = 1;
        end;
        tic;
        
        if mod(ci, 10) == 0           
%             fprintf(fid, '... Training classifier for %d-th label ...\n', ci);
            fprintf('... Training classifier for %d-th label ...\n', ci);
        end
       
        tempW = vl_pegasos(trainFeatures',int8(Y),lambda,'BiasMultiplier',biasMultiplier,'NumIterations',numOfTrainImages*100);
        W(:,ci) = tempW(1:ftrDim);
        b(ci) = tempW(ftrDim+1);
        prior1 = length(currPosImages);
        prior0 = numOfTrainImages-prior1;
        out = trainFeatures*W(:,ci) + b(ci);
        [sigA(ci),sigB(ci)] = sigmoidPlatt(out,target,prior1,prior0);
        toc;
    end;
    clear tempW;
    
    %%%% save model file
    modelFile = sprintf('corel5k_model_C%d.mat', i);
    save(fullfile(modelDir, modelFile), 'W', 'b', 'sigA', 'sigB');
    %%%% Testing

    scorePredictTestLabels = testFeatures*W;
    scorePredictTestLabels = scorePredictTestLabels';
    for i = 1:numOfLabels
        scorePredictTestLabels(i,:) = scorePredictTestLabels(i,:) + b(i);
    end;
    for i = 1:numOfLabels
        for j = 1:numOfTestImages
            fj = scorePredictTestLabels(i,j);
            pj = 1/(1+exp(sigA(i)*fj+sigB(i)));
            scorePredictTestLabels(i,j) = pj;
        end;
    end;

    
    %%%% evaluate with standard measure and save results
    resFile = sprintf('corel5k_res_C%d.mat', i);  
    resultsTag = evaluatePR(testAnnotations', scorePredictTestLabels, 5, 'tag');
    fprintf('... For tag measure: \n\t P %f, R %f, N+ %d \n', resultsTag.prec, resultsTag.rec, resultsTag.retrieved);
    fprintf(fid, '... For tag measure: \n\t P %f, R %f, N+ %d \n', resultsTag.prec, resultsTag.rec, resultsTag.retrieved);
    
    resultsImage = evaluatePR(testAnnotations', scorePredictTestLabels, 5, 'image');
    fprintf('... For image measure: \n\t P %f, R %f, N+ %d \n', resultsImage.prec, resultsImage.rec, resultsImage.retrieved);
    fprintf(fid, '... For image measure: \n\t P %f, R %f, N+ %d \n', resultsImage.prec, resultsImage.rec, resultsImage.retrieved);
    
%     save(fullfile(modelDir, resFile), 'resultsTag', 'resultsImage');
end

fclose(fid);

fprintf(' Finished the long journey of training :-) \n');
