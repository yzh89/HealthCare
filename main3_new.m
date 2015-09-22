for xx=1:1
    
    %simulation runs
    %number of patient
    Np=100000;
    %number of years
    Ny=10;
    
    %number of controller
    Nu=10;
    %number of measurement
    Nmu=3;
    
    p=cell(Nu,Nmu);
    
    % P{1,1} = [0.4,0.3,0.3; 0.3, 0.5; 0.2; 0.3, 0.2, 0.5]
    p{	1,1	}=[	0.5,	0.5,	0;	0.3,	0.6,	0.1;	0,	0.65,	0.35;	];
    p{	2,1	}=[	0.25,	0.5,	0.25;	0.3,	0.55,	0.15;	0.35,	0.55,	0.1;	];
    p{	3,1	}=[	0.125,	0.5,	0.375;	0.6,	0.1,	0.3;	0.23,	0.6,	0.17;	];
    p{	6,1	}=[	0.125,	0.5,	0.375;	0.3,	0.6,	0.1;	0.187,	0.55,	0.263;	];
    p{	1,2	}=[	0.1,	0.6,	0.3;	0.2,	0.5,	0.3;	0.15,	0.65,	0.2;	];
    p{	4,2	}=[	0.05,	0.8,	0.15;	0.2,	0.5,	0.3;	0.15,	0.65,	0.2;	];
    p{	5,2	}=[	0.05,	0.8,	0.15;	0.25,	0.55,	0.2;	0.3,	0.58,	0.12;	];
    p{	7,2	}=[	0.3,	0.5,	0.2;	0.3,	0.6,	0.1;	0.25,	0.65,	0.1;	];
    p{	9,2	}=[	0.3,	0.45,	0.25;	0.175,	0.65,	0.175;	0.225,	0.675,	0.1;	];
    p{	1,3	}=[	0.25,	0.55,	0.2;	0.2,	0.7,	0.1;	0.25,	0.55,	0.2;	];
    p{	8,3	}=[	0.2,	0.6,	0.2;	0.3,	0.6,	0.1;	0.2,	0.67,	0.13;	];
    p{	10,3	}=[	0.25,	0.5,	0.25;	0.3,	0.6,	0.1;	0.27,	0.65,	0.08;	];
    
    
    p{4,1}=eye(3);
    p{5,1}=eye(3);
    
    
    p{7,1}= eye(3);
    p{8,1}= eye(3);
    p{9,1}=eye(3);
    p{10,1}=eye(3);
    
    
    p{2,2}=eye(3);
    
    p{3,2}=eye(3);
    p{6,2} = eye(3);
    
    p{8,2}=eye(3);
    
    p{10,2}=eye(3);
    
    
    p{2,3}=eye(3);
    p{3,3}=eye(3);
    p{4,3}=eye(3);
    p{5,3}=eye(3);
    p{6,3}=eye(3);
    p{7,3}= eye(3);
    p{9,3}=eye(3);
    
    
    %%%Cost
    C1=[200, 100, 100, 200, 250, 100, 200, 300, 200, 500];
    C2=[120, 200, 60,  120,  180, 50, 100, 100 ,150 ,120];
    Cu=C1+C2;
    Cmu=[89,97,126];
    C.Cu=Cu;
    C.Cmu=Cmu;
    
    %value for transition from state i to state j
    R=[0 0 0;0.15, 0 0; 0.31, 0.25, 0];
    
    data = repmat(struct('x',Ny+1,'u',Ny,'mu',Ny,'C',1,'R',1), Np, 1 );
    Cost=zeros(1,Np);
    Reward=zeros(1,Np);
    X=zeros(Ny+1,Np);
    
    for i=1:Np
        data(i)=monteCarlo_new(p,C,Ny+1,R);
        Cost(i)=data(i).C;
        Reward(i)=data(i).R;
        X(:,i)=data(i).x;
    end
    
    Rs=histc(X,[1,2,3])/(Ny+1);
    W1=[0.81251, 0.06284, 0.12465];
    W2=[0.53248, 0.34641, 0.12111];
    W3=[0.42448,0.32491, 0.25061];
    Perf1=W1*Rs;
    Perf2=W2*Rs;
    Perf3=W3*Rs;
    %%
    g1=figure(1)
    pareout1=paretoGroup([(1./Perf1)',Cost',(1./Reward)']);
    plot3(Perf1, Cost,Reward,'.',Perf1(pareout1),Cost(pareout1),Reward(pareout1),'r.');
    fgn=strcat('Fig1_',num2str(xx));
    xlabel('Performance')
    ylabel('Cost')
    zlabel('Reward')
    savefig(g1,fgn);
    
    g2=figure(2)
    pareout2=paretoGroup([(1./Perf2)',Cost',(1./Reward)']);
    plot3(Perf2, Cost,Reward,'.',Perf2(pareout2),Cost(pareout2),Reward(pareout2),'r.');
    fgn=strcat('Fig2_',num2str(xx));
    xlabel('Performance')
    ylabel('Cost')
    zlabel('Reward')
    savefig(g2,fgn);
    
    g3=figure(3)
    pareout3=paretoGroup([(1./Perf3)',Cost',(1./Reward)']);
    plot3(Perf3, Cost,Reward,'.',Perf3(pareout3),Cost(pareout3),Reward(pareout3),'r.');
    fgn=strcat('Fig3_',num2str(xx));
    xlabel('Performance')
    ylabel('Cost')
    zlabel('Reward')
    savefig(g3,fgn);
    
    %%
    
    %return index
    iP=find(pareout1);
    filename = strcat('ParetoOutput_1',num2str(xx),'.xlsx');
    xlswrite(filename,{' ','x','u','mu'});
    for i=1:length(iP)
        xlswrite(filename,data(iP(i)).x,['B',num2str((i-1)*Ny+2),':B',num2str(i*Ny+1)]);
        xlswrite(filename,data(iP(i)).u,['C',num2str((i-1)*Ny+2),':C',num2str(i*Ny)]);
        xlswrite(filename,data(iP(i)).mu,['D',num2str((i-1)*Ny+2),':D',num2str(i*Ny)]);
        xlswrite(filename,{data(iP(i)).C,data(iP(i)).R, Perf1(iP(i))},['E',num2str((i-1)*Ny+2),':G',num2str((i-1)*Ny+2)])
    end
    %return index
    iP=find(pareout2);
    filename = strcat('ParetoOutput_2',num2str(xx),'.xlsx');
    xlswrite(filename,{' ','x','u','mu'});
    for i=1:length(iP)
        xlswrite(filename,{' ','x','u','mu'});
        xlswrite(filename,data(iP(i)).x,['B',num2str((i-1)*Ny+2),':B',num2str(i*Ny+1)]);
        xlswrite(filename,data(iP(i)).u,['C',num2str((i-1)*Ny+2),':C',num2str(i*Ny)]);
        xlswrite(filename,data(iP(i)).mu,['D',num2str((i-1)*Ny+2),':D',num2str(i*Ny)]);
        xlswrite(filename,{data(iP(i)).C,data(iP(i)).R, Perf1(iP(i))},['E',num2str((i-1)*Ny+2),':G',num2str((i-1)*Ny+2)])
        
    end
    %return index
    iP=find(pareout3);
    filename = strcat('ParetoOutput_3',num2str(xx),'.xlsx');
    xlswrite(filename,{' ','x','u','mu'});
    for i=1:length(iP)
        xlswrite(filename,data(iP(i)).x,['B',num2str((i-1)*Ny+2),':B',num2str(i*Ny+1)]);
        xlswrite(filename,data(iP(i)).u,['C',num2str((i-1)*Ny+2),':C',num2str(i*Ny)]);
        xlswrite(filename,data(iP(i)).mu,['D',num2str((i-1)*Ny+2),':D',num2str(i*Ny)]);
        xlswrite(filename,{data(iP(i)).C,data(iP(i)).R, Perf1(iP(i))},['E',num2str((i-1)*Ny+2),':G',num2str((i-1)*Ny+2)])
    end
end
