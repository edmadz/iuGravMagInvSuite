function cmap = createCmap(c,percent,num)

N=length(c);
cmap = [NaN,NaN,NaN];

for n=1:N-1
    R = linspace(c(n,1),c(n+1,1),ceil((num*percent(n))/100));
    G = linspace(c(n,2),c(n+1,2),ceil((num*percent(n))/100));
    B = linspace(c(n,3),c(n+1,3),ceil((num*percent(n))/100));
    if(n==N-1)
        cmap = cat(1,cmap,cat(2,R',G',B'));
    else
        cmap = cat(1,cmap,cat(2,R(1:end-1)',G(1:end-1)',B(1:end-1)'));
    end
end

cmap = cmap(2:end,:);