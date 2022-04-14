% addpath D:\PASCAL_VOC\VOCdevkit\VOCcode
%Execute VOCinit 

imgset='test';
cls='person';
[ids,gt]=textread(sprintf(VOCopts.clsimgsetpath, ...
cls,imgset),'%s %d');

%% 
% 
% t=0;
% files_img = dir(fullfile('D:\PASCAL_VOC\VOCdevkit\VOC2012\Annotations', '*.xml'));
% for i = 1:size(files_img,1)
% rec=PASreadrecord(sprintf(VOCopts.annopath,files_img(i).name(1:end-4)));
%     c=0;
%     for j = 1:size(rec.objects,2)    
%         if(strcmp(rec.objects(j).class,'person')==1)
% %             if(rec.objects(j).difficult==0 && rec.objects(j).occluded==0 && rec.objects(j).truncated==0)
%                 c=c+1;
%        
% %             end
%         end
%     end
%     if(c>0)
%         t=t+1;
%         img_path = fullfile('D:\PASCAL_VOC\VOCdevkit\VOC2012\JPEGImages', strcat(files_img(i).name(1:end-4),'.jpg'));
% %        img_path = fullfile('D:\PASCAL_VOC\VOCtrainval_11-May-2012\VOCdevkit\VOC2012\JPEGImages', strcat(pimg{i},'.jpg'));
%         im = imread(img_path);
%         imwrite(im,strcat(strcat(files_img(i).name(1:end-4)),'.jpg'));
%         copyfile(sprintf(VOCopts.annopath,files_img(i).name(1:end-4)),'D:/YOLOv3P/pascal_test_anno/');
%     end
% end
% 



%% 


t=0;
files_img = dir(fullfile('D:\PASCAL_VOC\VOCdevkit\VOC2012\Annotations', '*.xml'));
for i = 1:size(files_img,1)
rec=PASreadrecord(sprintf(VOCopts.annopath,files_img(i).name(1:end-4)));
    c=0;
    for j = 1:size(rec.objects,2)    
        if(strcmp(rec.objects(j).class,'person')==1)
%             if(rec.objects(j).difficult==0 && rec.objects(j).occluded==0 && rec.objects(j).truncated==0)
                c=c+1;
                bnb = rec.objects(j).bbox;
                x = bnb(1);
                y = bnb(2);
                w = bnb(3)-bnb(1);
                h = bnb(4)-bnb(2);
                pos(c,:) = [x y w h];
%             end
        end
    end
    if(c>0)
        t=t+1;
        img_path = fullfile('D:\PASCAL_VOC\VOCdevkit\VOC2012\JPEGImages', strcat(files_img(i).name(1:end-4),'.jpg'));
        d(t).imageFilename = img_path;
        d(t).person = double(pos);
        clear pos;
    end
end
    

dtest = struct2table(d,'AsArray',true);
 

