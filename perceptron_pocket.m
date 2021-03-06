function [n_i, wp] = perceptron_pocket(m1,m2,max_i,p,plotar)

% Autor: André Luiz Costa de Arruda

% FUNCAO PARA CALCULAR O CLASSIFICADOR PERCEPTRON POCKET
% O Perceptron eh um vetor W em L+1 dimensoes que atribui uma classe Pk ao padrao Xk
% O perceptron pocket não atualiza o vetor perceptron quando o numero de erros d Wi for maior que o erro de Wi-1

%INPUTS: 
%  - m1: matriz com os dados da classe 1
%  - m2: matriz com os dados da classe 2
%  - max_i: numero maximo de iteracores a serem realizadas
%  - p: parametro de aprendizado do classificador
%  - plotar: se diferente de 1, plota a ultima iteracao, senão, faz uma
%            animação daora
  
%OUTPUTS:
%  - n_i: numero de iteracoes realizadas para obter a convergencia
%  - w = perceptron
  
L = size(m1,1); % numero de caracteristicas dos dados da classe 1
N1 = size(m1,2); % numero de padroes dos dados da classe 1
N2 = size(m2,2); % numero de padroes dos dados da classe 2

if(L ~= size(m2,1)) % se o numero de caracteristicas das classes for diferente
  error('Numero de caracteristicas diferentes');
else
  if nargin < 5
      plotar = 0;
  end
  m1(end+1,:) = 1; % colocando 1 no vetor
  m2(end+1,:) = 1; % colocando 1 no vetor
  y = [m1,m2]; % y é a juncao das classes
  classes = [ones(1,N1),-1*ones(1,N2)]; % identifica quem eh positivo e quem eh negativo (classe 1 ou classe -1)
  
  cont_erro = length(classes); % Nesse momento o numero de erro eh maximo (inicio do perceptron)
  w = rand([1,L+1]); % criando w0 aleatorio
  wp = w;
  n_i = 0; % contador de iteracoes, inicia igual a 1 pois eh a primeira iteracao
  
  if plotar == 1
    h = figure('name','Perceptron'); % criando uma figura
  end
  
  J0 = inf;
  
  while(cont_erro > 0 && n_i < max_i) % enquanto contador de erro for maior que zero ou numero de iteracoes passar do maximo
    pk = sign(w*y); % classificar em classe 1 ou -1
    % se pk maior que zero, faz parte da classe 1
    % se pk menor que zero, faz parte da classe -1
    Ye = classes ~= pk; % Ye posicao de quem é diferente da classifcacao verdadeira (quem foi classificado erroneamente)
    J1 = sum(((repmat(pk(Ye),L+1,1)).* y(:,Ye)),2);
    w = w - (p *(J1')); % atualizando w
    if J1<J0
      J0 = J1;
      wp = w;
    end
    cont_erro = sum(Ye); % contador de erro eh o numero de divergencias
    if cont_erro == 0
        break;
    end
    n_i = n_i + 1; % contador de erro ++
    w0 = w(3); % um ponto do plano perceptron é a ultima posicao de w
    x1 = min([m1(1,:),m2(1,:)]); % calculando x de uma extremidade do perceptron
    y1 = (-w0/w(2))-x1*(w(1)/w(2)); % calculando y de uma extremidade do perceptron
    x2 = max([m1(1,:),m2(1,:)]); % calculando x de outra extremidade do perceptron
    y2 = (-w0/w(2))-x2*(w(1)/w(2));  % calculando y de outra extremidade do perceptron
    
    if plotar == 1 % só para plotar e deixar chavoso
        cla; % limpando os eixos
        plot(m1(1,:),m1(2,:),'b*'); % plotando classe 1
        hold on;
        plot(m2(1,:),m2(2,:),'r*'); % plotando classe 2
        hold on;
        plot([x1,x2],[y1,y2],'k:','linewidth',1.5); % plotando linha de separação entre as classes
        xlabel('Caracteristica 1'); 
        ylabel('Caracteristica 2');
        figure(h); % chamando figura h
        legend('Classe 1','Classe 2','Perceptron','Location','eastoutside'); % legenda
        title(['Nº de iteracoes ',num2str(n_i)]);
        pause(2);        
    end
  end
  if plotar ~= 1 % só para plotar e deixar chavoso
        plot(m1(1,:),m1(2,:),'b*'); % plotando classe 1
        hold on;
        plot(m2(1,:),m2(2,:),'r*'); % plotando classe 2
        hold on;
        plot([x1,x2],[y1,y2],'k:','linewidth',1.5); % plotando linha de separação entre as classes
        xlabel('Caracteristica 1'); 
        ylabel('Caracteristica 2');
        legend('Classe 1','Classe 2','Perceptron','Location','eastoutside'); % legenda
        title(['Nº de iteracoes ',num2str(n_i)]);
   end
end

end
