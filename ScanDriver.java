/**
 * Simple driver for a JFLEX-generated scanner
 *
 */

import java_cup.runtime.Symbol;
import java_cup.runtime.SymbolFactory; 
import java_cup.runtime.ComplexSymbolFactory;

import java.io.*;
import org.apache.commons.cli.*; // Command line parsing package

class ScanDriver {

    // Command line options
    String sourceFile = ""; 

    // Internal state
    ErrorReport report; 

    static public void main(String args[]) {
	ScanDriver driver = new ScanDriver(); 
	driver.go(args); 
    }

    public void go(String[] args) {
        report = new ErrorReport(); 
	parseCommandLine(args); 
        System.out.println("Beginning parse ..."); 
        try {
	    Scanner scanner = 
		new Scanner (new FileReader ( sourceFile ), 
				 new ComplexSymbolFactory()); 
	    scanner.setErrorReport(report); 
	    
	    ComplexSymbolFactory.ComplexSymbol s = scanner.next_token(); 
	    while (s.sym != sym.EOF) {
		System.out.println(s.xleft.getLine() + "," + 
				   s.xleft.getColumn() + ": " +
				   sym.terminalNames[s.sym] + "\t" +
				   s.value.toString());
		s = scanner.next_token(); 
	    }
				   

	    System.out.println("Done parsing"); 
        } catch (Exception e) {
            System.err.println("Yuck, blew up in parse/validate phase"); 
            e.printStackTrace(); 
	    System.exit(1); 
        }


    }

    void parseCommandLine(String args[]) {
	try {
	    // Comman line parsing
	    Options options = new Options(); 
	    CommandLineParser  cliParser = new GnuParser(); 
	    CommandLine cmd = cliParser.parse( options, args); 
	    String[] remaining = cmd.getArgs(); 
	    int argc = remaining.length; 
	    if (argc == 0) {
		report.err("Input file name required"); 
		System.exit(1); 
	    } else if (argc == 1) {
		sourceFile = remaining[0]; 
	    } else {
		report.err("Only 1 input file name can be given;"+
				    " ignoring other(s)"); 
	    }
	} catch (Exception e) {
	    System.err.println("Argument parsing problem"); 
	    System.err.println(e.toString()); 
	    System.exit(1); 
	}
    }
}
