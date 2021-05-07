%% Charts for EI sensor noise
%
% Check the table for the SD of the Green channel in the middle position
% (2). 
%

%% Measured noise at Stanford

mnSimulated = [234, 141, 84.6;
    432, 552, 211;
    120, 201, 97.1];

mnMeasured = [234,139,80.7;
    450, 550,206;
    118,195,94.1];

%%
ieNewGraphWin;
h = plot(mnSimulated(:),mnMeasured(:),'ko','MarkerSize',10);
set(h,'MarkerFaceColor', get(h,'Color'));
grid on;
identityLine;
xlabel('Simulated mean (digital value)'); ylabel('Measured mean (digital value)')

%%
ieNewGraphWin;
histogram(mnSimulated(:) - mnMeasured(:));

%%  Figure out if we want a nice bar plot

ieNewGraphWin;
bar(mnMeasured);
bar(mnSimulated);

%%
sdSimulated = [11.3, 5.84, 2.78;
    17.4, 22.5, 8.25;
    4.14, 7.59, 3.14];

sdMeasured = [8.27, 5.45,1.77;
    14.8, 18.4, 6.63;
    3.87,7.76, 2.60];

%%
ieNewGraphWin
plot(mnMeasured(:),sdMeasured(:),'ro','MarkerSize',10,'LineWidth',3)
hold on
plot(mnSimulated(:),sdSimulated(:),'ks','MarkerSize',10,'LineWidth',3);
grid on;
xlabel('Mean (digital value)'); ylabel('SD (digital value)');
legend('Measured','Simulated');
title('Stanford estimates')

%%
ieNewGraphWin;
plot(sdSimulated(:),sdMeasured(:),'o');
grid on;
identityLine;
xlabel('Simulated (sd, digital value)'); ylabel('Measured (sd, digital value)')

histogram(sdSimulated(:) - sdMeasured(:))

%%  Measured noise at Google estimates

% TO CHECK:  Are these numbers the same ones as Zheng has!!!
sdSimulated = [10.3, 5.45, 2.31;
    16.2, 20.8, 7.77;
    3.86, 7.95, 2.75];

sdMeasured = [8.27, 5.45,1.77;
    14.8,18.4,6.63;
    3.87,7.76,2.60];

%%
ieNewGraphWin
h = plot(mnMeasured(:),sdMeasured(:),'ro','MarkerSize',10,'LineWidth',3)
set(h,'MarkerFaceColor', get(h,'Color'));
hold on
h = plot(mnSimulated(:),sdSimulated(:),'ks','MarkerSize',10,'LineWidth',3);
set(h,'MarkerFaceColor', get(h,'Color'));
grid on;
xlabel('Mean (digital value)'); ylabel('SD (digital value)');
legend('Measured','Simulated');
title('Google estimates')

%%
ieNewGraphWin
plot(mnMeasured(:),sdMeasured(:),'ro',mnSimulated(:),sdSimulated(:),'ks')
grid on;

%%
ieNewGraphWin;
h = plot(sdSimulated(:),sdMeasured(:),'ks','MarkerSize',10,'LineWidth',3);
set(h,'MarkerFaceColor', get(h,'Color'));

grid on;
identityLine;
xlabel('Simulated (sd, digital value)'); ylabel('Measured (sd, digital value)')
%%
histogram(sdSimulated(:) - sdMeasured(:))

