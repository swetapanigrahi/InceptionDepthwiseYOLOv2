% load dataset in d and td.
d2 = vertcat(d,td);
rng(0)
shuffledIndices = randperm(height(d2));
idx = floor(0.6 * height(d2));

trainingIdx = 1:idx;
trainingDataTbl = d2(shuffledIndices(trainingIdx),:);

validationIdx = idx+1 : idx + 1 + floor(0.1 * length(shuffledIndices) );
validationDataTbl = d2(shuffledIndices(validationIdx),:);

testIdx = validationIdx(end)+1 : length(shuffledIndices);
testDataTbl = d2(shuffledIndices(testIdx),:);

%% 

imdsTrain = imageDatastore(trainingDataTbl{:,'imageFilename'});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,'person'));

imdsValidation = imageDatastore(validationDataTbl{:,'imageFilename'});
bldsValidation = boxLabelDatastore(validationDataTbl(:,'person'));

imdsTest = imageDatastore(testDataTbl{:,'imageFilename'});
bldsTest = boxLabelDatastore(testDataTbl(:,'person'));

trainingData = combine(imdsTrain,bldsTrain);
validationData = combine(imdsValidation,bldsValidation);
testData = combine(imdsTest,bldsTest);


%% 

data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I,'Rectangle',bbox);
annotatedImage = imresize(annotatedImage,2);
figure
imshow(annotatedImage)
%% 

inputSize = [224 224 3];

preprocessedTrainingData = transform(trainingData, @(data)preprocessData(data,inputSize));
numAnchors = 3;
anchorBoxes = estimateAnchorBoxes(preprocessedTrainingData,numAnchors)


%% Set base network and feature layer

featureExtractionNetwork = resnet50;

featureLayer = 'activation_40_relu';

numClasses = width(d)-1;

lgraph = fasterRCNNLayers(inputSize,numClasses,anchorBoxes,featureExtractionNetwork,featureLayer);
%% 

augmentedTrainingData = transform(trainingData,@augmentData);

augmentedData = cell(4,1);
for k = 1:4
    data = read(augmentedTrainingData);
    augmentedData{k} = insertShape(data{1},'Rectangle',data{2});
    reset(augmentedTrainingData);
end
figure
montage(augmentedData,'BorderSize',10)

%% 
trainingData = transform(augmentedTrainingData,@(data)preprocessData(data,inputSize));
validationData = transform(validationData,@(data)preprocessData(data,inputSize));


%% Set training options

options = trainingOptions('sgdm',...
    'MaxEpochs',10,...
    'MiniBatchSize',8,...
    'InitialLearnRate',1e-3,...
    'ValidationData',validationData);


[detector, info] = trainFasterRCNNObjectDetector(preprocessedTrainingData,lgraph,options,'ExecutionEnvironment','cpu');

testData = transform(testData,@(data)preprocessData(data,inputSize));

detectionResults = detect(detector,testData,'MinibatchSize',4);

[am, fppi, missRate] = evaluateDetectionMissRate(detectionResults,testData);

figure
loglog(fppi, missRate);
title(sprintf('log Average Miss Rate = %.1f', am))
%% 

[ap,recall,precision] = evaluateDetectionPrecision(detectionResults,testData);

figure
plot(recall,precision);
title(sprintf('Average Precision = %.1f',ap))