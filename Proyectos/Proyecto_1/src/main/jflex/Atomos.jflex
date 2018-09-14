/********************************************************************************
**  @author Diana Montes                                                       **
**  @about Proyecto 1: Analizador léxico para p, subconjunto de Python.        **
*********************************************************************************/
package lexico;
import java.util.*;
import java.io.FileWriter;
import java.io.BufferedWriter;

%%

%public
%class Alexico
%unicode
%states I
%standalone

%x  INDENTACION

SALTO = \r|\n|\r\n|\R
WhiteSpace     = {SALTO} | [ \t\f]
ENTERO = [1-9][0-9]* | 0+
REAL = "."[0-9] | {ENTERO}"."[0-9]+ | {ENTERO}"."
RESERVADO = "while" | "print" | and | as | assert | break | class | continue
            | def | del | elif | else | except | exec | 
            finally | for | from | global | if | import
            | in | is | lambda | not | or | pass |
            raise | return | try | with | yield |
            None
IDENTIFICADOR = ([a-zA-Z])([a-zA-Z] | [0-9] | "_")*
SEPARADOR = ":"
BOOLEAN = false | true
OPERADOR = "+" | "/" | "<" | ">" | "-" | "*" | "%" | "<=" 
            | ">=" | "=" | "!" | "!=" | ">" | "**" | "//" |
            "and" | "or" | "not" | "+=" | "-="

CADENA =  \" ~\"
%{

            //codigo dentro de la clase
    private static Stack<Integer> pila = new Stack<Integer>();
    private int counter = 0, linea = 1;
    private String resultado = "";
    public  void indenta(boolean continuar_indent){
        if(continuar_indent){
            counter++;
            return;
        }else{
            if(counter > 0 && pila.empty()){
                pila.push(counter);            
                analisis("INDENTA(" + counter+ ")" );
            }else if(counter > 0 && !pila.empty() && counter > pila.peek()){
                pila.push(counter);   
                analisis("INDENTA(" + counter+ ")");
            }else if(counter > 0 && !pila.empty() && counter < pila.peek()){
                analisis("Error de indentacion, linea " + linea);
                System.out.print(resultado);
                archivo();
                System.exit(0);
            }else if(counter == 0){
                while(!pila.empty()){
                    analisis("DENDENTA(" + pila.pop() + ") \n");
                }
                return;
            }
            counter = 0;  
            
        }
        return;
    }
    
    public void analisis(String exp){
        resultado+=exp;
    }
    
    public void archivo(){
        try{
            FileWriter fw1 = new FileWriter("salida/Proyecto1.plx");
            BufferedWriter bw1 = new BufferedWriter(fw1);
            bw1.write(resultado);
            bw1.close();
        }catch(Exception ex){}
    }

%}

%eof{
analisis("SALTO\n");
while(!pila.isEmpty()){
    analisis("DEINDENTA("+pila.pop()+")\n");
}

System.out.print(resultado);
archivo();

%eof}

%%
    {SALTO}         {linea+=1; analisis("SALTO\n"); yybegin(INDENTACION);}
    {CADENA}         {analisis("CADENA(" + yytext()+ ")");}
    #.*             {analisis("COMENTARIO(" + yytext()+ ")");}
    {RESERVADO}     {analisis("Reservado(" + yytext()+ ")");}

    {REAL}          {analisis("REAL(" + yytext()+ ")");}
    {ENTERO}        {analisis("ENTERO(" + yytext()+ ")");}
    {OPERADOR}      {analisis("OPERADOR(" + yytext()+ ")");}
    {IDENTIFICADOR} {analisis("IDENTIFICADOR(" + yytext()+ ")");}
    {SEPARADOR}     {analisis("SEPARADOR(" + yytext()+ ")");}
    <INDENTACION>{
    " "         {indenta(true);}
     .          {indenta(false); yypushback(1); yybegin(YYINITIAL);}
    }


