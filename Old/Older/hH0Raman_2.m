function out = hH0Raman_2(N,bins,flag,nn,pbc,T,jx,jz,h)
%This function computes Raman spectra for the H0 lattice
%   These calculations are based off of the paper by B Perreault, K Knolle,
%   NB Perkins, and FJ Burnell, with a three spin term added (NNN Majorana
%   spinon hopping)
%   Some of the background algebra was done in a notebook by Perreault
%   called H0_finite_cell_and_BZ.nb
% We choose finite in a1.

%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Inputs
%N - 2*N is the number of sampling points in each dimension (3 here)
%bins - the number of bins on the energy axis for the plots
%flag - whether to estimate time
%nn - the number of times this same code will be run for this time estimate
%T - the number of layers in the finite direction
%jx,jz - the spin-exchange or hopping parameters (jy=jx)
%h - the coefficient of the three-spin term (assumed isotropic)
%%%%%%%%%%%%%%%%%%%%%%%%%%


layers = zeros(T,1);
for t=1:T
    ll=2*pi*t/T;
    if ll>pi
        layers(t) = ll-2*pi;
    else
        layers(t) = ll;
    end
end

% Unit vectors
a1 = [-1,-sqrt(2),0];
a2 = [-1,sqrt(2),0]; %%%%%%%%%%
a3 = [-1,0,3];%%%%%%%%%%

r2 = rand;
r3 = rand;

%The size of the matrices 
M = 4*T;
S = 2*T;

%Coupling choice consistent with symmetry
jy = jx;
jxa=jx; jya=jy; jxb=jx; jyb=jy;
kxa=h; kxb=h; kya=h; kyb=h; kz=h;

%the max energy for the energy axis
emax = 4*(jx+jy+jz+6*h);  % This is the exact bandwidth

%A convenient notation for sampling points per dimension
L=2*N;

%Initialization
r1 = rand;  r3 = rand; %r2 = rand;
pts = (-N):(N-1);

Ev = (1:bins)'*emax/bins;

%The six are the six symmetric binary products of R^aa, R^ac, R^cc
    %h1 = {aa, aa, aa, ac, ac, cc, ab, bc};
    %h2 = {aa, ac, cc, ac, cc, cc, ab, bc};
m1 = {1,1,1,3,3,5,2,4};
m2 = {1,3,5,3,5,5,2,4};
mm = size(m1,2);

%The different terms given a certain combination
%{aa,ab,ac,bc,cc}
hxa = {1,-sqrt(2), 1,-sqrt(2),1}./4;
hya = {1,-sqrt(2),-1, sqrt(2),1}./4;
hxb = {1, sqrt(2), 1, sqrt(2),1}./4;
hyb = {1, sqrt(2),-1,-sqrt(2),1}./4;
hz =  {0,0,0,0               ,1};
nm = 5;

%Initialize the matrices so their memory is fixed.
RRR = cell(1,nm); RRr = RRR;

I = RRR; 
zerolist = zeros(size(Ev));
Dd = zerolist; Ddd=Dd;

W = cell(1,mm); 
zeroB = zeros(L,S,S);
enty = zeroB;
enty2 = zeros(L,S);
zeromat = zeros(S,S);

for m=1:mm
    I{m} = zerolist;  
    W{m} = zeroB;
end
count=0;
zeroes=0;
count1=Inf;
clockit = true;
clockit2 = true;

%Loop over the Brillouin Zone
for zind = pts 
    %count
   % count1
    %I display an estimate of the end time
    aleph = 1;% + round( (10/N)^2 ); %iterations for ~1 second of computation, or one iteration, which ever takes longer
    %Or an iteration, which ever is longer
    if (count >= 1) && flag && clockit   %the first few may be slower due to initialization, start from the third one
        cl1 = clock;
        count1=count;
        clockit = false;
    end
    if (count >= count1+aleph) && flag && clockit2
        cl2 = clock;
        time = (cl2-cl1)*((4*N^2)/(count-count1))*nn*.62;
        %cl = cl1 + time*(2*N-2)/(2*N);
        clockit2=false;
        
        format shortg
        disp('approximate time to take:')
        disp( datestr(time(6)/24/3600, 'DD-HH:MM:SS') )
        format
    end
    
    %for layind = 1:T
    for xind = pts


%kc = (zind + r3)*pi*(1/3) *1/N;%%%%%%%%%%%%%%%
%ka = (xind + r1)*pi*(29/36) *1/N; %%%%%%%%%
%kb = -(ka+layers(layind))/sqrt(2); %%%%%%%%%

%k = [ka,kb,kc].';

%k1 = (xind + r1)*pi/N;
k2 = (xind + r2)*pi/N;
k3 = (zind + r3)*pi/N;

%Check that this point is in the BZ, otherwise go to next point
%sn=-1;
%for tt = -2:2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This BZ cannot work for the finite slab case (without periodic BCs) so
% this code is garbage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %if sign(29*pi/36 - abs(ka) - abs(kb+tt*pi*sqrt(2))/sqrt(2) - abs(kc)/3 )>0
   %     sn=1;
   % end
%end
sn=1;     

if sn>0
%     if ylast<yind
     count = count+1;
%     ylast = yind;
%     end

%Phases
p1 = 0;
%p1 = exp(1i.*(k1));
p2 = exp(1i.*(k2));
p3 = exp(1i.*(k3));

%Build the matrix
DD = [jz,(jya + jxa.*p1)./p3 ;
      (jxb + jyb.*p2),jz];
alph = kyb-kya./p3-kxb*p2+kxa*p1/p3;
FF = [kz*(conj(p1)-p1), alph; -conj(alph), kz*(conj(p2)-p2)];
%F24 = [-kz*(conj(p1)-p1), -alph; conj(alph), -kz*(conj(p2)-p2)];
zero = 0*DD;
H0 = 1i*[FF , DD; -DD', -FF]; 

%"p1=1" "p1*=0"
D1 = [0,jxa./p3 ; 0,0];
alph1 = kxa./p3;
F1 = [-kz, alph1; 0, 0];
H1 = 1i*[F1 , D1; zero, -F1];

%From left to right goes in the positive a1 direction

H=zeromat;
if T>2
for t=1:T-2
    H(4*t+1:4*t+4,4*t+1:4*t+4) = H0;
    H(4*(t-1)+1:4*(t-1)+4,4*t+1:4*t+4) = H1';
    H(4*(t+1)+1:4*(t+1)+4,4*t+1:4*t+4) = H1;
end
end
H(1:4,1:4) = H0;
if T>1
    H(4*(T-1)+1:4*(T-1)+4,4*(T-1)+1:4*(T-1)+4) = H0;
    H(5:8,1:4) = H1;
    H(4*(T-2)+1:4*(T-2)+4,4*(T-1)+1:4*(T-1)+4) = H1';
end

if T==1
    if pbc == true 
        H = H0 + H1 + H1';
    else
        H = H0;
    end
end

%Periodic B.C.'s?
if pbc == true && T>1
    H(4*(T-1)+1:4*(T-1)+4,1:4) = H1';
    H(1:4,4*(T-1)+1:4*(T-1)+4) = H1;    
end

%Diagonalize it
[V,D] = eig(H);

%Sort them to ascending eigenvalue order for the first half
[~,II1] = sort(real(diag(D)));
[~,II2] = sort(real(diag(D)),'descend');
fh = 1:(size(H,1)/2);
II = [II2(fh),II1(fh)];    
V = V(:, II);
%en = temp(fh);
        
    %Need to normalize V to get U
U = V./repmat( sqrt(sum(V.*conj(V),1)), [size(V,1),1]);
  
%Store the energies
D2 = U'*H*U;
en = diag(D2);
en2 = en(1:S);
ent = repmat(en2,1,S) + repmat(en2',S,1);
enty(xind+N+1,:,:) = ent;
enty2(xind+N+1,:) = en2;
 
 
%Compute Raman operators
%Note that we are making frequent use of methods added
%manually to the cell data type to allow arithmetic on them
%This is convenient because the different polarization combinations are
%stored in cell space (making for fewer matrix/tensor indices).
jxa = jx; jxb = jx; jya = jy; jyb = jy;
jxac = jxa*hxa; jxbc = jxa*hxb; jyac = jya*hya; 
jybc = jya*hyb; jzc = jz*hz; 
for n =1:nm
RD = [jzc{n},(jyac{n} + jxac{n}.*p1)./p3 ;
      (jxbc{n} + jybc{n}.*p2)./p3,jzc{n}];
R0 = 1i*[zero , RD; -RD', zero]; 

RD1 = [0,jxa./p3 ; 0,0];
R1 = 1i*[zero , RD1; zero, zero]; 

R=zeromat;
if T>2
for t=1:T-2
    R(4*t+1:4*t+4,4*t+1:4*t+4) = R0;
    R(4*(t-1)+1:4*(t-1)+4,4*t+1:4*t+4) = R1';
    R(4*(t+1)+1:4*(t+1)+4,4*t+1:4*t+4) = R1;
end
end
R(1:4,1:4) = R0;
if T>1
    R(4*(T-1)+1:4*(T-1)+4,4*(T-1)+1:4*(T-1)+4) = R0;
    R(5:8,1:4) = R1;
    R(4*(T-2)+1:4*(T-2)+4,4*(T-1)+1:4*(T-1)+4) = R1';
end

%Periodic B.C.'s?
if pbc == true && T>1
    R(4*(T-1)+1:4*(T-1)+4,1:4) = R1';
    R(1:4,4*(T-1)+1:4*(T-1)+4) = R1;    
end
RRR{n} = R;
end
RR = U'*RRR*U;


    if emax/2 < max(en2)
        disp([max(en2),emax,jx,jz])
    end
    %Check that the energies are positive
    [me,f]=min(en2);
    if me<0
        disp([me,f,jx,jz])
    end

%Take out the relevant chunks of the Raman operator (SC terms)
for n=1:nm
    RRr{n} = RR{n}(S+1:M,1:S);
end
    
%The six binary combinations from above.
for m =1:mm;
    W{m}(xind+N+1,:,:) = pi*real(conj(RRr{m1{m}}).*RRr{m2{m}} ...
        + conj(RRr{m2{m}}).*RRr{m1{m}});
end

else %If sn<0 then the energy is put in as -1.
     enty(xind+N+1,:,:) = -ones(S);
     enty2(xind+N+1,:) = -ones(S,1);
end
    end
    
    if sum(sum(sum(sum(enty>0))))>0
    %We histogram for each kx-loop 
    [histw, histv] = histwv(2*enty(enty>0),W{1}(enty>0),0,emax,bins);
    Dd = Dd + histv;
    I{1} = I{1} + histw;
    
    if mm>1
    for m=2:mm
    [histw, ~] = histwv(2*enty(enty>0),W{m}(enty>0),0,emax,bins);
    I{m} = I{m} + histw;
    end
    end
        
    %Store the one-particle DOS as well
    [~, histv] = histwv(enty2(enty2>0),0*enty2(enty2>0),0,emax/4,bins);
    Ddd = Ddd + histv;
    
    zeroes = zeroes + sum(sum(sum(sum(enty2==0))));
    
    end
end

%Normalize the results (takes care of infinitesimal volume element and size
%of actual BZ within the square that was sampled)
ddd = sum(Ddd)*emax/bins *1/4;
disp(sum(Ddd)/(4*T*(2*N)^2))
disp(zeroes/(4*T*(2*N)^2))
disp(count/(T*(2*N)^2))
Ddd = Ddd./ddd;
Dd = Dd./(ddd);
I = I./(ddd);

out = cell(1,3+mm);

out{1} = Ev;
out{2} = Dd;
out{3} = Ddd;
for m=4:(3+mm)
    out{m} = I{m-3};
end

%Note that Intensity should be plotted against Ev while DOS against Ev/2
%(otherwise it is the two-particle DOS

end