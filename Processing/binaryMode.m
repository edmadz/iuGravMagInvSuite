function colors = binaryMode(input)

if(max(max(input))>1)
    input = input./255;
end

colors = input;