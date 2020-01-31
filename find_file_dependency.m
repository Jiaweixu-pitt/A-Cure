% find file dependency
fList = matlab.codetools.requiredFilesAndProducts('IP_EF_SRMSE.m');

filePh = fopen('dependency.txt','w');
fprintf(filePh,'%s\n',fList{:});
fclose(filePh);
