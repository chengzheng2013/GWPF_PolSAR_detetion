function [resultArray, resultArray2, resultArray3 ]= cfar(f, paras) 
%SARͼ��CFARĿ�����㷨

figure;
imshow(f,[]);

%--Ĭ�ϲ���

pf = 0.001;                          %��Ϊ�趨�ĺ��龯��
densGate = 40;              %�ܶ��˲���ֵ
rad = 3;                        %��̬ѧ�˲��ṹԪ�ذ뾶ֵ
numIter = 10;
tol = 1024;
width = 32;
height = 32;
if nargin == 2
    fields = fieldnames(paras);
    for i = length(fields)
        if ~isempty(paras.(fields(i)))
            eval([fields(i), '=', paras.(fields(i))]);
        end
    end
end
%--ͼ��ǰ�ڴ���
f = double(f);
f_size = size(f);


%--------------------------------------------------------------------------
%        һ��ȷ��CFAR������������������ڳߴ磬��������ȣ��Ӳ������
%--------------------------------------------------------------------------

%--ȷ��CFAR������Ĳ���
%--1.ȡ�����е����ֵ
global tMaxLength;
tMaxLength = max(width,height);

%--2.ȷ���������ı߳�
global proLength;
proLength = tMaxLength*2 + 1;                           %Ϊ������㣬ȡΪ����

%--3.ȷ���Ӳ������ο��
global cLength;
cLength = 2;                                            %���һ��Ϊ1�����ص�

%--4.���������Ӳ������������
numPix = 2*cLength*(2*cLength+proLength+proLength); 

%--6.CFAR������߳�
global cfarLength;
cfarLength = proLength + 2*cLength;
str = sprintf('CFAR������������߳���%f���Ӳ������ο�ȣ�%f�������Ӳ�����������%f'...
              ,proLength,cLength,numPix);               %��ʾ
disp(str);                                              %��ʾ

%--------------------------------------------------------------------------
%         ������ԭͼ��߽����䣬�������߽��Ӱ��
%--------------------------------------------------------------------------
padLength = tMaxLength + cLength;           %ȷ��ͼ�����ı߽��СΪCFAR������һ��
global g;
g = padarray(f,[padLength padLength],'symmetric');      %gΪ�����ͼ��


%--------------------------------------------------------------------------
%         ����ȷ��CFAR��ֵ
%--------------------------------------------------------------------------

th = (2*sqrt(-log(pf))-sqrt(pi))/(sqrt(4-pi));  %����ֵ����Ϊȷ�����龯������
                                                %��

%--------------------------------------------------------------------------
%        �ġ�����CFAR����������ֲ���ֵ��ִ�е������ص���ж�
%--------------------------------------------------------------------------

%--0.�������������

%--1.ȫ�ּ��
global resultArray0;
resultArray0 = g > 0.5*std(g(:)) + mean(g(:));
resultArray = resultArray0;
%--2.CFAR���
figure(2)
filename = 'test.gif';
frame = getframe(2);
im = frame2im(frame);
[imind,cm] = rgb2ind(im,256);
imagesc(resultArray0);title('changing');axis off;
imwrite(imind,cm,filename,'gif', 'Loopcount',inf);
%����ͼ���е�ÿ����
for k = 1:numIter
    for i = (1+padLength):(f_size(1)+padLength)
        for j = (1+padLength):(f_size(2)+padLength)
            if ~resultArray0(i,j)
                continue;
            end
            clutter = getEstSec(i,j);
            if length(clutter) <= 10
                continue;
            end
            u = mean(clutter);
            delta = std(clutter);
            temp = (g(i,j)-u)/delta;    %����˫����CFAR����б�ʽ
            %Ŀ����б�
            if temp > th                
                resultArray(i,j) = true;
            else resultArray(i,j) = false;
            end
        end
    end
    numdif = sum(sum(xor(resultArray,resultArray0)));
    
    if  numdif< tol
        break;
    end
    disp(['The number of changed pixels: ', num2str(numdif)]);
    imagesc(resultArray0 + resultArray);
    drawnow;
    frame = getframe(2);
    im = frame2im(frame);
    [imind,cm] = rgb2ind(im,256);
    imwrite(imind,cm,filename,'gif','WriteMode','append');
    resultArray0 = resultArray;
end
%--------------------------------------------------------------------------
%                         �塢Ŀ�����ؾ���
%--------------------------------------------------------------------------
%--1.�ܶ��˲�
[row col] = find(resultArray);     %�ҵ�Ŀ�����ص����������
numIndex2 = numel(row);                 %ȷ��Ŀ������
resultArray2 = zeros(size(resultArray));          %resultArray2���Դ���ܶ��˲���ľ���
for k = 1:numIndex2                     %ִ���ܶ��˲�
    resultArray2(row(k),col(k)) = densfilt(resultArray,row(k),col(k),width,height,...
                                   densGate);
end

%--2.��̬ѧ�˲�
se = strel('disk',rad);
resultArray3 = imopen(resultArray2,se);        %������
se = strel('disk',rad);
resultArray3 = imclose(resultArray3,se);       

%--3.չʾ���ͼƬ
resultArray = resultArray((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','CFAR�����ֵͼ'),imshow(resultArray);
resultArray2 = resultArray2((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','�ܶ��˲����ֵͼ'),imshow(resultArray2);
resultArray3 = resultArray3((padLength+1):(end-padLength),(padLength+1):(end-padLength));
figure('Name','��̬�˲����ֵͼ'),imshow(resultArray3);
toc;


function sec = getEstSec(c,r)

global cLength cfarHalfLength g resultArray0;
exLen = cfarHalfLength;

allSec = resultArray0(c-exLen:c+exLen, r-exLen:r+exLen);
allSec(cLength+1:end-cLength, cLength+1:end-cLength) = true;
sec = g(c-exLen:c+exLen, r-exLen:r+exLen);
sec = sec(~(allSec));
