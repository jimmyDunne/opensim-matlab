function fileNames = getPath2Files(fileList,conditions)


fileNames = [];
for  i = 1 : length(fileList)

    if     ~isempty(strfind(fileList{i},conditions{1})) ...
        && ~isempty(strfind(fileList{i},conditions{2}))...
        && ~isempty(strfind(fileList{i},conditions{3}))...
        && ~isempty(strfind(fileList{i},conditions{4}))...
        && ~isempty(strfind(fileList{i},conditions{5}));

        fileNames = [fileNames;fileList(i)];

    end
end