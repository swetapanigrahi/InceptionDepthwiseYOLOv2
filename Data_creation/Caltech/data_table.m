
fanno = dir('D:\Caltech-USA\data-USA\annotations');
for i = 3:13
    fname = fanno(i).name;
    ffolder = fanno(i).folder;
    fpath = fullfile(ffolder,fname);
    df = dir(fpath);
    numv = sum([df(~ismember({df.name},{'.','..'})).isdir]);
    dt{i-2,:} = anno(fpath,numv);
end


% countp = (zeros(1,6));
% counti = zeros(1,6);
% for i = 1:6
%     d = dt{i,1};
%     for j = 1:size(d,2)
%         countp(1,i) = countp(1,i) + size(d(j).person,1);
%         
%     end
%     counti(1,i) = size(d,2);
% end


% d1 = struct2table(dt{1,:},'AsArray',true);
% d2 = struct2table(dt{2,:},'AsArray',true);
% d3 = struct2table(dt{3,:},'AsArray',true);
% d4 = struct2table(dt{4,:},'AsArray',true);
% d5 = struct2table(dt{5,:},'AsArray',true);
% d6 = struct2table(dt{6,:},'AsArray',true);
train_struct = [dt{1,:},dt{2,:},dt{3,:},dt{4,:},dt{5,:},dt{6,:}];

% data_train = vertcat(d1,d2,d3,d4,d5,d6);
data_train = struct2table(train_struct,'AsArray',true);

% d7 = struct2table(dt{7,:},'AsArray',true);
% d8 = struct2table(dt{8,:},'AsArray',true);
% d9 = struct2table(dt{9,:},'AsArray',true);
% d10 = struct2table(dt{10,:},'AsArray',true);
% d11 = struct2table(dt{11,:},'AsArray',true);
% data_test = vertcat(d7,d8,d9,d10,d11);

test_struct = [dt{7,:},dt{8,:},dt{9,:},dt{10,:},dt{11,:}];

% data_train = vertcat(d1,d2,d3,d4,d5,d6);
data_test = struct2table(test_struct,'AsArray',true);

%% 
trainingDataTbl = dtrain;
imdsTrain = imageDatastore(trainingDataTbl{:,'imageFilename'});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,'person'));
trainingData = combine(imdsTrain,bldsTrain);
validateInputData(trainingData)


testingDataTbl = data_test;
imdsTest = imageDatastore(testingDataTbl{:,'imageFilename'});
bldsTest = boxLabelDatastore(testingDataTbl(:,'person'));
testingData = combine(imdsTest,bldsTest);
validateInputData(testingData)