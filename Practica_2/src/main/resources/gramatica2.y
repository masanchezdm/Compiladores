
%{
  import java.io.*;
%}

%token NL
%token NUMBER
     
%%

input:  /* cadena vacía */
       | input line
       ;

line : expr NL {linea++;  System.out.println("[ok]"); }
     | expr {linea++;  System.out.println("[ok]"); }
     ;

expr : term '+' expr
     | term '-' expr
     | term
     ;

term : factor '*' term
     | factor '/' term
     | factor
     ;

factor : NUMBER
     | '-' NUMBER
     ;
%%

  private Atomos lexer;
  public static short linea = 0 ;

  private int yylex () {
    int yyl_return = -1;
    try {
      yylval = new ParserVal(0);
      yyl_return = lexer.yylex();
    }
    catch (IOException e) {
      System.err.println("IO error :"+e);
    }
    return yyl_return;
  }


    public void yyerror (String error) {
        System.err.println ("[ERROR] " + error);
    }


    public Parser(Reader r) {
        lexer = new Atomos(r, this);
    }

  public static void main(String args[]) throws IOException {
    Parser yyparser;
    yyparser = new Parser(new FileReader("src/main/resources/test.txt"));
    yyparser.yydebug = true; //true para que imprima el proceso.
    int condicion = yyparser.yyparse();

    if(condicion != 0){
      linea++;
      System.err.print ("[ERROR] ");
      yyparser.yyerror("La expresión aritmética no esta bien formada. en la línea " + linea);
    }
  }
