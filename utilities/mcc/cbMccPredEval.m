function cbMccPredEval(varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addParameter('measurement',[], @ismatrix);
p.addParameter('prediction',[], @ismatrix);
p.parse(varargin{:});
rgbMeanS = p.Results.prediction;
rgbMeanR = p.Results.measurement;

%% Global comparison
ieNewGraphWin;
plot(rgbMeanS, rgbMeanR, 'o')
identityLine;
axis square
axis equal
xlabel('prediction')
ylabel('measurement')

%% Block by block check
colorList = ['r', 'g', 'b'];
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