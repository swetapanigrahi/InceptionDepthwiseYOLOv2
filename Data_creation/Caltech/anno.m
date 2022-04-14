function d = anno(foldpath,n) 
tc=0;
tot_img = 0;
for k=1:n
    if(k-1<10)
        files_anno = dir(fullfile(strcat(foldpath,'\V00',num2str(k-1)), '*.txt'));
    else
        files_anno = dir(fullfile(strcat(foldpath,'\V0',num2str(k-1)), '*.txt'));
    end   
        vc(k) = 0;
        for i = 1:size(files_anno,1)
            fname = files_anno(i).name;
            fpath = fullfile((files_anno(i).folder),fname);
%                  tc=tc+1;
                count = 0;
                fid = fopen(fpath,'r');
                while ~feof(fid)
                    tline = fgetl(fid);
                    label1 = textscan(tline(1:6),'%s','Delimiter', '\t');
                    label2 = textscan(tline(1:7),'%s','Delimiter', '\t');
                    label3 = textscan(tline(1:9),'%s','Delimiter', '\t');
                %     label{1,1}
                    if((strcmp(label1{1,1},'person')==1)) 
                        if((strcmp(label2{1,1},'person?')~=1))
                            if(strcmp(label3{1,1},'person-fa')~=1)
                                pos = textscan(tline(8:end),'%d');
                                pos = pos{1,1};
                                if((pos(1,1)+pos(3,1)<640) && (pos(2,1)+pos(4,1)<480))
                                if((pos(4,1)>50) && (pos(1,1)~=0) && (pos(1,1)~=-1) && (pos(3,1)>0))
                                           if(pos(5,1)==1)
                                               full = pos(3,1)*pos(4,1);
                                               vis = pos(8,1)*pos(9,1);
                                               occl = 1-(vis/full);
                                               if(occl<0.35)
                                                    count = count+1;
                                                    arr_pos(count,:) = [pos(6,1) pos(7,1) pos(8,1) pos(9,1)]; 
                                            
                                               end
                                            end
                                            if(pos(5,1)==0)
                                                    count = count+1;
                                                    arr_pos(count,:) = [pos(1,1) pos(2,1) pos(3,1) pos(4,1)]; 
                                                                                     
                                            end 
                                end
                                end
                             end
                            
                        end
                        if(strcmp(label3{1,1},'person-fa')==1)
                                 pos = textscan(tline(11:end),'%d');
                                pos = pos{1,1};
                                       if((pos(1,1)+pos(3,1)<640) && (pos(2,1)+pos(4,1)<480)) 
                                        if((pos(4,1)>50) && (pos(1,1)~=0) && (pos(1,1)~=-1) && (pos(3,1)>0))
                                            if(pos(5,1)==1)
                                               full = pos(3,1)*pos(4,1);
                                               vis = pos(8,1)*pos(9,1);
                                               occl = 1-(vis/full);
                                               if(occl<0.35)
                                                    count = count+1;
                                                    arr_pos(count,:) = [pos(6,1) pos(7,1) pos(8,1) pos(9,1)]; 
                                               end
                                            end
                                            if(pos(5,1)==0)
                                                    count = count+1;
                                                    arr_pos(count,:) = [pos(1,1) pos(2,1) pos(3,1) pos(4,1)]; 
                                                                                     
                                            end
                                        end
                                       end
                           
                        end
                    end
                    
                end
                 if(count>0)
                     if(k-1<10)
                        img_path = fullfile(strcat(foldpath(1:24),'images\',foldpath(end-4:end),'\V00',num2str(k-1)), strcat(fname(1:end-4),'.jpg'));
                     else
                        img_path = fullfile(strcat(foldpath(1:24),'images\',foldpath(end-4:end),'\V0',num2str(k-1)), strcat(fname(1:end-4),'.jpg'));
                     end   
                   tc=tc+1;
                   d(tc).imageFilename = img_path;
                   d(tc).person = double(arr_pos);
                   clear arr_pos;
                end
               vc(k) = vc(k)+count;
               fclose('all'); 
        end
        tot_img = tot_img+ size(files_anno,1);
end
% tot_img
% end
        
       
% 

% end
% %%
% count = zeros(1,6);
% for i = 1:size(d0,2)
%     count(1) = count(1) + size(d0(i).person,1);
% end
% 
% for i = 1:size(d1,2)
%     count(2) = count(2) + size(d1(i).person,1);
% end
% 
% for i = 1:size(d2,2)
%     count(3) = count(3) + size(d2(i).person,1);
% end
% 
% for i = 1:size(d3,2)
%     count(4) = count(4) + size(d3(i).person,1);
% end
% 
% for i = 1:size(d4,2)
%     count(5) = count(5) + size(d4(i).person,1);
% end
% 
% for i = 1:size(d5,2)
%     count(6) = count(6) + size(d5(i).person,1);
% end
% 
% sum(count(:))