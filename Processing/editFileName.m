function editedName = editFileName(name,modifier)

str_ = strsplit(name,'.');
format = cell2mat(str_(end));

str_2 = str_(1:end-1);
str_2 = char(strjoin(str_2,'.'));

editedName = strcat(str_2,modifier,'.',format);

end