function rootPath = cboxRootPath()
% Return the path to the root iset directory
%
% This function must reside in the directory at the base of the directory
% structure.  It is used to determine the location of various
% sub-directories.
% 
% Example:
%   fullfile(cboxRootPath,'data')

rootPath=which('cboxRootPath');

rootPath =fileparts(rootPath);

end
