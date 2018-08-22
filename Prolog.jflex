
//clase

%%
%public
%standalone
%unicode
%class AL

SALUDO = Hola
DIGITO = [0-9]
IDENTIFICADOR = [a-z]
%%
{IDENTIFICADOR}.*"(" {System.out.println("IDENTIFICADOR");}
%.* {System.out.println("COMENTARIO");}
1* {System.out.println("UNOS");}
{DIGITO} {System.out.println("DIGITO");}