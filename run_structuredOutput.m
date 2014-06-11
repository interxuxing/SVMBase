%% This script is to run the proposed structured output learning algorithm
%   Here we have two types of W parameters:
%   1), Wc for each classifier learned from One-versus-All SVM
%   2), a single Wl learned using latent structured SVM for all classifers
%
%   we need to combine Wc and W for final prediction for each label.

%%
% 1st, load Wl
latent_outputfile = 'corel5k_model_lambda_0.25';
Wl = dlmread(latent_outputfile);
% Wl = ones(size(Wl));
% 2st, load Wc
load('l2NormC0.125b1.mat');

%% for prediction
load('corel5k_test_data.mat');

numOfTestImages = size(testAnnotations,1);
numOfLabels = size(testAnnotations,2);
ftrDim = size(testFeatures,2);

Wc = [b'; W];
scorePredictTestLabels = zeros(numOfTestImages, numOfLabels);
scorePredictTestLabels = scorePredictTestLabels';
for i = 1 : numOfTestImages
    x = [1, testFeatures(i,:)];
    % calcualte hadmard product
    hp = repmat(x,numOfLabels,1) .* Wc'; %TxftrDim
    % calculate product
    scorePredictTestLabels(:,i) = hp * Wl;
end

% for i = 1:numOfLabels
% 	for j = 1:numOfTestImages
% 		fj = scorePredictTestLabels(i,j);
% 		pj = 1/(1+exp(sigA(i)*fj+sigB(i)));
% 		scorePredictTestLabels(i,j) = pj;
% 	end;
% end;

results = evaluatePR(testAnnotations', scorePredictTestLabels, 5, 'tag');
fprintf('... For tag measure: \n\t P %f, R %f, N+ %d \n', results.prec, results.rec, results.retrieved);

results = evaluatePR(testAnnotations', scorePredictTestLabels, 5, 'image');
fprintf('... For image measure: \n\t P %f, R %f, N+ %d \n', results.prec, results.rec, results.retrieved);
