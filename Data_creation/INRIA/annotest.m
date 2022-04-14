function [fp,sp] = annotest(fname)
% fname = '/home/sweta/Downloads/INRIAPerson/Train/annotations/crop_000011.txt'
f1 = fopen(fname,'r');

% a = fread(f1,10)
% 
% disp(a)
% 
% tline = fgetl(f1);
% 
% while ischar(tline)
%     disp(tline)
%     tline = fgetl(f1);
% end

nol = linecount(f1);
k=1;
% pos = 
linenum = 0;
while(linenum <= nol)
  f1 = fopen(fname,'r');
if((linenum>=18) && (mod((linenum-18),7)==0))
    C = textscan(f1,'%s',1,'delimiter','\n', 'headerlines',linenum-1);
%     C{1,1}
    A = cell2mat(C{1,1});
    lastpart = textscan(A(69:end),'%s','delimiter','-');
    fcor = lastpart{1,1}{1,1}; 
    scor = lastpart{1,1}{2,1};
    fcorr = textscan(fcor(2:end-2),'%d','delimiter',',');
    fp(:,k) = cell2mat(fcorr);
    lcorr = textscan(scor(2:end-1),'%d','delimiter',',');
    sp(:,k) = cell2mat(lcorr);
%     if(mod(k))
    fseek(f1,0,'bof');
    k = k+1;
end
linenum = linenum+1;
fclose(f1);
end
% fclose(f1);

end


