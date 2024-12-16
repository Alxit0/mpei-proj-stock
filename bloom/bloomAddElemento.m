function filtro =  bloomAddElemento(filtro,chave,k)
    for i=1:k
        chave= [chave num2str(i)];
        code = mod(string2hash_aux(chave, k),length(filtro))+1;
        filtro(code)=1;
        
    end
end