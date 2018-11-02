function value = densfilt(img, r,c,width,height,densGate)
%   value=densfilt(r,c,width,height,densGate)��r��c�ֱ����������ص��к��У�
%   width��height�ֱ�����˲�����ģ��Ŀ�͸ߣ�densGate�����˲���ֵ��valueֵ
%   ���б���

a = ceil(height/2);
b = ceil(width/2);
%--1.�����Բ�������Ϊ���ĵ��˲�����ģ���λ��
rStart = max(r - a, 1);
rEnd = min(r + a, size(img,1));
cStart = max(c - b, 1);
cEnd = min(c + b, size(img,2));

%--2.�õ�����ģ��ģ���е�Ŀ��������
densSection = img(rStart:rEnd,cStart:cEnd);
num = sum(densSection(:));
%--3.�ж��˲�
if num >= densGate
    value = true;
else
    value = false;
end