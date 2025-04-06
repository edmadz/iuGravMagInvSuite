function add2MATLABpath(additionalFilePath)

pcPlatform = computer('arch');
pcPlatform = pcPlatform(1:3);
if(strcmp(pcPlatform,'gln') || strcmp(pcPlatform,'mac'))
    fragmentedPath = strsplit(additionalFilePath,'\');
    fragmentedPath = fragmentedPath(1,2:end);
    n=length(fragmentedPath);
    a='';
    for i=1:n
        a = [a,'/',fragmentedPath{:,i}];
    end
    additionalFilePath = a;
end

rootDirectory = pwd;

newpath = [rootDirectory,additionalFilePath];

oldpath = path;
path(oldpath,newpath)

end