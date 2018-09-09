package lexico;
import java.io.*;

public class Test {

    public static void main (String[] args){
        AnalizadorLexico al = new AnalizadorLexico("src/main/resources/fb.txt");
        al.analiza();
    }
}
