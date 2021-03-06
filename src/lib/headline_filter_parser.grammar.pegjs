
// Grammar for the parser for the headline filter.

// It will automatically be compiled to the parser JavaScript file using the
// parser generator pegjs.

// You can use https://pegjs.org/online to debug it.

// Note: As suggested by alphapapa, the parser can be extended to support
// additional types of filter terms ("predicates"), e.g. ts:on=today
// ts-active:from=2019-12-31 priority:A,B
// - https://github.com/alphapapa/org-ql#non-sexp-query-syntax

// Note: The parser will fail when the syntax does not match the grammar.
// For example, it fails for filter strings like ":" or "this|" because the
// grammar dictates a property or tag after ":" and an alternative word after
// "|". That is intended. Handling this edge cases would add complexity.
// Just wrap parser.parse() in a try-catch block and handle the case of an
// incomplete/incorrect filter string.

Expression "filter expression"
  = _* head:LocationAnnotedTerm tail:(_+ LocationAnnotedTerm)* _* {
      return tail.reduce((result, element) => {
        result.push(element[1]);
        return result;
      }, [head]);
    }
 / _* { return [] }

// Used for computation of completions
LocationAnnotedTerm
  = a:Term {
        a.offset = location().start.offset;
        a.endOffset = location().end.offset;
        return a;
      };

// The order of lines is important here.
Term "filter term"
  = "-" a:PlainTerm { a.exclude = true;  return a; }
  /     a:PlainTerm { a.exclude = false; return a; }

PlainTerm
  = TermText
  / TermProp
  / TermTag

TermText "text filter term"
  = a:StringAlternatives {
        let type = 'ignore-case';
        // It's hard to check for upper-case chars in JS.
        // Best approach: https://stackoverflow.com/a/31415820/999007
        // Simplest approach for now:
        if (text().match(/[A-Z]/))
          type = 'case-sensitive';

        return {type: type, words: a}
  }

TermTag "tag filter term"
  = ":" a:TagAlternatives { return {type: 'tag', words: a} }

TermProp "property filter term"
  = ":" a:PropertyName ":" b:StringAlternatives? {
          return {
            type: 'property',
            property: a,
            words: b === null ? [''] : b
          }
        };

StringAlternatives "alternatives"
  = head:String tail:("|" String)* {
       return tail.reduce((result, element) => {
         result.push(element[1]);
         return result;
       }, [head])
     }

TagAlternatives "tag alternatives"
  = head:TagName tail:("|" TagName)* {
       return tail.reduce((result, element) => {
         result.push(element[1]);
         return result;
       }, [head])
     }

String "string"
  = [^: \t|'"]+ { return text() }
  / "'" a:([^']+) "'" { return a.join('') }
  / '"' a:([^"]+) '"' { return a.join('') }

// https://orgmode.org/manual/Property-Syntax.html
// - Property names (keys) are case-insensitive
// - Property names must not contain space
PropertyName "property name"
  = [^: \t]+ { return text() }

// https://orgmode.org/manual/Tags.html
TagName "tag name"
  = [a-zA-Z0-9_@]+ { return text() }

_ "whitespace"
  = [ \t]
