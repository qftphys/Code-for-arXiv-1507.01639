function out = KitaevRaman14_8_ac_blah(N,bins,flag,nn,jx,jz,h)
%This function was written by Brent Perreault
%The basic Hamiltonian can be compared with EK Lee et al. arXiv:1308.6592v2


%output form: out = [Ev,DEp,DEm,DE,Ipp,Imm,Ipm]

% Ev   Energy bins for Raman Intensity. The appropriate bins for DOS are Ev/2
% DEp  Density of states for the upper band
% DEm  DOS for lower band
% DE   Total Density of states
% Ipp  Raman Intensity for two spinons in the upper band
% Imm  Raman intensity for two spinons in the lower band
% Ipm  Raman intensity for two spinons, one from each band

%additional output:
%Time taken so far, and estimated end time
%Plot of the densitiy of states (commented out for now)

%input-parameters:

% 2*N    the number of points in a dimension (2*N ~ 100 takes minutes)
% flag   a boolean telling whether to estimate time on this run
% nn     the number of times that you plan to do a similar calculation (for error estimation) 
% type   a string specifying which Raman operator
% Jx     the value of J_x/J_z , where J_y = J_x
% bins   number of bins on the energy axis (~2*N is a good choice)


%Initial data

%the max energy for the energy axis
emax = 4*(2*jx+jz) + 8*h;

%The values of the Kitaev couplings
jy = jx;  %Jy is always same as Jx
%jxa=jx; jya=jy; jxb=jx; jyb=jy;
%Jz = 1; 
    %The 'kappa' terms characterizing the B-field term
kxa=h; kxb=h; kya=h; kyb=h; kza=h; kzb = h;


jxa=jx; jya=jy; jxb=jx; jyb=jy;

%A convenient notation
L=2*N;

%Initialization of Arrays

Ev = (1:bins)'*emax/bins;


randy=0.14;
r1 = randy; r2 = randy; r3 = randy;


pts = (-N):(N-1);
%We treat x and y values as corresponding to column and row values respectively
y=repmat((pts+r1)/N,L,1)*pi/sqrt(2);
z=repmat((pts.' + r3)/N,1,L)*pi/3;


a1 = [-1,-sqrt(2),0];
a2 = [-1,sqrt(2),0]; 
a3 = [-1,0,3];

%The six are the six symmetric binary products of R^aa, R^ac, R^cc
    %h1 = {aa, aa, aa, ac, ac, cc, ab, bc,[ac],[bc]};
    %h2 = {aa, ac, cc, ac, cc, cc, ab, bc,[ac],[bc]};
m1 = {1,1,1,3,3,5,2,4,6,7,6,6,4,4,4,4,5};
m2 = {1,3,5,3,5,5,2,4,6,7,7,3,1,2,3,5,1};
mm = size(m1,2);

%The different terms given a certain combination
%{aa,ab,ac,bc,cc,[ac],[bc]}
hxa = {1,-sqrt(2), 1,-sqrt(2),1,0,0}./4;
hya = {1,-sqrt(2),-1, sqrt(2),1,0,0}./4;
hxb = {1, sqrt(2), 1, sqrt(2),1,0,0}./4;
hyb = {1, sqrt(2),-1,-sqrt(2),1,0,0}./4;
hz =  {0,0,0,0               ,1,0,0};
nm = size(hz,2);

kzac = -1i*{0,0,0,0,0,1,1};
kzbc = -1i*{0,0,0,0,0,-1,1};
kxac = -1i*{0,0,0,0,0,1,1};
kxbc = -1i*{0,0,0,0,0,-1,1};
kyac = -1i*{0,0,0,0,0,1,1};
kybc = -1i*{0,0,0,0,0,-1,1};

%Initializtion
U=zeros(L,L,4,4); 
H=U; D=U;
vm=zeros(L,L,4);
vp=vm; vm2=vm; vp2=vm;

gamma = zeros(size(U));
one = ones(L);
gamma(:,:,1,3) = one;
gamma(:,:,2,4) = one;
gamma(:,:,3,1) = one;
gamma(:,:,4,2) = one;

R = cell(1,nm); R2=R;
for n=1:nm
    R{n} = U;
    R2{n} = U;
end

Ipp = cell(1,mm); Imm = Ipp; Ipm = Ipp;
%Dpp = Ipp; Dpm = Ipp; Dmm = Ipp;
zerolist = zeros(size(Ev));
for m=1:mm
    Ipp{m} = zerolist;  
    Imm{m} = zerolist;  
    Ipm{m} = zerolist;  
end
Dpp = zerolist;
Dmm = zerolist;
Dpm = zerolist;

%Wpp = cell(1,mm);
%Wmm = Wpp; Wpm = Wpp;

%Z counts the number of k-points falling withing the actual BZ (volume of BZ)
Z=0;

    %Now I do arithmetic as if x,y, and z were numbers but with x and a
    %matrices and doing only elementwise operations with them.
    
    %I only store values for a given y and then reduce the information into
    %a histogram before looping back to keep from overloading the memory
    
    %My computer handles about 2 to 5 * 10^8 doubles at once in memory so I
    %expect this code to max out the memory around N~3000
for ind = pts
    x = (ind + r2)*29*pi/(36*N);
        
    
    %I display an estimate of the end time
    aleph = 1 + round( (70/N)^2 ); %iterations for ~1 second of computation, or one iteration, which ever takes longer
    %Or an iteration, which ever is longer
    if (ind == -N+2) && flag   %the first few may be slower due to initialization, start from the third one
        cl1 = clock; 
    end
    if (ind == -N+2+aleph) && flag
        cl2 = clock;
        time = (cl2-cl1)*(2*N)/aleph*nn;
        %cl = cl1 + time*(2*N-2)/(2*N);
        
        format shortg
        disp('approximate time to take:')
        disp( datestr(time(6)/24/3600, 'DD-HH:MM:SS') )
        format
    end
        
        
    %Only values above the line below are in the BZ (which is part of the
    %rectangle I have created in x,y,z space.
    %If this value is not positive I negate the energies out of the hist
    sn = sign( 29*pi/(36) - abs(x) - abs(y)/sqrt(2) - abs(z)/3 );
     
    p1 = exp(1i*(x*a1(1)+y*a1(2)+z*a1(3))); 
    p2 = exp(1i*(x*a2(1)+y*a2(2)+z*a2(3))); 
    p3 = exp(1i*(x*a3(1)+y*a3(2)+z*a3(3)));

    A = (jxa + jya.*p1)./p3;
    B = (jxb + jyb.*p2);
    d = -kyb + kya./(p3) + kxb./p2  + kxa*p1./p3;%ky*(1-p2) + kx*(p2-p3);%%%%%%%%%%
    a = kza*( p1 - conj(p1) );%%%%%%%%%%%%
    b = -kzb*( p2 - conj(p2) );%%%%%%%%%%%%%%%
    
  %  DD = [jz,(jxa + jya.*p1)./p3 ;     (jxb + jyb.*p2),jz];

    
    %delta = ky + kx*p2 - ky*p1 - kx*p3 - kz*p3 + kz*conj(p3);   
    
    %Call the script that creates H and diagonalizes it giving U, U2 (for
    %-k) and the diagonal energy matrix D.
%    if h == 0
%        diag3D15h0;
%    else
        diag3D15;
        
        
%      A = (jxa + jya.*p1)./p3;
%     B = (jxb + jyb.*p2);
%     d = -kyb + kya/(p3) + kxb/p2  + kxa*p1/p3;%ky*(1-p2) + kx*(p2-p3);%%%%%%%%%%
%     a = kza*( p1 - conj(p1) );%%%%%%%%%%%%
%     b = -kzb*( p2 - conj(p2) );%%%%%%%%%%%%%%%
    
jxac = jxa*hxa; jxbc = jxa*hxb; jyac = jya*hya; 
jybc = jya*hyb; jzc = jz*hz; 
    
    %Raman operators (They are nm deep in cell space)
    Ac = (jxac + jyac*p1)./p3;
    Bc = (jxbc + jybc.*p2);
    dc = -kybc + kyac./(p3) + kxbc./p2  + kxac*p1./p3;
    ac = kzac*( p1 - conj(p1) ); 
    bc = -kzbc*( p2 - conj(p2) );
    
    for n=1:nm
        R{n}(:,:,1,1) = 1i*(ac{n}-bc{n}-2i*jzc{n});
        R{n}(:,:,1,2) = Ac{n}+conj(Bc{n});
        R{n}(:,:,1,3) = 1i*(ac{n}+bc{n});
        R{n}(:,:,1,4) = -Ac{n}+2i*dc{n}+conj(Bc{n});

        R{n}(:,:,2,1) = Bc{n}+conj(Ac{n});
        R{n}(:,:,2,2) = -1i*(ac{n}-bc{n}+2i*jzc{n});
        R{n}(:,:,2,3) = -Bc{n}+conj(Ac{n})-2i*conj(dc{n});
        R{n}(:,:,2,4) = 1i*(ac{n}+bc{n});
        
        R{n}(:,:,3,1) = 1i*(ac{n}+bc{n});
        R{n}(:,:,3,2) = Ac{n}+2i*dc{n}-conj(Bc{n}); 
        R{n}(:,:,3,3) = 1i*(ac{n}-bc{n}+2i*jzc{n});
        R{n}(:,:,3,4) = -Ac{n}-conj(Bc{n});   
        
        R{n}(:,:,4,1) = Bc{n}-conj(Ac{n})-2i*conj(dc{n});
        R{n}(:,:,4,2) = 1i*(ac{n}+bc{n}); 
        R{n}(:,:,4,3) = -Bc{n}-conj(Ac{n});
        R{n}(:,:,4,4) = 1i*(-ac{n}+bc{n}+2i*jzc{n});  
        
        
        %Now take -k
%         R2{n} = conj(R{n});
%         R2{n}(:,:,4,1) = -Ac{n}+2i*delta{n}+conj(Bc{n}); 
%         R2{n}(:,:,3,2) = conj(Ac{n})-2i*conj(deltac{n})-Bc{n};
%         R2{n}(:,:,1,4) = conj( -Ac{n}+2i*deltac{n}+conj(Bc{n}) ); 
%         R2{n}(:,:,2,3) = conj( conj(Ac{n})-2i*conj(deltac{n})-Bc{n} );
        
        R{n}  = R{n}/2;
        %R2{n} = R2{n}/4;
    end
        
    %Finding R in diagonal space (of H), call it RR
    RR = mult4( permute(conj(U),[1 2 4 3]) , mult4(R,U) ); 
    %RR2 = mult4( permute(conj(U2),[1 2 4 3]) , mult4(R2,U2) ); 
    D2 = mult4( permute(conj(U),[1 2 4 3]) , mult4(H,U) );
    Errs = abs(D2 - D);
    err = max(max(max(max(Errs))));
    if err>10^(-6)
        disp(err)
    end
    
%     The following check is not the requirement - need to implement -k in one of them, turns out U = conj(u2) 
%     Errs2 = abs(U2 - U);
%     err2 = max(max(max(max(Errs2))));
%     if err2>10^(-6)
%         disp(err2)
%     end
    
    if emax/2 < max(ep,em)
        disp([ep,emax,Jx,Jz])
    end
    
    %The six binary combinations from above.
    for m=1:mm
                %Store the relevant information
        Wmm = pi*real(conj(RR{m1{m}}(:,:,3,1)).*RR{m2{m}}(:,:,3,1) ...
                + conj(RR{m2{m}}(:,:,3,1)).*RR{m1{m}}(:,:,3,1));  %These are right now, but not in earlier versions (mm <-> pp)
        Wpp = pi*real(conj(RR{m1{m}}(:,:,4,2)).*RR{m2{m}}(:,:,4,2) ... 
                + conj(RR{m2{m}}(:,:,4,2)).*RR{m1{m}}(:,:,4,2));
        Wpm = pi*real(conj(RR{m1{m}}(:,:,4,1).*RR{m2{m}}(:,:,4,1))...
                +conj(RR{m2{m}}(:,:,4,1)).*RR{m1{m}}(:,:,4,1) ...
                        + conj(RR{m1{m}}(:,:,3,2)).*RR{m2{m}}(:,:,3,2) ...
                    + conj(RR{m2{m}}(:,:,3,2)).*RR{m1{m}}(:,:,3,2) );
                    
            %disp(max(max(2*ep(sn>=0))))
   
        %Histogram it
        [histw, histv] = histwv(4*ep(sn>=0),Wpp(sn>=0),0,emax,bins);
        Ipp{m} = Ipp{m} + histw;
        Dpp = Dpp + histv;

        [histw, histv] = histwv(4*em(sn>=0),Wmm(sn>=0),0,emax,bins);
        Imm{m} = Imm{m} + histw;
        Dmm = Dmm + histv;

        [histw, histv] = histwv(2*ep(sn>=0)+2*em(sn>=0),Wpm(sn>=0),0,emax,bins);
        Ipm{m} = Ipm{m} + histw;
        Dpm  = Dpm  + histv;
    end
      
    %Add one to the number of BZ points counted if the point is indeed in
    %the BZ
    Z=Z+size(sn(sn(:)>=0),1);
    %Z should approximately be 18/29*L^3;
end

%Normalize the results by the BZ volume
ddd = sum(Dmm)*(emax)/bins;

Dpp=Dpp./ddd;
Dmm=Dmm./ddd;
Dpm =Dpm./ddd;
%Note: the 1-particles DOS is D = 2*(Dmm+Dpp) on Ev/2, which will integrate to 2. 
%1 = 2*sum(Dmm)*(Ev(max)/2)/bins = sum(Dmm)*(Ev(max))/bins 

Ipp=Ipp./ddd;
Ipm=Ipm./ddd;
Imm=Imm./ddd;

% Dpp=Dpp*bins./(Z*emax*mm );
% Dmm=Dmm*bins./(Z*emax*mm );
% Dpm =Dpm *bins./(Z*emax*mm );
% 
% Ipp=Ipp*bins./(Z*2*emax*mm );
% Ipm=Ipm*bins./(Z*2*emax*mm );
% Imm=Imm*bins./(Z*2*emax*mm );

out = cell(1,10);

out{1} = Ev;
out{2} = Dpp+Dmm;
out{3} = Dpp + Dmm + 2*Dpm;
for m=1:mm
    out{m+3} = Ipp{m}+Imm{m}+2*Ipm{m};
end

%Note that Intensity should be plotted against Ev while DOS against Ev/2
%(otherwise it is the two-particle DOS

%DEp(1)=0; DEm(1)=0;

% Plot
% figure;
% hold on;
% plot(Ev,Ipp,Ev,Imm,Ev,Ipm,Ev,Ipp+Imm+Ipm);
% title(['Raman Spectrum for HyperHoneycomb Kitaev spinons: bins = ',num2str(bins),', N= ',num2str(N)])
% xlabel('E');
% ylabel('I(E)');
% hold off;