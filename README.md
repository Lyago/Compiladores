Compilar usando `Makefile` 

    $ make

ou manualmente no Linux, passo a passo abaixo:

    $ bison -d calc.y
    $ flex calc.l
    $ gcc calc.tab.c lex.yy.c -o calc -lm
    $ ./calc

arquivos exmp1.cal e exmp2.cal são exemplos de arquivos compiláveis. 
São uma série de contas apresentando a gramática e funcionalidades implementadas
