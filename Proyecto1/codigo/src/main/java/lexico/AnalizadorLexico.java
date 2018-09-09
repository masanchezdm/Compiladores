package lexico;
import java.io.*;

public class AnalizadorLexico {
    Alexico lexer;

    public AnalizadorLexico(String archivo){
        try {
            Reader lector = new FileReader("src/main/resources/test.txt");
            lexer = new Alexico(lector);
        }
        catch(FileNotFoundException ex) {
            System.out.println(ex.getMessage() + " No se encontró el archivo;");
        }
    }

    public void analiza(){
        try{
          lexer.yylex();
        }catch(IOException ex){
            System.out.println(ex.getMessage());
        }
    }

}
