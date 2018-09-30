#
# Simple Makefile for building scanner with driver;
# almost certainly needs revision.
#

# Adjust paths to local environment
#
JFLEX = ${HOME}/Tools/jflex-1.7.0/bin/jflex
JARS = lib/jflex-full-1.7.0.jar:lib/java-cup-11b-runtime.jar:lib/commons-cli-1.4.jar

all:	Scanner.java ErrorReport.java ScanDriver.java sym.java 
	javac -cp .:$(JARS) $^

Scanner.java: Quack.jflex
	jflex Quack.jflex

%.class: %.java
	javac -cp .:$(JARS) $<

clean:
	rm -f *.class
	rm Scanner.java



