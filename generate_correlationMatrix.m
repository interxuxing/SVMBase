function generate_correlationMatrix(outFile, inAnnoMatrix)
%% this function is to genrate a correlation matrix for multiple labels
%   save the correlation matrix in 'outFile'
%
%   Input: ourFile,  a txt filename
%       inAnnoMatrix is a nInstance X nLabel matrix

% e.g. generate_correlationMatrix('corel5k_R.txt', double(yTr'));

annoMatrix = double(inAnnoMatrix);

fid = fopen(outFile, 'w');

[nInstance, nLabel] = size(annoMatrix);
correlationMatrix = zeros(nLabel, nLabel);


for i = 1 : nLabel
    idxInstance = find(annoMatrix(:, i) ~= 0); 
    for j = 1:length(idxInstance)
        idxLabel = find(annoMatrix(idxInstance(j), :) ~= 0);
        for k = 1:length(idxLabel)
            correlationMatrix(i, idxLabel(k)) = correlationMatrix(i, idxLabel(k)) + 1;
        end
    end
end

% then normalize the correlationMatrix
correlationMatrix = correlationMatrix ./ repmat(max(correlationMatrix,[],2),1,nLabel);

% write to file, format is similar as M3L
% start_flag = 1;
% for i = 1 : nLabel
%     for j = 1 : nLabel
%         if start_flag == 1
%             fprintf(fid, '%d,%d:%f', i-1,j-1,correlationMatrix(i,j));
%             start_flag = 0;
%         else
%             fprintf(fid, ' %d,%d:%f', i-1,j-1,correlationMatrix(i,j));
%         end
%     end
% end

% write to file, format is similar as Julian
for i = 1: nLabel
    for j = 1: nLabel
        if j == 1
            fprintf(fid, '%f', correlationMatrix(i,j));
        else
            fprintf(fid, ' %f', correlationMatrix(i,j));
        end
    end
    fprintf(fid, '\n');
end


fprintf(fid, '\n');
fclose(fid);

fprintf('...Finishe write to correlation file %s ...\n',outFile);

end




function X_out = normalizeL2(X_in)
    X_out = X_in ./ norm(X_in, 2);
end

function X_out = normalizeL1(X_in)
    X_out = X_in ./ norm(X_in, 1);
end