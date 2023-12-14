%option noyywrap

%x CONST_CHAR
%x CONST_STRING

%{
#include<stdio.h>
#include<stdlib.h>
#include<ctype.h>
#include<string.h>
#include<iostream>

int line_count=1;
int error_count=0;

FILE *logout;
FILE *tokenout;

std::string lexeme;
std::string characterToken;

std::string stringToken;
bool multiLineString = false;
int startLine;

char *toUpper(char *s){
    int n = strlen(s);
    char *newChar = new char[n+1];
    int i = 0;
    while(*s){
        newChar[i] = toupper(*s);
        s++;
        i++;
    }
    newChar[i] = '\0';
    return newChar;
}

void endFile(){
    fprintf(logout, "Total number of errors: %d\n", error_count);
    fprintf(logout, "Total number of lines: %d\n", line_count);
}

%}

DIGIT [0-9]
KEYWORDS if|else|for|while|do|break|int|char|float|double|void|return|switch|case|default|continue
NEWLINE \n
%%

{KEYWORDS} {
    char *upper = toUpper(yytext);
    fprintf(tokenout,"<%s, %s>\n", upper, yytext);
    fprintf(logout, "Line# %d: Token <%s> Lexeme %s found\n", line_count, upper, yytext);
    delete[] upper;
}  

{DIGIT}+ {
    fprintf(tokenout,"<CONST_INT, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <CONST_INT> Lexeme %s found\n", line_count, yytext);    
}
{DIGIT}+((\.{DIGIT}+)?(E[+-]?{DIGIT}+)?) {
    fprintf(tokenout,"<CONST_FLOAT, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <CONST_FLOAT> Lexeme %s found\n", line_count, yytext);
}
' {
    characterToken = "";
    lexeme = "";
    BEGIN(CONST_CHAR);
}

<CONST_CHAR>' {
    if(characterToken.length() == 0){
        fprintf(logout, "Error at line# %d: EMPTY_CONST_CHAR \'\'\n", line_count);
        error_count++;
    }
    else if(characterToken.length() > 1){
        fprintf(logout, "Error at line# %d: MULTICHAR_CONST_CHAR \'%s\'\n", line_count, characterToken.c_str());
        error_count++;
    }else{
        fprintf(tokenout,"<CONST_CHAR, %s>\n", characterToken.c_str());
        fprintf(logout, "Line# %d: Token <CONST_CHAR> Lexeme %s found\n", line_count, characterToken.c_str());
    }
    BEGIN(INITIAL);
}

<CONST_CHAR>\\[nt\'afrbv0\"\\] {
    char c;
    switch(yytext[1]){
        case 'n': c = '\n'; break;
        case 't': c = '\t'; break;
        case '\'': c = '\''; break;
        case 'a': c = '\a'; break;
        case 'f': c = '\f'; break;
        case 'r': c = '\r'; break;
        case 'b': c = '\b'; break;
        case 'v': c = '\v'; break;
        case '0': c = '\0'; break;
        case '\"': c = '\"'; break;
        case '\\': c = '\\'; break;
    }
    characterToken += c;
    lexeme += yytext;
}

<CONST_CHAR>\n {
    fprintf(logout, "Error at line# %d: UNFINISHED_CONST_CHAR \'%s\n", line_count, lexeme.c_str());
    error_count++;
    line_count++;
    BEGIN(INITIAL);
}

<CONST_CHAR><<EOF>> {
    fprintf(logout, "Error at line# %d: UNFINISHED_CONST_CHAR \'%s\n", line_count, lexeme.c_str());
    error_count++;
    BEGIN(INITIAL);
    endFile();
}

<CONST_CHAR>. {
    characterToken += yytext;
    lexeme += yytext;
}

"+"|"-" {
    fprintf(tokenout,"<ADDOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <ADDOP> Lexeme %s found\n", line_count, yytext);
}

"*"|"/"|"%" {
    fprintf(tokenout,"<MULOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <MULOP> Lexeme %s found\n", line_count, yytext);
}

"++"|"--" {
    fprintf(tokenout,"<INCOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <INCOP> Lexeme %s found\n", line_count, yytext);
}
"<"|">"|"<="|">="|"=="|"!=" {
    fprintf(tokenout,"<RELOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <RELOP> Lexeme %s found\n", line_count, yytext);
}

"=" {
    fprintf(tokenout,"<ASSIGNOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <ASSIGNOP> Lexeme %s found\n", line_count, yytext);
}

"&&"|"||" {
    fprintf(tokenout,"<LOGIOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <LOGIOP> Lexeme %s found\n", line_count, yytext);
}

"!" {
    fprintf(tokenout,"<NOT, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <NOT> Lexeme %s found\n", line_count, yytext);
}

"&"|"|"|"^"|"<<"|">>" {
    fprintf(tokenout,"<BITOP, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <BITOP> Lexeme %s found\n", line_count, yytext);
}

"(" {
    fprintf(tokenout,"<LPAREN, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <LPAREN> Lexeme %s found\n", line_count, yytext);
}

")" {
    fprintf(tokenout,"<RPAREN, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <RPAREN> Lexeme %s found\n", line_count, yytext);
}

"{" {
    fprintf(tokenout,"<LCURL, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <LCURL> Lexeme %s found\n", line_count, yytext);
}

"}" {
    fprintf(tokenout,"<RCURL, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <RCURL> Lexeme %s found\n", line_count, yytext);
}

"[" {
    fprintf(tokenout,"<LSQUARE, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <LSQUARE> Lexeme %s found\n", line_count, yytext);

}

"]" {
    fprintf(tokenout,"<RSQUARE, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <RSQUARE> Lexeme %s found\n", line_count, yytext);
}

"," {
    fprintf(tokenout,"<COMMA, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <COMMA> Lexeme %s found\n", line_count, yytext);
}

";" {
    fprintf(tokenout,"<SEMICOLON, %s>\n", yytext);
    fprintf(logout, "Line# %d: Token <SEMICOLON> Lexeme %s found\n", line_count, yytext);
}


\" {
    BEGIN(CONST_STRING);
    stringToken = "";
    multiLineString = false;
    lexeme = "";
    startLine = line_count;
}

<CONST_STRING>\" {
    std::string tmp = "SINGLE LINE STRING";
    if(multiLineString){
        tmp = "MULTI LINE STRING";
    }
    fprintf(tokenout,"<%s, %s>\n", tmp.c_str(), stringToken.c_str());
    fprintf(logout, "Line# %d: Token <%s> Lexeme %s found\n", startLine, tmp.c_str(), lexeme.c_str());
    BEGIN(INITIAL);
}

<CONST_STRING>\\\n {
    multiLineString = true;
    line_count++;
    lexeme += yytext;
}

<CONST_STRING>\\[nt\'afrbv0\"\\] {
    char c;
    switch(yytext[1]){
        case 'n': c = '\n'; break;
        case 't': c = '\t'; break;
        case '\'': c = '\''; break;
        case 'a': c = '\a'; break;
        case 'f': c = '\f'; break;
        case 'r': c = '\r'; break;
        case 'b': c = '\b'; break;
        case 'v': c = '\v'; break;
        case '0': c = '\0'; break;
        case '\"': c = '\"'; break;
        case '\\': c = '\\'; break;
    }

    stringToken += c;
    lexeme += yytext;
}
<CONST_STRING>\n {
    fprintf(logout, "Error at line# %d: UNFINISHED_STRING \"%s\n", startLine, lexeme.c_str());
    error_count++;
    line_count++;
    BEGIN(INITIAL);
}

<CONST_STRING><<EOF>> {
    fprintf(logout, "Error at line# %d: UNFINISHED_STRING \"%s\n", startLine, lexeme.c_str());
    error_count++;
    BEGIN(INITIAL);
    endFile();
}

<CONST_STRING>. {
    lexeme += yytext;
    stringToken += yytext;
}

{NEWLINE} {
    line_count++;
}
%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("log.txt","w");
	tokenout= fopen("token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}