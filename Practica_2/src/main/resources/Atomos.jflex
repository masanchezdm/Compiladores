package com.mycompany.practica_2;

%%

%byaccj
%class Atomos

%{
  private Parser yyparser;

  public Atomos(java.io.Reader r, Parser yyparser) {
    this(r);
    this.yyparser = yyparser;
  }
%}

NUMBER = [1-9][0-9]* | 0
NL = "\n" | "\r"  | "\r\n"
OPERADOR = "+" | "-" | "*" | "/"

%%

{OPERADOR} { return (int) yycharat(0); }

{NL}   {return Parser.NL;}

{NUMBER}  {return Parser.NUMBER;}

[ \t]+ { }

.   { System.err.println("Error: caracter no reconocido '"+yytext()+"'"); return -1; }
