clear;
clc

% number of years
Ny=10;

% number of controller
Nu=10;
% number of measurement
Nmu=3;

p=zeros(Nu,Nmu,3,3);

% p(1,1} = [0.4,0.3,0.3; 0.3, 0.5; 0.2; 0.3, 0.2, 0.5]transition matrix
% when you choose u intervention, mu test.
p(1,1,:,:)=[	0.5,	0.5,	0;	0.3,	0.6,	0.1;	0,	0.65,	0.35;	];
p(2,1,:,:)=[	0.25,	0.5,	0.25;	0.3,	0.55,	0.15;	0.35,	0.55,	0.1;	];
p(3,1,:,:)=[	0.125,	0.5,	0.375;	0.6,	0.1,	0.3;	0.23,	0.6,	0.17;	];
p(6,1,:,:)=[	0.125,	0.5,	0.375;	0.3,	0.6,	0.1;	0.187,	0.55,	0.263;	];
p(	1,2,:,:)=[	0.1,	0.6,	0.3;	0.2,	0.5,	0.3;	0.15,	0.65,	0.2;	];
p(	4,2,:,:)=[	0.05,	0.8,	0.15;	0.2,	0.5,	0.3;	0.15,	0.65,	0.2;	];
p(	5,2,:,:)=[	0.05,	0.8,	0.15;	0.25,	0.55,	0.2;	0.3,	0.58,	0.12;	];
p(	7,2,:,:)=[	0.3,	0.5,	0.2;	0.3,	0.6,	0.1;	0.25,	0.65,	0.1;	];
p(	9,2,:,:)=[	0.3,	0.45,	0.25;	0.175,	0.65,	0.175;	0.225,	0.675,	0.1;	];
p(	1,3,:,:)=[	0.25,	0.55,	0.2;	0.2,	0.7,	0.1;	0.25,	0.55,	0.2;	];
p(	8,3,:,:)=[	0.2,	0.6,	0.2;	0.3,	0.6,	0.1;	0.2,	0.67,	0.13;	];
p(	10,3,:,:)=[	0.25,	0.5,	0.25;	0.3,	0.6,	0.1;	0.27,	0.65,	0.08;	];

p(4,1,:,:)=eye(3);
p(5,1,:,:)=eye(3);

p(7,1,:,:)= eye(3);
p(8,1,:,:)= eye(3);
p(9,1,:,:)=eye(3);
p(10,1,:,:)=eye(3);

p(2,2,:,:)=eye(3);

p(3,2,:,:)=eye(3);
p(6,2,:,:) = eye(3);

p(8,2,:,:)=eye(3);

p(10,2,:,:)=eye(3);
p(2,3,:,:)=eye(3);
p(3,3,:,:)=eye(3);
p(4,3,:,:)=eye(3);
p(5,3,:,:)=eye(3);
p(6,3,:,:)=eye(3);
p(7,3,:,:)= eye(3);
p(9,3,:,:)=eye(3);
%%% Cost c1 cost of intervention material, c2 cost of intervention labor
% cost of
C1=[200, 100, 100, 200, 250, 100, 200, 300, 200, 500];
C2=[120, 200, 60,  120,  180, 50, 100, 100 ,150 ,120];
Cu=C1+C2;
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
W=W2;
counter=0;
for lambda=logspace(-2,0,1000)
    % counter= counter+1;
    % lambda=1;
    J=zeros(Ny+1,3);
    Q=zeros(Ny,3,Nu,Nmu);
    J(Ny+1,:)=lambda*W/(Ny+1);
    
    %%
    for i=Ny:-1:1
        for x=1:3
            for j=1:Nu
                for k=1:Nmu
                    %Q(i,x,j,k)=lambda*W (x)/(Ny+1)+(1-lambda)*(11*(max(Cu)-min(Cu)+max(Cmu)-min(Cmu)))/(Cu(j)+Cmu(k))+ J(i+1,:)*squeeze(p(j,k,x,:));
                    Q(i,x,j,k)=lambda*W(x)/(Ny+1)-(1-lambda)*(Cu(j)+Cmu(k))/(10*(max(Cu)+max(Cmu)))+ J(i+1,:)*squeeze(p(j,k,x,:));
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
    J0=sum (J(1,:))/3;
    
    pi0=[1/3,1/3,1/3];
    pi=zeros(Ny+1,3);
    for i=2:Ny+1
        for x=1:3
            if (i==2)
                pi(1,1)=pi0(1,1);
                pi(1,2)=pi0(1,2);
                pi(1,3)=pi0(1,3);
            end
            for xp=1:3
                pi(i,x)=pi(i,x)+pi(i-1,xp)*p(u(i-1,xp),mu(i-1,xp),xp,x);
            end
        end
    end
    
    
    %V=1./(W*Ny);
    V = W;
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
            BtArrU(x,i,counter) = u(i,x);
            BtArrMu(x,i,counter) = mu(i,x);
            BtArrV2(x,i,counter) = V2-tmp;
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

plot(Jhcarr, Ctotalarr,'b*');
xlabel('Jhc');
ylabel('Ctotal');

