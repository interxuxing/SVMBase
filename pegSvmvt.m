% "trainAnnotations", "testAnnotations", "trainFeatures", "testFeatures" need 
% to be loaded.
% clc;
clear all;
if 1
[trainFeatures, testFeatures, trainAnnotations, testAnnotations] = do_generate_multiple_feature('config_file_corel5k');

load('tolorrenceData.mat');

randSeed = 1;
randn('state',randSeed);
rand('state',randSeed);
vl_twister('state',randSeed);


numOfTrainImages = size(trainAnnotations,1);
numOfTestImages = size(testAnnotations,1);
numOfLabels = size(trainAnnotations,2);
ftrDim = size(trainFeatures,2);


%%%% Training

C = 2^(-3);
lambda = 1/(C*numOfTrainImages);
W = zeros(ftrDim,numOfLabels);
b = zeros(numOfLabels,1);
sigA = zeros(numOfLabels,1);
sigB = zeros(numOfLabels,1);
biasMultiplier = 1;
for ci = 1:numOfLabels
	Y = zeros(1,numOfTrainImages) - 1;
	target = zeros(1,numOfTrainImages);
	currPosImages = find(trainAnnotations(:,ci)==1);
	for j = 1:length(currPosImages)
		Y(currPosImages(j)) = 1;
		target(currPosImages(j)) = 1;
	end;
    
    % allocate the tolorrence value to each feature
    vt = tolorrenceScores(:,ci);
    trainFeatures = trainFeatures .* repmat(vt,1,ftrDim);
    
    tic;
    fprintf('... Training classifier for %d-th label ...\n', ci);
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

end

% load('l2NormC0.125b1.mat');
% load('corel5k_test_data.mat');
% numOfTestImages = size(testAnnotations,1);
% numOfLabels = size(testAnnotations,2);
% ftrDim = size(testFeatures,2);

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



results = evaluatePR(testAnnotations', scorePredictTestLabels, 5, 'tag');
fprintf('... For tag measure: \n\t P %f, R %f, N+ %d \n', results.prec, results.rec, results.retrieved);

results = evaluatePR(testAnnotations', scorePredictTestLabels, 5, 'image');
fprintf('... For image measure: \n\t P %f, R %f, N+ %d \n', results.prec, results.rec, results.retrieved);


