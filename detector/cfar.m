function outImg = cfar(img, th, width, posts)

if nargin == 2
    width = 32;
end
if nargin <= 3;
    posts.densf = 0;
    posts.morph = 0;
    posts.rad = 3;
end
[Nx,Ny,Nc] = size(img);
assert(Nc == 1, 'Only for graylevel image!');
% figure;
% imshow(img);


%--ͼ��ǰ�ڴ���
f = double(img);

%--ȷ��CFAR������Ĳ���

%--1.ȷ���������ı߳�
proLength = width*2 + 1;                           %Ϊ������㣬ȡΪ����

%--2.ȷ���Ӳ������ο��
global cLength;
cLength = 2;                                            %���һ��Ϊ1�����ص�

global cfarHalfLength;
cfarHalfLength = width + cLength;

%--3.CFAR������߳�
% cfarLength = proLength + 2*cLength;
str = sprintf('CFAR������������߳���%f���Ӳ������ο�ȣ�%f.'...
              ,proLength,cLength);               %��ʾ
disp(str);                                              %��ʾ

%--------------------------------------------------------------------------
%         ������ԭͼ��߽����䣬�������߽��Ӱ��
%--------------------------------------------------------------------------
padLength = cfarHalfLength;           %ȷ��ͼ�����ı߽��СΪCFAR������һ��
global g;
g = padarray(f,[padLength padLength],'symmetric');      %gΪ�����ͼ��

%--1.ȫ�ּ��
global g_det;
g_det = g > 0.5*std(g(:)) + mean(g(:));

%--2.�������
% h = waitbar(0, 'sliding processing');
outImg = zeros(Nx, Ny);
for i = 1:Nx
    for j = 1:Ny
        if ~g_det(i+padLength,j+padLength)
            continue;
        end
        outImg(i, j) = cfarWindow(i+padLength,j+padLength);
    end
%     waitbar(i/Nx, h, sprintf('processing at %d / %d row...', i, Nx));
end
% delete(h)

if ~th
    return;
end

densGate = posts.densf*width^2;              %�ܶ��˲���ֵ
r = minmax(outImg(:));
for kk = 1:length(th)
    resultArray = outImg >(th(kk) * r(2) + (1-th(kk)) * r(1));
    if ~posts.densf
        bw(:,:,kk) = resultArray;
        continue;
    end
    %--------------------------------------------------------------------------
    %                         �塢Ŀ�����ؾ���
    %--------------------------------------------------------------------------
    %--1.�ܶ��˲�
    [row, col] = find(resultArray);     %�ҵ�Ŀ�����ص����������
    numIndex2 = numel(row);                 %ȷ��Ŀ������
    resultArray1 = zeros(size(resultArray));          %resultArray2���Դ���ܶ��˲���ľ���
    for k = 1:numIndex2                     %ִ���ܶ��˲�
        resultArray1(row(k),col(k)) = densfilt(resultArray,row(k),col(k), width, width, densGate);
    end

    % figure('Name','�ܶ��˲����ֵͼ'),imshow(resultArray1);

    if ~posts.morph
        bw(:,:,kk) = resultArray1;
        continue;
    end
    %--2.��̬ѧ�˲�
    rad = posts.rad;     
    se = strel('disk',rad);
    resultArray2 = imopen(resultArray1,se);
    se = strel('disk',rad);
    resultArray2 = imclose(resultArray2,se);

    % figure('Name','��̬�˲����ֵͼ'),imshow(resultArray2);

    bw(:,:,kk) = resultArray2;
end

outImg = bw;

function output = cfarWindow(c,r)

global cLength cfarHalfLength g g_det;
exLen = cfarHalfLength;

allSec = g_det(c-exLen:c+exLen, r-exLen:r+exLen);
allSec(cLength+1:end-cLength, cLength+1:end-cLength) = true;
sec = g(c-exLen:c+exLen, r-exLen:r+exLen);
sec = sec(~(allSec));
output = (g(c,r) - mean(sec)) / std(sec);   %����˫����CFAR����б�ʽ
