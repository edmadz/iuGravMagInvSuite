function output = generateNaNmask(input)

input(~isnan(input))=1;

output=input;