#+Title: Proyecto 1: Analizador Léxico
#+OPTIONS: toc:nil date:nil

* Entrega 14 Septiembre 2018
* Descripción
En este proyecto se construirá el primer componente de un compilador, un
analizador léxico. Para este trabajo se utilizará el generador de analizadores
léxico /JFlex/.
El lenguaje en el que estará escrito el código fuente es una versión
minimizada de /python/; /p/.
Los átomos presentes en la gramática del lenguaje son:
1. *IDENTIFICADOR*
2. *RESERVADA*
3. *BOOLEANO*
4. *ENTERO*
5. *REAL*
6. *CADENA*
7. *OPERADOR*
7. *SALTO*
8. *INDENTA*
9. *DEINDENTA*

Las palabras resevadas, operadores y separadores también tienen que ser reconocidos.
Para mayor referencia revisar el archivo /atomos.pdf/.

Veamos un ejemplo de cómo debe comportarse el analizador léxico.
Tenemos el siguiente código en /p/:

#+BEGIN_EXAMPLE
if 9 > 7:
  v_x = -4
  while v_x < 1:
    v_x += 1
    print v_x * 3
else:
   v_x = "Hello world"
#+END_EXAMPLE

La salida esperada de nuestro analizador es:

#+BEGIN_EXAMPLE
RESERVADA(if)ENTERO(9)OPERADOR(>)ENTERO(7)SEPARADOR(:)SALTOINDENTA(2)
IDENTIFICADOR(v_x)OPERADOR(=)OPERADOR(-)ENTERO(4)SALTORESERVADA(while)
IDENTIFICADOR(v_x)OPERADOR(<)ENTERO(1)SEPARADOR(:)SALTOINDENTA(4)
IDENTIFICADOR(v_x)OPERADOR(+=)ENTERO(1)SALTORESERVADA(print)
IDENTIFICADOR(v_x)OPERADOR(*)ENTERO(3)SALTODEINDENTA(4)DEINDENTA(2)
RESERVADA(else)SEPARADOR(:)SALTOINDENTA(3)IDENTIFICADOR(v_x)OPERADOR(=)
CADENA(Hello world)SALTODEINDENTA(3)
#+END_EXAMPLE

A los ojos del analizador sintáctico, que será el consumidos de los
átomos, la salida es suficientemente entendible de ésta manera. Pero
para nosotros sería mejor de ésta manera:

#+BEGIN_EXAMPLE
RESERVADA(if)ENTERO(9)OPERADOR(>)ENTERO(7)SEPARADOR(:)SALTO
INDENTA(2)IDENTIFICADOR(v_x)OPERADOR(=)OPERADOR(-)ENTERO(4)SALTO
RESERVADA(while)IDENTIFICADOR(v_x)OPERADOR(<)ENTERO(1)SEPARADOR(:)SALTO
INDENTA(4)IDENTIFICADOR(v_x)OPERADOR(+=)ENTERO(1)SALTO
RESERVADA(print)IDENTIFICADOR(v_x)OPERADOR(*)ENTERO(3)SALTO
DEINDENTA(4)
DEINDENTA(2)
RESERVADA(else)SEPARADOR(:)SALTO
INDENTA(3)IDENTIFICADOR(v_x)OPERADOR(=)CADENA(Hello world)SALTO
DEINDENTA(3)
#+END_EXAMPLE

Cabe destacar que los espacios y saltos de línea son únicamente para
hacer mas legible la salida, no son átomos que deba producir el
analizador léxico. Sólo para facilitar la lectura, salidas como la anterior, con saltos de
línea, son las que se esperan para este proyecto.
Ahora veremos cómo se comporta bajo el siguiente error léxico:
#+BEGIN_EXAMPLE
# ejemplo.p
if 0 < 1:
    x = 2 + 9
    print x
 else:
   x = 8
#+END_EXAMPLE

Salida:

#+BEGIN_EXAMPLE
RESERVADA(if)ENTERO(0)OPERADOR(<)ENTERO(1)SEPARADOR(:)SALTO
INDENTA(4)IDENTIFICADOR(x)OPERADOR(=)ENTERO(2)OPERADOR(+)ENTERO(9)SALTO
RESERVADA(print)IDENTIFICADOR(x)SALTO
Error de indentacion, linea 5
#+END_EXAMPLE

El error fue producido por qué el bloque del ~else~, al tener un nivel
de indentación menor a la línea anterior, debería ser alguno de los
que ya habían sido creados.


Veamos ahora el siguiente ejemplo:
#+BEGIN_EXAMPLE
if 3 < 1:
   print 2
      print 7
#+END_EXAMPLE
Salida:
#+BEGIN_EXAMPLE
RESERVADA(if)ENTERO(3)OPERADOR(<)ENTERO(1)SEPARADOR(:)SALTO
INDENTA(4)RESERVADA(print)ENTERO(2)SALTO
INDENTA(8)RESERVADA(print)ENTERO(7)SALTO
DEINDENTA(8)
DEINDENTA(4)
#+END_EXAMPLE

Entre las dos instrucciones de ~print~ no hay una que nos indique la
creación de un nuevo bloque, por lo que no es un programa válido en
/p/, sin embargo, el analizador léxico no es el encargado de
detectar este tipo de errores.
La regla general es que el analizador léxico debe detectar átomos mal
formados, mientras que el analizador sintáctico secuencias de átomos
mal formadas respecto a la sintaxis del lenguaje.

La salida puede ser devuelta en algún archivo o a la salida estándar,
pero en ambos casos debe reportar errores con número de línea.

* Jflex
  Vista con detenimiento, la tarea de reconocer los átomos de bloques
  (*INDENTA* y *DEINDENTA*) no parece ser solucionable únicamente con
  expresiones regulares, ya que:
  - Los espacios que se encuentran al principio tienen un significado
    diferente a los que se encuentran entre las palabras del código
  - Para saber si una línea pertenece o no a un bloque se debe conocer
    el nivel de indentación de las líneas previas.

  /Jflex/ provee una característica llamada /contexto/ que puede ayudar
  a completar la tarea anterior.

  Un contexto está definido por un identificador y el conjunto de reglas
  que se van a aplicar cuándo éste esté activo. Un contexto se encuentra
  activo si la variable interna ~zzLexicalState~ tiene el valor de su identificador.

  Para definir un contexto se debe escribir en la segunda sección del archivo:
  #+BEGIN_EXAMPLE
  %s[tate] "identificador" [, "identificador", ... ]
  #+END_EXAMPLE
  ó
  #+BEGIN_EXAMPLE
  %x[state] "identificador" [, "identificador", ... ]
  #+END_EXAMPLE

  En el primer caso, se definen /contextos inclusivos/, eso quiere que las
  reglas dentro del contexto y todas aquellas que no estén especificadas
  para algún contexto están activas.

  En el segundo caso, se definen /contextos exclusivos/, eso quiere que
  únicamente las reglas dentro del contexto están activas.

  En ambos casos los contextos se guardan como constantes enteras.

  La sintaxis para indicar que una regla pertenece a un determinado
  contexto es la siguiente:

  ~<Contexto>regla {acción}~

  Para indicar que todo un conjunto de reglas pertenencen a un
  contexto:
  #+BEGIN_EXAMPLE
    <Contexto>{
      regla_1 {acción_1}
      regla_2 {acción_2}
      ...
      regla_k {acción_k}
    }
  #+END_EXAMPLE

  Las funciones relacionados con contextos son:
  * ~yybegin(int identificador_contexto)~ inicia el contexto con identificador
    ~identificador_contexto~.
  * ~yystate(void)~ devuelve el contexto activo.

  El contexto por omisión es ~YYINITIAL~.

* Ejercicio
** FizzBuzz
   Realiza una implementación del ~FizzBuzz~ hasta 100 en ~python 2.7~ en paradigma imperativo.
   El código sólo debe utilizar:
   - Ciclos while
   - Condicionales if
   - Variables que conserven tipo (entero o cadena)
   - Operaciones aritméticas
   - Impresión de enteros o cadenas.

   El código debe estar en un archivo llamado ~fizzbuzz.p~.

** Modificaciones al fizzbuzz.
   Se deberán crear 3 archivos que prueben que su analizador detecta de forma
   adecuada los siguientes aspectos:
   1) Una cadena mal formada, (~fz_error_cadena.p~).
   2) Un error de creación de bloques, (~fz_error_indentacion.p~).
   3) Lexemas que no están contemplados en ninguna categoría léxica, (~fz_error_lexema.p~).

** Analizador léxico
  Crear un proyecto administrado con ~maven~ que se llame *lexico*.
  El proyecto generará un analizador léxico para las categorías sintácticas descritas en
  /categorias.pdf/.

  Escribir un archivo llamado ~Flexer.jflex~ que genere un analizador léxico
  en una clase llamada ~Flexer~.

  Cuando haya un átomo mal formado se debe detener el funcionamiento del analizador léxico y
  se debe reportar el número de línea en el que se encuentra.

  El analizador se probará sobre los 4 archivos anteriores. Y el resultado de cada uno será otro archivo
  con el mismo nombre pero con extensión ~plx~, ejemplo (~fizzbuzz.plx~). Los archivos de salida estarán
  ubicados en un directorio en la raíz de su proyecto llamado ~out~.

* Condiciones de entrega
  - El código debe subirse al repositorio.
  - El código debe ubicarse en la siguiente ruta:
   #+BEGIN_EXAMPLE
   Repo
     |-> Proyectos
       |-> Proyecto_1
         |-> README.[org|txt|pdf|md]
         |-> pom.xml
         |-> src
           ...
         |-> out (resultado del análisis)
   #+END_EXAMPLE
  - El ~README.[org|txt|pdf|md]~ debe tener las instrucciones para compilar y ejecutar el proyecto.
