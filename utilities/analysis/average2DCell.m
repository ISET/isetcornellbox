function meanCell = average2DCell(data, dim)

%%
if dim == 2
    data = data';
end
meanCell = cell(1, size(data, 2));


%%
for ii = 1:size(data, 2)
    tmp = zeros(size(data{1, 1}));
    for jj = 1:size(data, 1)
        tmp = tmp + data{jj, ii};
    end
    meanCell{ii} = tmp / size(data, 1);
end
%%

end