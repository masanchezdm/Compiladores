/********************************************************************************
**  @author Diana Montes                                                       **
**  @about Proyecto 1: Analizador léxico para p, subconjunto de Python.        **
*********************************************************************************/
package lexico;
import java.util.*;

%%

%public
%class Alexico
%unicode
%standalone

%x  INDENTACION

SALTO = \r | \n | \r\n 
WhiteSpace     = {SALTO} | [ \t\f]
ENTERO = [1-9][0-9]* | 0+
REAL = "."[0-9] | {ENTERO}"."[0-9]+ | {ENTERO}"."
RESERVADO = "print" | and | as | assert | break | class | continue
            | def | del | elif | else | except | exec | 
            finally | for | from | global | if | import
            | in | is | lambda | not | or | pass |
            raise | return | try | while | with | yield |
            None
IDENTIFICADOR = ([a-zA-Z])([a-zA-Z] | [0-9] | "_")*
SEPARADOR = ":"
BOOLEAN = false | true
OPERADOR = "+" | "/" | "<" | ">" | "-" | "*" | "%" | "<=" 
            | ">=" | "=" | "!" | "!=" | ">" | "**" | "//" |
            "and" | "or" | "not"

CADENA =  "."

%{

            //codigo dentro de la clase
    private static Stack<Integer> pila = new Stack<Integer>();
    private static int counter = 0;
    public static void identa(boolean continuar_indent){
        if(continuar_indent)
            counter++;
        else{
            if(counter > 0 && pila.empty()){
                pila.push(counter);            
                System.out.print("INDENTA(" + counter+ ")" );
            }
            if(counter > 0 && !pila.empty() && counter > pila.peek()){
                pila.push(counter);   
                System.out.print("INDENTA(" + counter+ ")");
            }else if(counter > 0 && !pila.empty() && counter < pila.peek()){
                System.out.print("error");
                return;
            }
            else if(counter == 0){
                while(!pila.empty()){
                    System.out.println("DENDENTA " + pila.pop() + " ");
                }
                return;
            }
            counter = 0;  
            
        }
    }

%}

%%
{SALTO} = {System.out.print("SALTO ") ;}
{CADENA} = {System.out.print("CADENA ");}
#.*            {System.out.print("COMENTARIO ");}
{RESERVADO}    {System.out.print("Reservado ");}

{REAL} {System.out.print("REAL ");}
{ENTERO}      {System.out.print("ENTERO ");}
{OPERADOR}    {System.out.print("OPERADOR ");}
{IDENTIFICADOR} {System.out.print("IDENTIFICADOR ");}
{SEPARADOR} {System.out.print("SEPARADOR ");}
"\n" {System.out.println("SALTO "); yybegin(INDENTACION);}
"" { yybegin(INDENTACION);}
<INDENTACION>{
" "         {identa(true);}
 .          {identa(false); yybegin(YYINITIAL);}
}


