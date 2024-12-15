function out = string2hash_aux(str,k)

    str=double(str);
    hash = 5381; 
    for i=1:size(str,2)
        hash = mod(hash * 33 + str(i), 2^32-1); 
    end
    
    out = zeros(1, k);
    for i = 1:k
        hash = mod(hash * 33 + i, 2^32-1);
        out(i) = hash;
    end

end