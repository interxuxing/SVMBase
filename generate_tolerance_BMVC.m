function tolorrenceScores = generate_tolerance_BMVC(config_file)
%% function tolorrenceScores = generate_tolorrence_BMVC(feature_matrix, label_matrix)
%   is a high-level function that calculate the image-label specific
%   tolorrence score based on three factors:
%   1, reverse nearest neighbor based score
%   2, visual similarity based score
%   3, label co-occurrence based score
%
%   the calculation method refers in Verma, et.al BMVC2013
clc;
%% load the data of feature_matrix and label_matrix
[trainFeatures, testFeatures, trainAnnotations, testAnnotations] = do_generate_multiple_feature(config_file);

feature_matrix = trainFeatures;
label_matrix = trainAnnotations;

[N, L] = size(label_matrix);

if 0
% now generate label-specific positive / negative indexes
for l = 1 : L
    label_indexes{l}.pos = (label_matrix(:, l) == 1);
    label_indexes{l}.neg = (label_matrix(:, l) ~= 1);
end

% calculate pair-wise distance for all training samples and normalize
% all elemtents to range [0,1]
% for viusal distance, NxN
visual_dist = slmetric_pw(feature_matrix', feature_matrix', 'eucdist');
% now scale according to row
row_max = max(visual_dist,[],1);
visual_sim = 1 - visual_dist ./ repmat(row_max,N,1);

semantic_dist = slmetric_pw(label_matrix, label_matrix, 'nrmcorr');
row_max = max(semantic_dist,[],1);
semantic_sim = semantic_dist ./ repmat(row_max,L,1);

save('tolorrenceData.mat', 'label_indexes', 'visual_dist', 'visual_sim',...
    'semantic_dist', 'semantic_sim');

else
    load('tolorrenceData.mat');
end

% calculate reverseScores
reverseScores = score_reverse_NN(label_indexes, visual_sim);
% calculate visualScores
visualScores = score_visual_similarity(label_indexes, visual_sim);
% calculate semanticScores
semanticScores = score_semantic_similarity(label_indexes, semantic_sim, label_matrix);

% caluclate tolorrenceScores
tolorrenceScores = 1 - (reverseScores + visualScores + semanticScores)/3;
tolorrenceScores(label_matrix == 1) = 1;
save('tolorrenceData.mat', 'reverseScores', 'visualScores', 'semanticScores', 'tolorrenceScores', '-append');

end



%% calculate the reverse nearest neighbor based score
function reverseScores = score_reverse_NN(label_indexes, visual_sim)
[N, N] = size(visual_sim);
L = length(label_indexes);
reverseScores = ones(N, L);
sigma = 1e-2;
K = 5;

for l = 1 : L
    pos_index = find(label_indexes{l}.pos == 1);
    neg_index = find(label_indexes{l}.neg == 1);
    scores = zeros(length(neg_index), 1);
    for n = 1 : length(neg_index)
        % for each n in neg_index
        % find the largest visual similarity score in S+
        [value, idx] = sort(visual_sim(neg_index(n), :),2, 'descend');
        sum1 = 0;
        sum2 = 0;
        for k = 1 : K
            c = intersect(idx(1:k), pos_index);
            sum1 = sum1 + length(c)/k;
            sum2 = sum2 + length(c);
        end
        scores(n) = sum1 / (sum2 + sigma);      
    end    
    reverseScores(neg_index, l) = scores;
    
    if mod(l, 50) == 0
        fprintf('... reverse nearest neighbor based score for %d-th labels ...\n', l);
    end
end

end

%% calculate the visual similarity based score
function visualScores = score_visual_similarity(label_indexes, visual_sim)
[N, N] = size(visual_sim);
L = length(label_indexes);
visualScores = ones(N, L);

for l = 1 : L
%     pos_index = find(label_indexes{l}.pos == 1);
    neg_index = find(label_indexes{l}.neg == 1);
    scores = zeros(length(neg_index), 1);
    for n = 1 : length(neg_index)
        % for each n in neg_index
        % find the largest visual similarity score in S+
        scores(n) = max(visual_sim(neg_index(n), label_indexes{l}.pos),[],2);
    end    
    visualScores(neg_index, l) = scores;
    
    if mod(l, 50) == 0
        fprintf('... visual similarity based score for %d-th labels ...\n', l);
    end
end

end

%% calculate the label co-occurrence based score
function semanticScores = score_semantic_similarity(label_indexes, semantic_sim, label_matrix)
[N, L] = size(label_matrix);
semanticScores = ones(N, L);

for l = 1 : L
    pos_index = find(label_indexes{l}.pos == 1);
    neg_index = find(label_indexes{l}.neg == 1);
    scores = zeros(length(neg_index), 1);
    for n = 1 : length(neg_index)      
        % semantic similarity
        L_n = (label_matrix(neg_index(n),:) ~= 0);     
        vt_sem = max(semantic_sim(L_n, l));
        if isempty(vt_sem)
            vt_sem = 0;
        end
        scores(n) = vt_sem;
    end   
    semanticScores(neg_index,l) = scores;
    if mod(l, 50) == 0
        fprintf('... label co-occurrence based score for %d-th labels ...\n', l);
    end
end
end