function d = data_table(r)


% r=224.0
fid = fopen('/home/cse/Documents/Sweta_2/INRIAPerson/Train/annotations.lst','r');

nl = linecount(fid);


% i=7;
for i =1:nl

fid = fopen('/home/cse/Documents/Sweta_2/INRIAPerson/Train/annotations.lst','r');   
an = textscan(fid,'%s',1,'delimiter','\n', 'headerlines',i-1);
apath = fullfile('/home/cse/Documents/Sweta/INRIAPerson/',an{1,1});

pid = fopen('/home/cse/Documents/Sweta_2/INRIAPerson/Train/pos.lst','r');

pn = textscan(pid,'%s',1,'delimiter','\n', 'headerlines',i-1);
pname = pn{1,1}{1,1};
f_name = textscan(pname(11:end),'%s','delimiter','/');
ppath = fullfile('/home/cse/Documents/Sweta_2/INRIAPerson/Train/pos/',f_name{1,1});

img = imread(fullfile('/home/cse/Documents/Sweta_2/INRIAPerson/Train/pos/',f_name{1,1}{1,1}));
% [ih,iw]=size(img);
ih = size(img,1);
iw = size(img,2);

[x,y] = annotest(apath{1,1});

nobj = size(x,2);
for k = 1:nobj
    w(k) = y(1,k) - x(1,k); 
end
for k = 1:nobj
   h(k) = y(2,k) - x(2,k); 
end

% arr = [x(1,1),y(1,1),w(1),h(1);x(1,2),y(1,2),w(2),h(2)]

for l=1:nobj
    xn(l) = (double(r)/double(iw))*x(1,l);
    yn(l) = (double(r)/double(ih))*x(2,l);
    wn(l) = (double(r)/double(iw))*w(l);
    hn(l) = (double(r)/double((ih)))*h(l);
%     arr(l,:) = [x(1,l),x(2,l),w(l),h(l)];
    arr(l,:) = [xn(l),yn(l),wn(l),hn(l)];
end

S(i).imageFilename = ppath;
S(i).person = double(arr);
 
clearvars arr h hn w wn xn yn;

end

% fclose(pid);

d = struct2table(S,'AsArray',true);

% fclose(fid);