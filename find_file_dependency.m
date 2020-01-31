% find file dependency
fList = matlab.codetools.requiredFilesAndProducts('IP_EF_SRMSE.m');
% onl work for newer version:writecell(fList);
filePh = fopen('dependency.txt','w');
fprintf(filePh,'%s\n',fList{:});
fclose(filePh);