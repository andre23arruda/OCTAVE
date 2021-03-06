function [ordem,maxcriterio]= SelecaoVetorial(metodo,criterio,classes,n)

% Autor: André Luiz Costa de Arruda

% Seleciona caracteristicas baseando-se nas Scatter Matrices (seleção vetorial)

% INPUT:
%   classes = célula {1 x numero de classes}
%   classes{i}= matriz L x N (características x padrões) para a classe i
%   metodo='forward','exaustivo' ou 'floating'
%   criterio= 'J1','J2','J3' (de acordo com Theodoridis)
%   n = numero de caracteristicas para selecionar

% OUTPUT:
%   maxcriterio=valor do criterio para a seleção
%   ordem = ordem das caracteristicas de acordo com o criterio escolhido
%% AGC (atualizado semestre 2/2017). Editado por ALCA (09/12/17)

    %% TESTE DOS INPUTS:
    L=size(classes{1},1);
    C=length(classes);
    for i=2:1:C;
        if size(classes{i},1)~=L
            error('Todas classes devem ter o mesmo número de características');
        end
    end
    if round(n)~=n
        error('n deve ser inteiro e positivo');
    else
        if n==1
            error('Chame a seleção escalar para n =1');
        elseif n<0
            error('n deve ser inteiro e positivo');
        elseif n>=L
            error('n deve ser menor que o número de características');
        end
    end
   

    
    
    switch metodo
        case 'exaustivo'
            [ordem,maxcriterio]= exaustsel(classes,n,criterio);

        case 'forward'
             [ordem,maxcriterio]= forwardsel(classes,n,criterio);

        case 'floating'
             [ordem,maxcriterio]=floatingsel(classes,n,criterio);
    end
end


function classes_sub=construirclasses(classes,caracteristicas)
         classes_sub=cell(1,length(classes));
         for c=1:1:length(classes)
             classes_sub{c}=classes{c}(caracteristicas,:);
         end
            
end

        
function [caractsel,valor]=exaustsel(classes,n,criterio)
    [J1,J2,J3,combinacoes]= espalhamento(classes,n);
     eval(['caractsel=combinacoes(find(',criterio,'==max(',criterio,')),:);']);
     eval(['valor=max(',criterio,');']);
end

        

function [caractsel,custo]=forwardsel(classes,n,criterio)    
     caractsel=[];
     remaining=1:1:size(classes{1},1);    
     [J1,J2,J3,combinacoes]= espalhamento(classes,1);
     eval(['caractsel=combinacoes(find(',criterio,'==max(',criterio,')),:);']);
     eval(['custo=max(',criterio,');'])
     remaining(caractsel)=[];
     for j=2:n
         valor=-Inf;
         escolhida=0;
         for k=1:1:length(remaining)
             testaressas=[caractsel,remaining(k)];
             [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,testaressas),numel(testaressas));
             eval(['teste=',criterio,';'])
             if teste>valor
                 eval(['valor=',criterio,';']);
                 escolhida=k;
             end
         end
         caractsel(end+1)=remaining(escolhida);
         remaining(escolhida)=[];
         custo=valor;
     end

end




function [caractsel,valor]=floatingsel(classes,n,criterio)    
     
    %INICIALIZAÇÃO
    k=2;
    m=size(classes{1},1);
    [X{2},C{2}]=forwardsel(classes,2,criterio);
    
    while k<=n
        %STEP 1:        
        custo=[];
        Y{m-k}=setdiff(1:m,X{k});
        for i=1:length(Y{m-k})
            testaressas=[X{k} Y{m-k}(i)];
            [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,testaressas),numel(testaressas));
            eval(['custo=[custo ',criterio,'];']);
        end
        [maxcusto,ind]=max(custo);
        X{k+1}=[X{k} Y{m-k}(ind)]; %adiciona a caracteristica que maximiza o custo      
        
        %STEP 2:
        custo=[];
        for i=1:length(X{k+1})
            testaressas=setdiff(X{k+1}, X{k+1}(i));
            [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,testaressas),numel(testaressas));
            eval(['custo=[custo ',criterio,'];']);
        end
        [maxcusto,r]=max(custo);
        xr=X{k+1}(r); %caracteristica menos relevante     
        if r==k+1 %é a caracteristica que foi adicionada: continua sem remove-la
            [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,X{k+1}),numel(X{k+1}));
             eval(['C{k+1}=',criterio,';']);
            k=k+1;
            continue;
        end
        if r~=k+1 &  maxcusto< C{k} %é uma caracteristica anterior mas a remocao dela não aumenta o custo
            continue;
        end
        if k==2 %nesse caso, r=1 ou 2 e maxcusto>C{k}: troca X{k} pelo par melhor e começa de novo (só está aqui pq no algoritmo de Theodoridis a inicialização com forward não é otimizada como a minha, no meu caso isso nunca acontece)
            X{k}=setdiff(X{k+1},xr);
            C{k}=maxcusto;
            continue;
        end
        
         
        %STEP 3: só vem nesse passo se r~=k+1 e maxcusto>=C{k}: vale a pena
        %remover
        go=1;
        while go
            Xlinha{k}=setdiff(X{k+1},xr); %remove xr, Xlinha é o novo conjunto
            custo=[];
            for i=1:length(Xlinha{k})
                 testaressas=setdiff(Xlinha{k}, Xlinha{k}(i));
                 [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,testaressas),numel(testaressas));
                  eval(['custo=[custo ',criterio,'];']);
            end
            [maxcusto,s]=max(custo);
            xs=Xlinha{k}(s); %caracteristica menos relevante no novo conjunto
            if maxcusto<C{k-1} %remocao de xs baixa o custo, então fica com o Xlinha 
                X{k}=Xlinha{k};
                [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,X{k}),numel(X{k}));
                eval(['C{k}=',criterio,';']); 
                go=0;
                break;
            end
            %se está aqui a remocao de xs aumenta o custo
            Xlinha{k-1}=setdiff(Xlinha{k},xs); %remove xs e dá um passo para trás
            k=k-1;
            if k==2
                X{k}=Xlinha{k};
                [J1,J2,J3,combinacoes]= espalhamento(construirclasses(classes,X{k}),numel(X{k}));
                eval(['C{k}=',criterio,';']);                 
                go=0;
            end
        end
        if go==0
            continue;
        end
    end
    if k>n
        caractsel=X{k-1};
        valor=C{k-1};
    else
        caractsel=X{k-1};
        valor=C{k-1};
    end


end




