trainingDataTbl = d;
testDataTbl=td;

imdsTrain = imageDatastore(trainingDataTbl{:,'imageFilename'});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,'person'));

imdsTest = imageDatastore(testDataTbl{:,'imageFilename'});
bldsTest = boxLabelDatastore(testDataTbl(:,'person'));

trainingData = combine(imdsTrain,bldsTrain);

testData = combine(imdsTest,bldsTest);


net = squeezenet;
lgraph = layerGraph(net);

imageInputSize = [300 300 3];

imgLayer = imageInputLayer(imageInputSize,"Name","input_1");

lgraph = replaceLayer(lgraph,"data",imgLayer);

featureExtractionLayer = ["fire5-concat", "fire9-concat"];

lgraph = removeLayers(lgraph, {'drop9' 'conv10' 'relu_conv10' 'pool10' 'prob' 'ClassificationLayer_predictions'});

trainingDataForEstimation = transform(trainingData, @(data)preprocessData(data, imageInputSize));
numAnchors = 6;
[anchorBoxes, meanIoU] = estimateAnchorBoxes(trainingDataForEstimation, numAnchors)

area = anchorBoxes(:, 1).*anchorBoxes(:, 2);
[~, idx] = sort(area, 'descend');
anchorBoxes = anchorBoxes(idx, :);

%% 
numClasses = 1;

anchorBoxes1 = anchorBoxes(1:3,:);
anchorBoxes2 = anchorBoxes(4:6,:);
anchorBox1 = anchorBoxLayer(anchorBoxes1,"Name","anchors1");
anchorBox2 = anchorBoxLayer(anchorBoxes2,"Name","anchors2");


lgraph = addLayers(lgraph,anchorBox1);
lgraph = connectLayers(lgraph,"fire5-concat","anchors1");

lgraph = addLayers(lgraph,anchorBox2);
lgraph = connectLayers(lgraph,"fire9-concat","anchors2");

numAnchors1 = size(anchorBoxes1,1);
numClassesPlusBackground = numClasses + 1;
numClsFilters1 = numAnchors1 * numClassesPlusBackground;
filterSize = 3;
conv1 = convolution2dLayer(filterSize,numClsFilters1,...
    "Name","convClassification1",...
    "Padding","same");

numAnchors2 = size(anchorBoxes2,1);
numClassesPlusBackground = numClasses + 1;
numClsFilters1 = numAnchors2 * numClassesPlusBackground;
filterSize = 3;
conv2 = convolution2dLayer(filterSize,numClsFilters1,...
    "Name","convClassification2",...
    "Padding","same");

lgraph = addLayers(lgraph,conv1);
lgraph = connectLayers(lgraph,"anchors1","convClassification1");

lgraph = addLayers(lgraph,conv2);
lgraph = connectLayers(lgraph,"anchors2","convClassification2");


numRegFilters1 = 4 * numAnchors1;
conv3 = convolution2dLayer(filterSize,numRegFilters1,...
    "Name","convRegression1",...
    "Padding","same");

numRegFilters2 = 4 * numAnchors2;
conv4 = convolution2dLayer(filterSize,numRegFilters2,...
    "Name","convRegression2",...
    "Padding","same");

lgraph = addLayers(lgraph,conv3);
lgraph = connectLayers(lgraph,"anchors1","convRegression1");

lgraph = addLayers(lgraph,conv4);
lgraph = connectLayers(lgraph,"anchors2","convRegression2");

numFeatureExtractionLayers = numel(featureExtractionLayer);
mergeClassification = ssdMergeLayer(numClassesPlusBackground,numFeatureExtractionLayers,...
    "Name","mergeClassification");

lgraph = addLayers(lgraph,mergeClassification);
lgraph = connectLayers(lgraph,"convClassification1","mergeClassification/in1");
lgraph = connectLayers(lgraph,"convClassification2","mergeClassification/in2");

numCoordinates = 4;
mergeRegression = ssdMergeLayer(numCoordinates,numFeatureExtractionLayers,...
    "Name","mergeRegression");

lgraph = addLayers(lgraph,mergeRegression);
lgraph = connectLayers(lgraph,"convRegression1","mergeRegression/in1");


lgraph = connectLayers(lgraph,"convRegression2","mergeRegression/in2");

clsLayers = [
    softmaxLayer("Name","softmax")
    focalLossLayer("Name","focalLoss")
    ];

lgraph = addLayers(lgraph,clsLayers);
lgraph = connectLayers(lgraph,"mergeClassification","softmax");

reg = rcnnBoxRegressionLayer("Name","boxRegression");

lgraph = addLayers(lgraph,reg);
lgraph = connectLayers(lgraph,"mergeRegression","boxRegression");


%% 
augmentedTrainingData = transform(trainingData,@augmentData);

preprocessedTrainingData = transform(augmentedTrainingData,@(data)preprocessData(data,imageInputSize));

options = trainingOptions('sgdm',...
    'MiniBatchSize', 16, ....
    'InitialLearnRate',1e-3, ...
     'MaxEpochs', 30);


[detector, info] = trainSSDObjectDetector(preprocessedTrainingData,lgraph,options);

%% 

preprocessedTestData = transform(testData,@(data)preprocessData(data,inputSize));


detectionResults = detect(detector, preprocessedTestData, 'Threshold', 0.4);

[am, fppi, missRate] = evaluateDetectionMissRate(detectionResults,preprocessedTestData);


figure
loglog(fppi, missRate);
title(sprintf('log Average Miss Rate = %.1f', am))


