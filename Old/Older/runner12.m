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


% Now we repeat the first example but do not need to include anything
% special beyond manually specifying the tick marks.
% f = @(x) x.^2;
% g = @(x) 5*sin(x)+5;
% dmn = -pi:0.001:pi;
% xeq = dmn(abs(f(dmn) - g(dmn)) < 0.002);
% 
% figure(1); clf;
% plot(dmn,f(dmn),'b-',dmn,g(dmn),'r--',xeq,f(xeq),'g*');
% xlim([-pi pi]);
% legend({'f(x)', 'g(x)', 'f(x)=g(x)'}, 'Location', 'SouthEast'...
%     );%,'Interpreter','latex');
% xlabel('x');
% ylabel('I(E)');
% title('Automatic Example Figure');
% set(gca,'XTick',-3:3); 
% set(gca,'YTick',2*(0:5));


%run code to make plots

%for Jxx = [0,.3,1.43]
   % runit12(Jxx,0);
%end

%I0 = runit12(1,0);
%I3 = runit12(.3,0);
%I4 = runit12(1.43,0);

Ih01 = runit12(1,.01);
Ih03 = runit12(1,.03);
Ih1  = runit12(1,.1);

Ev = 2:30;
hh=figure;%('Position',position);
hold on;
plot(log(I0{8}(Ev)),log(I0{4}(Ev)),log(Ih01{8}(Ev)),log(Ih01{4}(Ev)),log(Ih03{8}(Ev)),log(Ih03{4}(Ev)),log(Ih1{8}(Ev)),log(Ih1{4}(Ev)) );
%errorbar(Ev,Ipp+Imm+Ipm,errs(:,4)+errs(:,5)+errs(:,6));
title(['Raman Spectrum for HyperHoneycomb spinons: h-field comparison (log plot)'])
xlabel('log(\omega/J)');
ylabel('log(I_{ac})');
legend({'h=0','h=0.01','h=0.03','h=0.1'}, 'Location', 'SouthEast');
hold off;
filename = ['3D_Raman_10^7_magneticfield'];
savefig(filename)
print(hh, '-dpng', filename);


diary 3D_Raman_diary
