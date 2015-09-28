function method3()

% number of years
Ny=10;

% number of controller
Nu=4;
% number of measurement
Nmu=3;

p=zeros(Nu,3,3);

% p(1,1} = [0.4,0.3,0.3; 0.3, 0.5; 0.2; 0.3, 0.2, 0.5]transition matrix
% when you choose u intervention, mu test.
p(1,:,:)=[	0.8,	0.18,	0.02;	0,	0.65,	0.35;	0,	0,	1;	];
p(2,:,:)=[	0.8,	0.16,	0.04;	0,	0.7,	0.3;	0,	0,	1;	];
p(3,:,:)=[	0.8,	0.18,	0.02;	0,	0.75,	0.25;	0,	0,	1;	];
p(4,:,:)=[	0.8,	0.19,	0.01;	0,	0.8,	0.2;	0,	0,	1;	];

p_o = zeros(Nmu,3,3);
p_o(1,:,:) = [0.6 0.2 0.2; 0.2 0.6 0.2; 0.2 0.2 0.6];
p_o(2,:,:) = [0.7 0.1 0.1; 0.2 0.7 0.2; 0.1 0.2 0.7];
p_o(3,:,:) = [0.8 0.1 0.1; 0.1 0.8 0.1; 0.1 0.1 0.8];

% set discrete belief to be a discrete grid differ by 0.1
Nb = 66;
b = zeros(3,Nb);
b_end = 0;
b_len = 11;
for i = 1:1:11
    b(1,b_end+1:b_end+b_len) = 0.1*(i-1)*ones(1,b_len);
    b(2,b_end+1:b_end+b_len) = (1-0.1*(i-1)):-0.1:0;
    b(3,b_end+1:b_end+b_len) = 0:0.1:(1-0.1*(i-1));
    b_end = b_end+b_len;
    b_len = b_len-1;
end


p_bo = zeros(Nmu,Nu,3,Nb,Nb);
p_b = zeros(Nmu,Nu,Nb,Nb);
b_o = zeros(1,3);
for mu = 1:Nmu
    for i = 1:Nb
        for a = 1:Nu
            for o = 1:3
                b_n = squeeze(p_o(mu,o,:))'.*(b(:,i)'*squeeze(p(a,:,:)));
                b_o(o) = sum(b_n);
                b_n = b_n/b_o(o);
                for i_n =1:Nb
                    p_bo(mu, a,o,i,i_n) = cosDist(b_n, b(:,i_n))^50;
                end
                p_bo(mu, a,o,i,:) = p_bo(mu, a,o,i,:)/sum(p_bo(mu, a,o,i,:));
            end
            p_b(mu,a,:,i) = b_o* squeeze(p_bo(mu, a,:,i,:));
            %sum(p_b(mu,a,:,:))
        end
    end
end
        


%%% Cost c1 cost of intervention material, c2 cost of intervention labor
% cost of
Cu=[0, 50, 100, 200];
Cmu=[89,97,126];
C.Cu=Cu;
C.Cmu=Cmu;

%W1=[0.81251, 0.06284, 0.12465];
W1=[0.8, 0.1, 0.1];
%W1=[0.8,0,0 ];
W2=[0.6, 0.2, 0.2];
%W2=[0.5, 0, 0];
%W3=[0.42448,0.32491, 0.25061];
%W3=[0.4,0.3, 0.3];
%W3=[0.4,0.3, 0.3];
W=(W2*b)';
counter=0;
tic
for lambda=logspace(-2,0,100)
    % counter= counter+1;
    % lambda=1;
    J=zeros(Ny+1,Nb);
    Q=zeros(Ny,Nb,Nu,Nmu);
    J(Ny+1,:)=lambda*W/(Ny+1);
    
    %%
    for i=Ny:-1:1
        for x=1:Nb
            for j=1:Nu
                for k=1:Nmu
                    %Q(i,x,j,k)=lambda*W (x)/(Ny+1)+(1-lambda)*(11*(max(Cu)-min(Cu)+max(Cmu)-min(Cmu)))/(Cu(j)+Cmu(k))+ J(i+1,:)*squeeze(p(j,k,x,:));
                    Q(i,x,j,k)=lambda*W(x)/(Ny+1)-(1-lambda)*(Cu(j)+Cmu(k))/(10*(max(Cu)+max(Cmu)))+ J(i+1,:)*squeeze(p_b(k,j,x,:));
                    % Q(i,x,j,k)=lambda/(W(x)*Ny)+ J(i+1,:)*squeeze(p(j,k,x,:));
                    % Q(i,x,j,k)=lambda/W(x)*Ny+(1-lambda)*(Cu(j)+Cmu(k))+ J(i+1,:)*squeeze(p(j,k,x,:));
                    
                end
            end
            [qTemp, uTemp]=max(squeeze(Q(i,x,:,:)));
            [JTemp, muTemp]=max(qTemp);
            u(i,x)=uTemp(muTemp);
            mu(i,x)=muTemp;
            J(i,x)=JTemp;
        end
        
        
    end
    %%
    J0=sum (J(1,:))/Nb;
    b_n = zeros(3,3);
    
    pi0=[1/3,1/3,1/3];
    pi=zeros(Ny+1,3);
    for i=2:Ny+1
        if (i==2)
            pi(1,1)=pi0(1,1);
            pi(1,2)=pi0(1,2);
            pi(1,3)=pi0(1,3);
        end
        for xp=1:Nb
            for o= 1:3
                b_n(o,:) = (squeeze(p_o(mu(i-1,xp),o,:))'.*(pi(i-1,:)*squeeze(p(u(i-1,xp),:,:))))';
            end
            pi(i,:)=sum(b_n);
        end
    end
    
    
    %V=1./(W*Ny);
    V = W1;
    V1=0;
    for x=1:3
        V1=V1+V(x)*pi(11,x);
    end
    V1=V1;
    
    V2=0;
    counter = counter + 1;
    %BtCellU = cell(3,10);
    for i=1:10
        for x=1:3
            tmp = V2;
            V2=V2+V(x)*pi(i,x);
%             BtArrU(x,i,counter) = u(i,x);
%             BtArrMu(x,i,counter) = mu(i,x);
%             BtArrV2(x,i,counter) = V2-tmp;
        end
    end
    V2=V2;
    
    %Jhc=(V1+V2);
    % Jhc = (V1+V2)/(11*(max(V)-min(V)));
    Jhc = (V1+V2)/(11*max(V));
    Cmu1=0; Cu1=0;
    for i=1:10
        for x=1:3
            Cmu1=Cmu1+pi(i,x)*Cmu(mu(i,x));
            Cu1=Cu1+pi(i,x)*Cu(u(i,x));
        end
    end
    %
    %Ctotal = Cmu1 + Cu1;
    %Ctotal= (Cmu1+Cu1)/(11*((max(Cu)-min(Cu))+(max(Cmu)-min(Cmu))));
    Ctotal= (Cmu1+Cu1);%/(10*(max(Cu)+max(Cmu)));
    
    %[Jhc, Ctotal]
    
    
    % x = Jhc
    % y = Ctotal
    %counter = counter + 1;
    Jhcarr(counter)=Jhc;
    Ctotalarr(counter)=Ctotal;
    
    % plot(x,y, 'b*');
    % hold on;
    % xlabel('Jhc');
    % ylabel('Ctotal');
    
end

toc
plot(Jhcarr, Ctotalarr,'b*');
xlabel('Jhc');
ylabel('Ctotal');

end

function dist = cosDist (v1, v2)
dist = v1*v2/norm(v1)/norm(v2);
end
