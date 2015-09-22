function [out] = monteCarlo_new(P,C,N,R)

%N is the number of years
x0=randi(3,1);
Nu=10;
Nmu=3;
x=zeros(N,1);
U=zeros(N-1,1);
Mu=zeros(N-1,1);
x(1)=x0;
Cmu=C.Cmu;
Cu=C.Cu;
Ctotal=0;
Rtotal=0;
for i=2:N
    u=randi(Nu,1);
    mu=randi(Nmu,1);
    Ctotal=Ctotal+Cu(u)+Cmu(mu);
    U(i-1)=u;
    Mu(i-1)=mu;
    x(i) = sum(rand() >= cumsum([0, P{u,mu}(x(i-1),:)]));
    Rtotal=R(x(i-1),x(i))+Rtotal;
end
out.x=x;
out.u=U;
out.mu=Mu;
out.C=Ctotal;
out.R=Rtotal;