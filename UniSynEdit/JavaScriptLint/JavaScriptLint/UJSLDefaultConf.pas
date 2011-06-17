unit UJSLDefaultConf;

interface

const
  JSLOptionsCount = 45;
type
  TJSLConfEntry = record
    checked: Boolean;
    key: string;
    desc: string;
  end;
  TJSLConf = array[0..JSLOptionsCount - 1] of TJSLConfEntry;

function JSLConfEntry(checked: Boolean; key: string; desc: string):
  TJSLConfEntry;
var
  DefaultConf: TJSLConf;

implementation

function JSLConfEntry(checked: Boolean; key: string; desc: string):
  TJSLConfEntry;
begin
  Result.checked := checked;
  Result.key := key;
  Result.desc := desc;
end;
initialization

  DefaultConf[0] := JSLConfEntry(True, 'no_return_value',
    'function {0} does not always return a value');
  DefaultConf[1] := JSLConfEntry(True, 'duplicate_formal',
    'duplicate formal argument {0}');
  DefaultConf[2] := JSLConfEntry(True, 'equal_as_assign',
    'test for equality (==) mistyped as assignment (=)?{0}');
  DefaultConf[3] := JSLConfEntry(True, 'var_hides_arg',
    'variable {0} hides argument');
  DefaultConf[4] := JSLConfEntry(True, 'redeclared_var',
    'redeclaration of {0} {1}');
  DefaultConf[5] := JSLConfEntry(True, 'anon_no_return_value',
    'anonymous function does not always return a value');
  DefaultConf[6] := JSLConfEntry(True, 'missing_semicolon',
    'missing semicolon');
  DefaultConf[7] := JSLConfEntry(True, 'meaningless_block',
    'meaningless block; curly braces have no impact');
  DefaultConf[8] := JSLConfEntry(True, 'comma_separated_stmts',
    'multiple statements separated by commas (use semicolons?)');
  DefaultConf[9] := JSLConfEntry(True, 'unreachable_code', 'unreachable code');
  DefaultConf[10] := JSLConfEntry(True, 'missing_break',
    'missing break statement');
  DefaultConf[11] := JSLConfEntry(True, 'missing_break_for_last_case',
    'missing break statement for last case in switch');
  DefaultConf[12] := JSLConfEntry(True, 'comparison_type_conv',
    'comparisons against null, 0, true, false, or an empty string allowing implicit type conversion (use === or !==)');
  DefaultConf[13] := JSLConfEntry(True, 'inc_dec_within_stmt',
    'increment (++) and decrement (--) operators used as part of greater statement');
  DefaultConf[14] := JSLConfEntry(True, 'useless_void',
    'use of the void type may be unnecessary (void is always undefined)');
  DefaultConf[15] := JSLConfEntry(True, 'multiple_plus_minus',
    'unknown order of operations for successive plus (e.g. x+++y) or minus (e.g. x---y) signs');
  DefaultConf[16] := JSLConfEntry(True, 'use_of_label', 'use of label');
  DefaultConf[17] := JSLConfEntry(False, 'block_without_braces',
    'block statement without curly braces');
  DefaultConf[18] := JSLConfEntry(True, 'leading_decimal_point',
    'leading decimal point may indicate a number or an object member');
  DefaultConf[19] := JSLConfEntry(True, 'trailing_decimal_point',
    'trailing decimal point may indicate a number or an object member');
  DefaultConf[20] := JSLConfEntry(True, 'octal_number',
    'leading zeros make an octal number');
  DefaultConf[21] := JSLConfEntry(True, 'nested_comment', 'nested comment');
  DefaultConf[22] := JSLConfEntry(True, 'misplaced_regex',
    'regular expressions should be preceded by a left parenthesis, assignment, colon, or comma');
  DefaultConf[23] := JSLConfEntry(True, 'ambiguous_newline',
    'unexpected end of line; it is ambiguous whether these lines are part of the same statement');
  DefaultConf[24] := JSLConfEntry(True, 'empty_statement',
    'empty statement or extra semicolon');
  DefaultConf[25] := JSLConfEntry(False, 'missing_option_explicit',
    'the "option explicit" control comment is missing');
  DefaultConf[26] := JSLConfEntry(True, 'partial_option_explicit',
    'the "option explicit" control comment, if used, must be in the first script tag');
  DefaultConf[27] := JSLConfEntry(True, 'dup_option_explicit',
    'duplicate "option explicit" control comment');
  DefaultConf[28] := JSLConfEntry(True, 'useless_assign', 'useless assignment');
  DefaultConf[29] := JSLConfEntry(True, 'ambiguous_nested_stmt',
    'block statements containing block statements should use curly braces to resolve ambiguity');
  DefaultConf[30] := JSLConfEntry(True, 'ambiguous_else_stmt',
    'the else statement could be matched with one of multiple if statements (use curly braces to indicate intent)');
  DefaultConf[31] := JSLConfEntry(True, 'missing_default_case',
    'missing default case in switch statement');
  DefaultConf[32] := JSLConfEntry(True, 'duplicate_case_in_switch',
    'duplicate case in switch statements');
  DefaultConf[33] := JSLConfEntry(True, 'default_not_at_end',
    'the default case is not at the end of the switch statement');
  DefaultConf[34] := JSLConfEntry(True, 'legacy_cc_not_understood',
    'couldn''t understand control comment using /*@keyword@*/ syntax');
  DefaultConf[35] := JSLConfEntry(True, 'jsl_cc_not_understood',
    'couldn''t understand control comment using /*jsl:keyword*/ syntax');
  DefaultConf[36] := JSLConfEntry(True, 'useless_comparison',
    'useless comparison; comparing identical expressions');
  DefaultConf[37] := JSLConfEntry(True, 'with_statement',
    'with statement hides undeclared variables; use temporary variable instead');
  DefaultConf[38] := JSLConfEntry(True, 'trailing_comma_in_array',
    'extra comma is not recommended in array initializers');
  DefaultConf[39] := JSLConfEntry(True, 'assign_to_function_call',
    'assignment to a function call');
  DefaultConf[40] := JSLConfEntry(True, 'parseint_missing_radix',
    'parseInt missing radix parameter');
  DefaultConf[41] := JSLConfEntry(True, 'legacy_control_comments',
    'legacy control comments are enabled by default for backward compatibility.');
  DefaultConf[42] := JSLConfEntry(False, 'jscript_function_extensions',
    'JScript Function Extensions');
  DefaultConf[43] := JSLConfEntry(False, 'always_use_option_explicit',
    'By default, "option explicit" is enabled on a per-file basis.');
  DefaultConf[44] := JSLConfEntry(True, 'lambda_assign_requires_semicolon',
    'By default, assignments of an anonymous function to a variable or property (such as a function prototype) must be followed by a semicolon.');
end.

