function [ U ] = gs_Oth( A )
%GS_OTH �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%   ����ԭʼ���� A
%   ��������� U
%   U�ĵ�һ��ΪA�ĵ�һ�ж�Ӧ�ĵ�λ����
    numF = size(A, 1);
    U = zeros(numF, rank(A));
    U(:,1) = A(:,1)/norm(A(:,1));
    curV = 2; i = 2;
    while i <= size(U,2)
        res = A(:,curV);
        for j = 1:i-1
            res = res - A(:,curV)'*U(:,j)*U(:,j);
            if norm(res) == 0
                curV = curV + 1;
                continue;
            end
        end
        U(:,i) = res/norm(res);
        i = i + 1;
    end
end

