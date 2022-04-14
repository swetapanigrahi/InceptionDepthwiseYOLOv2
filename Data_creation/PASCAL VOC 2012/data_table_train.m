% addpath D:\PASCAL_VOC\VOCtrainval_11-May-2012\VOCdevkit\VOCcode
%Execute VOCinit 

imgset='trainval';
cls='person';
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath, ...
cls,imgset),'%s %d');


%% 
count = 0;
for i = 1:size(gt,1)
     if(gt(i,:)==1) %if(gt(i,:)==0) %difficult
         count = count+1;
         pimg{count,:} = ids{i};
     end
end

%% 
% c=0;
% for i = 1:size(pimg,1)
%     rec=PASreadrecord(sprintf(VOCopts.annopath,pimg{i}));
%     for j = 1:size(rec.objects,2)    
%         if(strcmp(rec.objects(j).class,'person')==1)
%             if(rec.objects(j).difficult==0 && rec.objects(j).occluded==0)
%                 c=c+1;
%                 bnb(c,:) = rec.objects(j).bbox;
%                 img{c,:} = pimg{i};
%             end
%         end
%     end
% end
% 
% %% image copy for python program
% 
% 
% t = 0;
% for i = 1:size(pimg,1)
%     rec=PASreadrecord(sprintf(VOCopts.annopath,pimg{i}));
%     c=0;
%     for j = 1:size(rec.objects,2)    
%         if(strcmp(rec.objects(j).class,'person')==1)
% %             if(rec.objects(j).difficult==0 && rec.objects(j).occluded==0 && rec.objects(j).truncated==0)
%              if(rec.objects(j).difficult==0)
%                 c=c+1;
%              end
%         end
%     end
%       if(c>0)
%         t=t+1;
% %         img_path = fullfile('D:\PASCAL_VOC\VOCtrainval_11-May-2012\VOCdevkit\VOC2012\JPEGImages', strcat(pimg{i},'.jpg'));
% %         im = imread(img_path);
% %         imwrite(im,strcat(pimg{i},'.jpg'));
%         copyfile(sprintf(VOCopts.annopath,pimg{i}),'D:/YOLOv3P/pascal_train_anno/');
%      end
% end





%% 


t=0;
for i = 1:size(pimg,1)
    rec=PASreadrecord(sprintf(VOCopts.annopath,pimg{i}));
    c=0;
    for j = 1:size(rec.objects,2)    
        if(strcmp(rec.objects(j).class,'person')==1)
%             if(rec.objects(j).difficult==0 && rec.objects(j).occluded==0 && rec.objects(j).truncated==0)
             if(rec.objects(j).difficult==0)
                c=c+1;
                bnb = rec.objects(j).bbox;
                x = bnb(1);
                y = bnb(2);
                w = bnb(3)-bnb(1);
                h = bnb(4)-bnb(2);
                pos(c,:) = [x y w h];
            end
        end
    end
    if(c>0)
        t=t+1;
        img_path = fullfile('D:\PASCAL_VOC\VOCtrainval_11-May-2012\VOCdevkit\VOC2012\JPEGImages', strcat(pimg{i},'.jpg'));
        d(t).imageFilename = img_path;
        d(t).person = double(pos);
        clear pos;
    end
end


%% 

dtrainval = struct2table(d,'AsArray',true);

%% 



