function result = checkElemento(filtro,chave,k)
    result=true;
    for i= 1:k
        chave= [chave num2str(i)];
        code = mod(string2hash(chave),length(filtro))+1;
        if filtro(code)==0
            result=false;
            break
        end
    end
end