%simulation runs
%number of patient
Np=100000;
%number of years
Ny=10;

%number of controller
Nu=10;
%number of measurement
Nmu=3;

P=cell(Nu,Nmu);

% P{1,1} = [0.4,0.3,0.3; 0.3, 0.5; 0.2; 0.3, 0.2, 0.5]
P{1,1}= [0.05	,0.05	,0; 0.2, 0.3,	0.1; 0,	0.2,	0.1];
P{2,1} = [0.1043,	0.2758,	0.105; 0.147, 0.3297,	0.1211; 0.1134,	0.2674,	0.098];
p{3,1}=[0.0745,	0.197,	0.075; 0.105,	0.2355,	0.0865; 0.081,	0.191,	0.07];

p{4,1}=zeros(3,3);
p{5,1}=zeros(3,3);

p{6,1}=[0.00745,	0.0197,	0.0075; 0.0105,	0.02355,	0.00865; 0.0081,	0.0191,	0.007];

p{7,1}= zeros(3,3);
p{8,1}= zeros(3,3);
p{9,1}=zeros(3,3);
p{10,1}=zeros(3,3);

P{1,2}=[0.1575,	0.35325,	0.12975; 0.1575,	0.35325,	0.12975; 0.1575,	0.35325,	0.12975];

p{2,2}=zeros(3,3);

p{3,2}=zeros(3,3);
p{4,2}=[0.0021,	0.00471,	0.00173; 0.0021,	0.00471,	0.00173; 0.0021,	0.00471,	0.00173];

p{5,2}=[0.0021,	0.00471,	0.00173; 0.0021,	0.00471,	0.00173; 0.0021,	0.00471,	0.001730];
p{6,2} = zeros(3,3);
p{7,2}=[0.021,	0.0471,	0.0173; 0.021,	0.0471,	0.0173; 0.021,	0.0471,	0.0173];
p{8,2}=zeros(3,3);
p{9,2}=[0.168,	0.3768,	0.1384; 0.168,	0.3768,	0.1384; 0.168,	0.3768,	0.1384];
p{10,2}=zeros(3,3);
p{1,3}=[0.1215,	0.2865,	0.105; 0.1215,	0.2865,	0.105; 0.1215,	0.2865,	0.105];


p{2,3}=zeros(3,3);
p{3,3}=zeros(3,3);
p{4,3}=zeros(3,3);
p{5,3}=zeros(3,3);
p{6,3}=zeros(3,3);
p{7,3}= zeros(3,3);

p{8,3}= [0.0162,	0.0382,	0.014; 0.0162,	0.0382,	0.014; 0.0162,	0.0382,	0.014];
p{9,3}=zeros(3,3);
p{10,3}=[0.1296,	0.3056,	0.112; 0.1296,	0.3056,	0.112; 0.1296,	0.3056,	0.112];


%%%Cost
C1=[200, 100, 100, 200, 250, 100, 200, 300, 200, 500];
C2=[120, 200, 60,  120,  180, 50, 100, 100 ,150 ,120];
Cu=C1+C2;
Cmu=[89,97,126];
C.Cu=Cu;
C.Cmu=Cmu;

for i=1:Nu
    for j=1:Nmu
        P{i,j}=[0.5,0.3,0.2; 0.3,0.5,0.2; 0.1, 0.4, 0.5];
    end
end


for i=1:Np
    data(i)=monteCarlo(P,C,Ny);
    Cost(i)=data(i).C;
    X(:,i)=data(i).x;
end

Rs=histc(X,[1,2,3])/Ny;
W1=[0.6,0.3,0.1];
W2=[0.8,0.1,0.1];
W3=[0.5,0.3,0.2];
Perf1=W1*Rs;
Perf2=W2*Rs;
Perf3=W3*Rs;
%%
figure(1)
pareout1=paretoGroup([(1./Perf1)',Cost']);
plot(Perf1, Cost,'.',Perf1(pareout1),Cost(pareout1),'r.');

figure(2)
pareout2=paretoGroup([(1./Perf2)',Cost']);
plot(Perf2, Cost,'.',Perf2(pareout2),Cost(pareout2),'r.');

figure(3)
pareout3=paretoGroup([(1./Perf3)',Cost']);
plot(Perf3, Cost,'.',Perf3(pareout3),Cost(pareout3),'r.');

%%

%return index
iP=find(pareout1);
filename = 'ParetoOutput.xlsx';
for i=1:length(iP)
    xlswrite(filename,{'x','u','mu'},i);
    xlswrite(filename,data(iP(i)).x,i,['A',num2str(2),':A',num2str(Ny+1)]);
    xlswrite(filename,data(iP(i)).u,i,['B',num2str(2),':B',num2str(Ny)]);
    xlswrite(filename,data(iP(i)).mu,i,['C',num2str(2),':C',num2str(Ny)]);
end
