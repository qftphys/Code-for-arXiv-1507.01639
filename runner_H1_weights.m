%The first part of this code sets defaults for the plots to look good
%The second part runs code to make plots.

%initial data
width = 5.1;     % Width in inches
height = 3;    % Height in inches
alw = 1;       % AxesLineWidth
fsz = 14;      % Fontsize
fna = 'Helvetica'; %Fontname
lw = 1.5;      % LineWidth
msz = 8;       % MarkerSize
interp = 'tex';

%pixs = get(0,'screensize');
%width = pixs(3)/2; height = pixs(4)/2-50;

%Close the figures
close all;

% The properties we've been using in the figures
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz
set(0,'defaultLineLineWidth',lw);   % set the default line width to lw
set(0,'defaultLineMarkerSize',msz); % set the default line marker size to msz

set(0,'defaultAxesFontName',fna);
set(0,'defaultAxesFontSize',fsz);
set(0,'defaultTextInterpreter',interp);

% Set the default Size for display
defpos = get(0,'defaultFigurePosition');
set(0,'defaultFigurePosition', [defpos(1) defpos(2) width*100, height*100]);

% Set the defaults for saving/printing to a file
set(0,'defaultFigureInvertHardcopy','on'); % This is the default anyway
set(0,'defaultFigurePaperUnits','inches'); % This is the default anyway
defsize = get(gcf, 'PaperSize');
left = (defsize(1)- width)/2;
bottom = (defsize(2)- height)/2;
defsize = [left, bottom, width, height];
set(0, 'defaultFigurePaperPosition', defsize);


%run code to make plots

%for Jxx = [0,.3,1.43]
   % runit14(Jxx,0);
%end
did = 0:20; s1=did;s4=did;s7=did;Jx =did;th2=did;
for n = (1:21);
    th = (n-1)*pi/40; th2(n)=th*2/pi;
    Jxx = 3*tan(th)/(1+2*tan(th));
    Jzz = 3/(1+2*tan(th));
    Jx(n) = Jxx;
    Jz(n) = Jzz;    
   
    IH20_2 = runit_H1_r_2(Jxx,Jzz,0,0);
    Ev = IH20_2{10};
    Jav = (Jzz+2*Jxx)/3;
    dE = Ev(200)/(200);
    
    s1(n) = sum(IH20_2{1})*dE;
    s4(n) = sum(IH20_2{4})*dE;
    s7(n) = sum(IH20_2{7})*dE;
end
% I3 = runit14(.3,0);
% I4 = runit14(1.43,0);
% 
% Ih01 = runit14(1,.01);
% Ih03 = runit14(1,.03);
% Ih1  = runit14(1,.1);

%Ev = 2:18;
hh=figure;%('Position',position);
hold on;
plot(th2,s1,th2,s4,th2,s7);
%errorbar(Ev,Ipp+Imm+Ipm,errs(:,4)+errs(:,5)+errs(:,6));
title(['Raman Spectral Weights for H1 spinons \kappa=0'])
xlabel('(2/\pi)arctan(J_x/J_{av})');
ylabel('Spectral Weight');
legend({'I_{aa}','I_{ac}','I_{ab}'}, 'Location', 'NorthWest');
hold off;
filename = ['H1_Raman_weights'];
saveas(hh,filename)
print(hh, '-dpng', filename);



diary H1_Raman_weights_diary
