function lgraph = darknetFeatureExtractor(net, imageInputSize)

% Convert to layerGraph.
lgraph = layerGraph(net);

lgraph = removeLayers(lgraph, {'avg1' 'conv53' 'softmax' 'output'});
inputLayer = imageInputLayer(imageInputSize,'Normalization','none','Name','data');
lgraph = replaceLayer(lgraph,'input',inputLayer);
end