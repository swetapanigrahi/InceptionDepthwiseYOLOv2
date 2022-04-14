% rng(0);

d = dtrainval3; %train data table
td = dtest;  %test data table

shuffledIndices = randperm(height(d));
idx = floor(0.9 * length(shuffledIndices) );

trainingIdx = 1:idx;
trainingDataTbl = d(shuffledIndices(trainingIdx),:);

validationIdx = idx+1 : idx + 1 + floor(0.1 * length(shuffledIndices) );
validationDataTbl = d(shuffledIndices(validationIdx),:);

testDataTbl=td;

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

inputSize = [256 256 3];

numClasses = 1;

trainingDataForEstimation = transform(trainingData,@(data)preprocessData(data,inputSize));
numAnchors = 4;
[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingDataForEstimation, numAnchors);
%% 

lgraph = networkArchitecture;
%% 
augmentedTrainingData = transform(trainingData,@augmentData);

preprocessedTrainingData = transform(augmentedTrainingData,@(data)preprocessData(data,inputSize));
preprocessedValidationData = transform(validationData,@(data)preprocessData(data,inputSize));
%% 

options = trainingOptions('adam',...
      'InitialLearnRate',0.0001,...
      'Verbose',true,...                      
      'MiniBatchSize',16,...
      'MaxEpochs',30,...
      'ValidationData',preprocessedValidationData);
  
  %% 
  
[detector,info] = trainYOLOv2ObjectDetector(preprocessedTrainingData,lgraph_D53,options);

preprocessedTestData = transform(testData,@(data)preprocessData(data,inputSize));

detectionResults = detect(detector, preprocessedTestData);

[ap,recall,precision] = evaluateDetectionPrecision(detectionResults, preprocessedTestData);

[am, fppi, missRate] = evaluateDetectionMissRate(detectionResults, preprocessedTestData);
  
figure, loglog(fppi, missRate);

figure,plot(recall,precision);


