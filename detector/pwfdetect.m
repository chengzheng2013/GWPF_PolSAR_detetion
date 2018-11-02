function pwf = pwfdetect(img, th, width, posts)

if nargin == 2
    width = 35;
end
if nargin <= 3;
    posts.densf = 0;
    posts.morph = 0;
    posts.rad = 3;
end

[Nx,Ny,Nc] = size(img);

% figure;
% imshow(img);
densGate = posts.densf*width^2;              %�ܶ��˲���ֵ
rad = posts.rad;                        %��̬ѧ�˲��ṹԪ�ذ뾶ֵ

%--ͼ��ǰ�ڴ���
f = double(img);

%--ȷ��CFAR������Ĳ���

%--2.ȷ���������ı߳�
proLength = width*2 + 1;                           %Ϊ������㣬ȡΪ����

%--3.ȷ���Ӳ������ο��
cLength = 5;                                            %���һ��Ϊ1�����ص�

%--4.���������Ӳ������������
numPix = 4*cLength*(cLength+proLength); 

%--6.CFAR������߳�
cfarLength = proLength + 2*cLength;
% str = sprintf('CFAR������������߳���%f���Ӳ������ο�ȣ�%f�������Ӳ�����������%f'...
%               ,proLength,cLength,numPix);               %��ʾ
% disp(str);                                              %��ʾ

%--------------------------------------------------------------------------
%         ������ԭͼ��߽����䣬�������߽��Ӱ��
%--------------------------------------------------------------------------
padLength = width+cLength;           %ȷ��ͼ�����ı߽��СΪCFAR������һ��
g = padarray(f,[padLength padLength],'symmetric');      %gΪ�����ͼ��
g = reshape(g, [], Nc);
f = reshape(f, [], Nc);
%--2.�������
cfarRegion = true(cfarLength);
cfarRegion(cLength+1:proLength, cLength+1:proLength) = false;
[r, c] = find(cfarRegion);
inds = sub2ind([Nx, Ny], r, c);

h = waitbar(0, 'sliding processing');
pwf = zeros(Nx, Ny);
for i = 1:Nx*Ny

        sec = g(i + inds, :);       %�õ�(i,j)����������Ӧ��4���Ӳ�������������ͼ��ʾ
        
        %���Ӳ�����õ���ֵ�ͱ�׼ƫ��
        
        if Nc == 3 || Nc == 4
            %--2.�������ϲ�
            C = sec.' * conj(sec) / numPix;
        else
            C = reshape(mean(sec), [3 3]);
        end

        if Nc == 3
            x = squeez(f(i,:));
            pwf(i) = x'*C\x;    %����pwf
        else
            X = reshape(f(i,:), [3 3]);
            pwf(i) = trace(C\X)+ log(det(C)); %Wishart distance
        end
    waitbar(i/Nx/Ny, h, sprintf('processing at %d / %d pixels...', i, Nx*Ny));
end
delete(h);

pwf = real(pwf);

if ~th
    return;
end

bw = false(Nx, Ny, length(th));
r = minmax(pwf(:)');
for kk = 1:length(th)
    resultArray = pwf>(th(kk) * r(2) + (1-th(kk)) * r(1));
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
        resultArray1(row(k),col(k)) = densfilt(resultArray,row(k),col(k),width,width,...
                                       densGate);
    end

    % figure('Name','�ܶ��˲����ֵͼ'),imshow(resultArray1);

    if ~posts.morph
        bw(:,:,kk) = resultArray1;
        continue;
    end
    %--2.��̬ѧ�˲�
    se = strel('disk',rad);
    resultArray2 = imopen(resultArray1,se);
    se = strel('disk',rad);
    resultArray2 = imclose(resultArray2,se);

    % figure('Name','��̬�˲����ֵͼ'),imshow(resultArray2);

    bw(:,:,kk) = resultArray2;
end
pwf = bw;
