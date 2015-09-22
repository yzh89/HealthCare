function [value]=valueHC(Xu,Xmu,P,W)

Ny=3;
V=zeros(Ny,1);
p=[1/3,1/3,1/3];
for i=1:Ny
    pnext(1)=p(1)*Xu(:,i)'*P(:,:,1,1)*Xmu(:,i)+p(2)*Xu(:,i)'*P(:,:,2,1)*Xmu(:,i)+p(3)*Xu(:,i)'*P(:,:,3,1)*Xmu(:,i);
    pnext(2)=p(1)*Xu(:,i)'*P(:,:,1,2)*Xmu(:,i)+p(2)*Xu(:,i)'*P(:,:,2,2)*Xmu(:,i)+p(3)*Xu(:,i)'*P(:,:,3,2)*Xmu(:,i);
    pnext(3)=p(1)*Xu(:,i)'*P(:,:,1,3)*Xmu(:,i)+p(2)*Xu(:,i)'*P(:,:,2,3)*Xmu(:,i)+p(3)*Xu(:,i)'*P(:,:,3,3)*Xmu(:,i);
    V(i)=pnext(1)+pnext(2)+pnext(3);
    p=pnext;
end
value=sum(V)/Ny;
end