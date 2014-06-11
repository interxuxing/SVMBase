function testpegSvm(datasetNum)

if( datasetNum==1 )

	datasetName = 'corel';
	C = 1/8;
	featureFileName = {'DenseSift.hvecs','DenseSiftV3H1.hvecs','DenseHue.hvecs','DenseHueV3H1.hvecs','Gist.fvec','HarrisSift.hvecs','HarrisSiftV3H1.hvecs',...
        'HarrisHue.hvecs','HarrisHueV3H1.hvecs','Hsv.hvecs32','HsvV3H1.hvecs32','Lab.hvecs32','LabV3H1.hvecs32','Rgb.hvecs32','RgbV3H1.hvecs32'};

elseif( datasetNum==2 )
	
	datasetName = 'esp';
	C = 1/8;
	featureFileName = {'DenseHue.hvecs','DenseHueV3H1.hvecs','DenseSift.hvecs','DenseSiftV3H1.hvecs','Gist.fvec','HarrisHue.hvecs','HarrisHueV3H1.hvecs',...
        'HarrisSift.hvecs','HarrisSiftV3H1.hvecs','Hsv.hvecs32','HsvV3H1.hvecs32','Lab.hvecs32','LabV3H1.hvecs32','Rgb.hvecs32','RgbV3H1.hvecs32'};

elseif( datasetNum==3 )
	
	datasetName = 'iapr';
	C = 1/16;
	featureFileName = {'DenseHue.hvecs','DenseHueV3H1.hvecs','DenseSift.hvecs','DenseSiftV3H1.hvecs','Gist.fvec','HarrisHue.hvecs','HarrisHueV3H1.hvecs',...
        'HarrisSift.hvecs','HarrisSiftV3H1.hvecs','Hsv.hvecs32','HsvV3H1.hvecs32','Lab.hvecs32','LabV3H1.hvecs32','Rgb.hvecs32','RgbV3H1.hvecs32'};

end;



disp(['Evaluating performance on ' datasetName]);


biasMultiplier = 1;


% set the appropriate path.
Dir = ['tagpropData/' datasetName '/'];
testAnnotations = double(load([Dir datasetName '_test_annot.hvecs.txt']));

numOfTestImages = size(testAnnotations,1);
numOfLabels = size(testAnnotations,2);

disp('Loading data.');
ftrDim = 37152;
testFeatures = zeros(numOfTestImages,ftrDim);
indx1 = 0;
indx2 = 0;
for i = 1:length(featureFileName)
	currFtr = load([Dir datasetName '_test_' featureFileName{i} '.mat']);
	currFtr = double(currFtr.ftrs);
	for j = 1:numOfTestImages
		summ = sqrt(sum(currFtr(j,:).^2));
		if( summ>0 )
			currFtr(j,:) = currFtr(j,:)/summ;
		end;
	end;
	indx1 = indx2 + 1;
	indx2 = indx1 + size(currFtr,2) - 1;
	testFeatures(:,indx1:indx2) = currFtr;
end;

modelFile = ['models/' datasetName '/l2NormC' num2str(C) 'b' num2str(biasMultiplier) '.mat'];
model = load(modelFile);
W = model.W;
b = model.b;
sigA = model.sigA;
sigB = model.sigB;


%%%% 


disp('Testing performance.');
probPredictTestLabels = testFeatures*W;
probPredictTestLabels = probPredictTestLabels';
for i = 1:numOfLabels
	probPredictTestLabels(i,:) = probPredictTestLabels(i,:) + b(i);
end;
for i = 1:numOfLabels
	for j = 1:numOfTestImages
		fj = probPredictTestLabels(i,j);
		pj = 1/(1+exp(sigA(i)*fj+sigB(i)));
		probPredictTestLabels(i,j) = pj;
	end;
end;

correct = zeros(numOfLabels,1);
predict = zeros(numOfLabels,1);
ground = zeros(numOfLabels,1);
for i = 1:numOfTestImages
        actualLabels = find(testAnnotations(i,:)==1);
	currProbs1 = probPredictTestLabels(:,i);
	assignedLabels = zeros(1,5);
	for j = 1:5
		[val,indx] = max(currProbs1);
		assignedLabels(j) = indx;
		currProbs1(indx) = -inf; 
	end;

	for j = 1:length(assignedLabels)
		predict(assignedLabels(j)) = predict(assignedLabels(j)) + 1;
	end;
	
	for j = 1:length(actualLabels)
		ground(actualLabels(j)) = ground(actualLabels(j)) + 1;
		for k = 1:length(assignedLabels)
			if( assignedLabels(k)==actualLabels(j) )
				correct(assignedLabels(k)) = correct(assignedLabels(k)) + 1;
			end;
		end;
	end;
end;
prec = zeros(numOfLabels,1);
rec = zeros(numOfLabels,1);
for i = 1:numOfLabels
	if( predict(i)>0 )
		prec(i) = correct(i)/predict(i);
	end;
	if( ground(i)>0 )
		rec(i) = correct(i)/ground(i);
	end;
end;
precision = mean(prec)*100;
recall = mean(rec)*100;
fScore = 2*precision*recall/(precision+recall);
N = length(find(rec>0));

disp([datasetName ' -- C = ' num2str(C) ', b = ' num2str(biasMultiplier) ' -- ' num2str(precision) ' -- ' num2str(recall) ' -- ' num2str(fScore) ' -- ' num2str(N)]);



