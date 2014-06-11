%% This script is to generate the dataformat for M3L method
%   generate the feature file (multi-class type) and correlationMatrix file




[trainFeatures, testFeatures, trainAnnotations, testAnnotations] = do_generate_multiple_feature('config_file_corel5k');

file_correlationMatrix = 'corel5k_R.txt';
generate_correlationMatrix(file_correlationMatrix, trainAnnotations);
fprintf('... Finished genearating correlation Matrix file: %s \n', file_correlationMatrix);

file_train_multilabel = 'corel5k_train_multilabelM3L.feat';
file_test_multilabel = 'corel5k_test_multilabelM3L.feat';
libsvmwrite_multilabel(file_train_multilabel,trainAnnotations, sparse(trainFeatures));
libsvmwrite_multilabel(file_test_multilabel,testAnnotations, sparse(testFeatures));
fprintf('... Finished genearating multilabel format files for training and test sets! \n');
