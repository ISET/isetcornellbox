function cbMccPredEval(varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('measurement',[], @ismatrix);
p.addParameter('prediction',[], @ismatrix);
p.parse(varargin{:});
rgbMeanS = p.Results.prediction;
rgbMeanR = p.Results.measurement;

%% Initialization
colorList = ['r', 'g', 'b'];

%% Global comparison
ieNewGraphWin;
for ii = 1:3
plot(rgbMeanS(:,ii), rgbMeanR(:,ii), strcat(colorList(ii), 'o')); hold on;
end
identityLine;
axis square
axis equal
xlabel('prediction')
ylabel('measurement')

%% Get sample size
szS = size(rgbMeanS, 1);
%% Block by block check
ieNewGraphWin;
for ii=1:24
    subplot(6, 4, ii);
    hold all
    for jj=1:3
        plot(rgbMeanS(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'o'));
    end
    title(sprintf('Illuminant A-patch: %d', ii))
    xlabel('prediction')
    ylabel('measurement')
    identityLine;
    axis square
    axis equal    
end
if szS > 24
ieNewGraphWin;
for ii=25:48
    subplot(6, 4, ii-24);
    hold all
    for jj=1:3
        plot(rgbMeanS(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), 'x'));
    end
    title(sprintf('Illuminant CWF-patch: %d', ii-24))
    xlabel('prediction')
    ylabel('measurement')
    identityLine;
    axis square
    axis equal    
end
end

if szS > 48
ieNewGraphWin;
for ii=49:72
    subplot(6, 4, ii-48);
    hold all
    for jj=1:3
        plot(rgbMeanS(ii, jj), rgbMeanR(ii, jj), strcat(colorList(jj), '*'));
    end
    title(sprintf('Illuminant Day-patch: %d', ii-48))
    xlabel('prediction')
    ylabel('measurement')
    identityLine;
    axis square
    axis equal    
end
end
end