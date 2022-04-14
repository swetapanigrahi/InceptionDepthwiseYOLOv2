function lgraph = resnet18FeatureExtractor(net, imageInputSize)

% Convert to layerGraph.
lgraph = layerGraph(net);

lgraph = removeLayers(lgraph, {'res5b_relu' 'pool5' 'fc1000' 'prob' 'ClassificationLayer_predictions'});
inputLayer = imageInputLayer(imageInputSize,'Normalization','none','Name','data');
lgraph = replaceLayer(lgraph,'data',inputLayer);
end