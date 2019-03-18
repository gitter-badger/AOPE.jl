## AOPE - Avaliação de Obrigações e Produtos Estruturados

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/ASaragga/Notebooks.jl/master)

### Elementos de Cálculo Financeiro
A valorização de instrumentos de taxa de juro envolve a observação e estimativa de diversos factores temporais, incluindo: data de liquidação, juros corridos, datas de pagamento de coupons e datas de compensação de rendimentos (e.g. swaps).  

No entanto, estes factores dependem de diversos caracteristicas particulares e convenções de mercado que importam levar em conta para obtenção de estimativas precisas, nomeadamente:
* Duração do Ciclo de Liquidação, 
* Convenção de Dias Úteis
* Convenção de Contagem de Dias
* Calendário do Mercado de Capitais 

Na aplicação AOPE, dispomos de diversos métodos para estimar de forma precisa e de acordo com diferentes convenções e particularidades de mercado  
* Data de Liquidação (depende da duração do ciclo de liquidação e do calendário relevante) - `liqd` 
* Data de Pagamento de coupons e de eventuais reembolsos parciais (depende do calendário relevante e da convenção de dia úteis) - `utild`
* Fração do ano entre duas datas (depende da convenção de contagem de dias) - `frac`
* Juros Corridos de coupons - `jurosc`
* Preço de Liquidação da obrigação - `spreço`
* Yield-to-Redemption (maturidade, call, put) e Yield Simples - `ytr` e `ysimples`


### Instalar AOPE.jl
Primeiro, necessitamos de instalar a linguagem de programação [Julia](https://julialang.org) (download v1.1). Alternativamente também podemos instalar [Julia Pro](https://juliacomputing.com/case-studies/), cujo site apresenta muitos exemplos interessantes de domínios onde foram desenvolvidas aplicações avançadas na linguagem Julia. 

Após correr Julia (duplo-click no ícone) irá aparecer uma janela com o prompt julia> Nesse prompt digitamos,
```julia
] add https://github.com/ASaragga/AOPE.jl
```
e a aplicação AOPE.jl fica instalada. Apenas teremos de repetir novamente este procedimento se quisermos instalar uma nova versão da aplicação AOPE.

Para correr a aplicação numa sessão Julia basta digitar
```julia
using AOPE
```

### Exemplos 
* `liqd(data transação, duração ciclo liquidação, calendário relevante)`
* `utild(data pagamento coupon, convenção dias úteis, calendário relevante)`
* `frac(data inicial, data final, convenção contagem de dias)` 

No REPL:
```julia
julia> using AOPE

julia> liqd(Date(2018,12,23),2,:USNYSE) 
2018-12-26     # data de liquidação será no próximo dia útil seguinte após Natal

julia> liqd(Date(2019,2,22),"T+1",:TARGET)
2019-02-25     # duração do ciclo de liquidação representado textualmente da forma tradicional

julia> utild(Date(2019,3,9),Following,:USNYSE)  # Convenção dias úteis: Following, Calendário: NYSE.
2019-03-11     # pagamento do coupon será dia 11, pois dia 9 Março cai num Sábado  

julia> frac(Date(2011,12,28),Date(2012,2,28),Actual365Fixed())   
0.16986301369863013  # fração do ano entre 2011-12-28 e 2012-02-28 de acorod com a convenção de contagem de dias Actual/365 Fixed

```

Calendários de mercado
* TARGET - Calendário TARGET para a zona Euro
* UKSettlement - Calendário para Reino-Unido, incluindo banking holidays
* USSettlement - Calendário para EUA, incluindo feriados federais excepcionais 
* USNYSE - Calendário para New York Stock Exchange 
* USGovernmentBond - Calendário para Obrigações do Tesouro EUA
* CanadaTSX - Calendário para Toronto Stock Exchange

... e calendários genéricos
* WeekendsOnly - Calendário base, onde a definição de dias úteis inclui feriados, excluindo porém os fins-de-semana 
* Null - Calendário base, onde todos os dias são definidos como sendo dias úteis, incluindo feriados e fins-de-semana

Convenções de Dias Úteis
* Following
* Modified Following
* Preceding
* Modified Proceding
* End of Month

Convenções de Contagem de Dias
* Actual/Actual (ISDA)
* Actual/Actual (ISMA)
* Actual/Actual (ICMA)
* Actual/365 (Fixed)
* Actual/360
* 30/360 Bond Basis
* 30E/360 Eurobond Basis
* 30E/360 (ISDA)

... e para compatibilidade com o Excel
* Actual/Actual (Excel)
* 30/360 (Excel) 

### Opcional 
Adicionalmente também podemos instalar a aplicação [Jupyter](https://jupyter.org). Tal irá permitir interagir com a linguagem Julia, combinando código de programação, resultados calculados, texto formatado, símbolos matemáticos e multimédia num único documento (**notebook**). No prompt julia> digitamos,
```julia
using Pkg; Pkg.add("IJulia")
```
para instalar o kernel de Jupyter para a linguagem Julia. Para lançar o **notebook** no nosso browser (e.g. Google Chrome, Safari, Microsoft Edge) digitamos,
```julia
using IJulia; notebook()
```
Da primeira vez que corrermos `notebook()`, será pergundado se pretendemos instalar Jupyter, ao que iremos responder afirmativamente. Por omissão, o painel inicial do **notebook** será aberto na nossa diretoria pessoal. No entanto, também podemos abrir o **notebook** numa diretoria diferente, fazendo antes,
```julia
using IJulia; notebook(dir="/outra/diretoria")
```
