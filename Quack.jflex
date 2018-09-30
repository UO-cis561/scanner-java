/* JFlex scanner starter code harvested from a 2015 project for a different language */

import java_cup.runtime.Symbol;
import java_cup.runtime.SymbolFactory;
import java_cup.runtime.ComplexSymbolFactory;
import java_cup.runtime.ComplexSymbolFactory.Location;

%%

%cup
%class Scanner
%line
%column
%type ComplexSymbolFactory.ComplexSymbol

%{  // Code to be included in the Scanner class goes here


  // Stack of file names, for 'include' files
  // java.util.Stack<String> input_stack = new java.util.Stack<String>();
  String cur_file = "";

  // Buffer for building up tokens that take more than one pattern,
  // e.g., quoted strings 
  StringBuffer string = new StringBuffer();

  // The default "Symbol" class in CUP is stupid.  We need the alternative
  // ComplexSymbol class, which is managed by a ComplexSymbolFactory, 
  // because in Java you don't have Problems, you have ProblemFactories
  // We share the ComplexSymbolFactory with other components;
  // CUP examples do this, but I'm not sure why or if it's necessary.
  ComplexSymbolFactory symbolFactory; 

  // Alternate constructor to share the factory
  public Scanner(java.io.Reader in, ComplexSymbolFactory sf){
	this(in);
	symbolFactory = sf;
  }


  // Factor a bunch of tedium from constructing ComplexSymbol objects
  // into helper functions. 
  /**
   * Create a Symbol (token + location + text) for a lexeme 
   * that is not converted to another kind of value, e.g., 
   * keywords, punctuation, etc.
   */
  public ComplexSymbolFactory.ComplexSymbol mkSym(int id) {
    	    return (ComplexSymbolFactory.ComplexSymbol) 
               symbolFactory.newSymbol( 
	    	  sym.terminalNames[id], // per Cup documentation, no idea why
		  id,               // the actual integer used as a token code
		  new Location(yyline+1, yycolumn+1),  	// Left extent of token
		  new Location(yyline+1, yycolumn+yylength()), // Right extent
		  yytext()       	 		  // Text of the token
		  );
   }

  /**
   * Create a Symbol (token + location + value) for a lexeme 
   * that is not converted to another kind of value, e.g., 
   * an integer literal, or a token that requires more than 
   * one pattern to match (so that we can't just grab yytext).
   */
   public ComplexSymbolFactory.ComplexSymbol mkSym(int id, Object value) {
    	    return (ComplexSymbolFactory.ComplexSymbol) 
                symbolFactory.newSymbol( 
	    	  sym.terminalNames[id],  // per Cup documentation, no idea why
		  id,           	  // the actual integer token code
		  new Location(yyline+1, yycolumn+1),  // Left extent of token
		  new Location(yyline+1, yycolumn+yylength()), // Right extent
		  value      	 		 // e.g. Integer for int value
		  );
   }


   int lexical_error_count = 0; 
   int comment_begin_line = 0; /* For running off end of file in comment */ 
   int MAX_LEX_ERRORS = 20;
   
   int commentDepth = 0;	/* Used to keep track of nested comments */
   int currStrLen = 0, maxStrLen = 1024; /* Used to determine if a string is short enough to be valid */

   String lit = ""; 

  // If the driver gives us an error report class, we use it to print lexical
  // error messages
  ErrorReport report = null; 
  public void setErrorReport( ErrorReport _report) {
       report = _report;
  }

  void err(String msg) {
    if (report == null) {
        System.err.println(msg); 
    } else {
        report.err(msg); 
    }
   }

  void lexical_error(String msg) {
    String full_msg = "Lexical error at " + cur_file + 
    		      " line " + yyline + 
    		       ", column " + yycolumn +
		       ": " + msg; 
    err(full_msg); 
    if (++lexical_error_count > MAX_LEX_ERRORS) {
       err("Too many lexical errors, giving up."); 
       System.exit(1); 
    }
  }
  
%}
// %debug


%xstate INCOMMENT
%xstate STRING

SPACE = [ \n\t]+
LETTER = [a-zA-Z]+
DIGIT = [0-9]+
INTEGER = {DIGIT}*
REAL = {INTEGER}\.{INTEGER}
SINGLELINECOMMENT = "--".*[\n]

%%

{SPACE}    { ; /* skip */ }

{SINGLELINECOMMENT}	{ ; /* skip */ }

"/*" { yybegin(INCOMMENT); comment_begin_line = yyline; commentDepth++;}
<INCOMMENT> {
  "/*"  { commentDepth++; }
  "*/"  { commentDepth--;
  	  if(commentDepth == 0){
  		yybegin(YYINITIAL);
  	  }
	}
 [^\*]+ { /* skip */ }
  .     { /* skip */ }
  \n    { /* skip */ }
  <<EOF>> { lexical_error("Comment \"/*...\"  missing ending \"*)\"" +
                          "\nComment began on line " +comment_begin_line ); 
	    yybegin(YYINITIAL); 
          }
}

<<EOF>>    { return mkSym( sym.EOF );  }

/* Punctuation */ 

"("	   { return mkSym( sym.LPAREN ); }
")"	   { return mkSym( sym.RPAREN ); }
"{"	   { return mkSym( sym.LBRACE ); }
"}"	   { return mkSym( sym.RBRACE ); }


{INTEGER}	{ return mkSym( sym.INT_LIT, yytext() ); }



/* Default when we don't match anything above 
 * is a scanning error.  We don't want too many of 
 * these, but it's hard to know how much to gobble ... 
 */ 
.   { lexical_error("Illegal character '" +
      	              yytext() +
		      "' "); 
    }

