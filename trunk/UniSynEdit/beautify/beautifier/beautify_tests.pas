unit beautify_tests;

interface
procedure run_beautifier_tests();
implementation
uses jsbeautify, SysUtils, Classes;
type
  EExpectationException = class(Exception);

var
    flags:record
      indent_size:integer;
      indent_char:char;
      preserve_newlines:boolean;
      space_after_anon_function:boolean;
      braces_on_own_line :boolean;
      keep_array_indentation :boolean;
    end;
    sl:TStringList;

function toUnix(input:string):string;
begin
  result:=StringReplace(input, #13#10, #10, [rfReplaceAll]);
end;

procedure expect(input, expected:string);
var output:string;
begin
  output:= js_beautify(
  input,
  flags.indent_size,
  flags.indent_char,
  flags.preserve_newlines,
  0,
  0,
  flags.space_after_anon_function,
  flags.braces_on_own_line,
  flags.keep_array_indentation
  );
  if toUnix(output) <> toUnix(expected) then
    raise EExpectationException.Create('Input:`'#10+input+#10'` Expected:`'#10+expected+#10'`, but get:`'#10+output+#10'`');
end;

// test the input on beautifier with the current flag settings
// does not check the indentation / surroundings as bt() does
procedure test_fragment(input:string; expected:string='');
begin
    if expected='' then expected := input;
    expect(input, expected);
end;



// test the input on beautifier with the current flag settings
// test both the input as well as { input } wrapping
procedure bt(input:string; expectation:string = '');
var wrapped_input, wrapped_expectation:string;
i:Integer;
begin
    if expectation='' then expectation := input;
    test_fragment(input, expectation);

    // test also the returned indentation
    // e.g if input = "asdf();"
    // then test that this remains properly formatted as well:
    // {
    //     asdf();
    //     indent;
    // }

    if (flags.indent_size = 4) and (input<>'') then begin
        wrapped_input := '{'#10+ input + #10'foo=bar;}';
        Sl.text:=expectation;
        for i:=0 to sl.count -1 do
          if sl[i]<>'' then
            sl[i]:='    '+sl[i];
        wrapped_expectation := '{'#10 + Sl.text + '    foo = bar;'#10'}';
//      wrapped_expectation = '{\n' + expectation.replace(/^(.+)$/mg, '    $1') + '\n    foo = bar;\n}';
        test_fragment(wrapped_input, wrapped_expectation);
    end;

end;

// test the input on beautifier with the current flag settings,
// but dont't
procedure bt_braces(input, expectation:string);
    var braces_ex:Boolean;
begin
    braces_ex := flags.braces_on_own_line;
    flags.braces_on_own_line := true;
    bt(input, expectation);
    flags.braces_on_own_line := braces_ex;
end;

procedure run_beautifier_tests();
begin
    flags.indent_size       := 4;
    flags.indent_char       := ' ';
    flags.preserve_newlines := true;
    flags.space_after_anon_function := true;
    flags.keep_array_indentation := false;
    flags.braces_on_own_line := false;
    sl:=TStringList.Create();
    sl.Delimiter:=#10;
    bt('');
    bt('return .5');
    bt('a        =          1', 'a = 1');
    bt('a=1', 'a = 1');
    bt('a();'#10#10'b();');
    bt('var a = 1 var b = 2', 'var a = 1'#10'var b = 2');
    bt('var a=1, b=c[d], e=6;', 'var a = 1,'#10'    b = c[d],'#10'    e = 6;');
    bt('a = " 12345 "');
    bt('a = '' 12345 ''');
    bt('if (a == 1) b = 2;', 'if (a == 1) b = 2;');
    bt('if(1){2}else{3}', 'if (1) {'#10'    2'#10'} else {'#10'    3'#10'}');
    bt('if(1||2);', 'if (1 || 2);');
    bt('(a==1)||(b==2)', '(a == 1) || (b == 2)');
    bt('var a = 1 if (2) 3;', 'var a = 1'#10'if (2) 3;');
    bt('a = a + 1');
    bt('a = a == 1');
    bt('/12345[^678]*9+/.match(a)');
    bt('a /= 5');
    bt('a = 0.5 * 3');
    bt('a *= 10.55');              
    bt('a < .5');
    bt('a <= .5');
    bt('a<.5', 'a < .5');
    bt('a<=.5', 'a <= .5');
    bt('a = 0xff;');
    bt('a=0xff+4', 'a = 0xff + 4');
    bt('a = [1, 2, 3, 4]');
    bt('F*(g/=f)*g+b', 'F * (g /= f) * g + b');
    bt('a.b({c:d})', 'a.b({'#10'    c: d'#10'})');
    bt('a.b'#10'('#10'{'#10'c:'#10'd'#10'}'#10')', 'a.b({'#10'    c: d'#10'})');
    bt('a=!b', 'a = !b');
    bt('a?b:c', 'a ? b : c');
    bt('a?1:2', 'a ? 1 : 2');
    bt('a?(b):c', 'a ? (b) : c');
    bt('x={a:1,b:w=="foo"?x:y,c:z}', 'x = {'#10'    a: 1,'#10'    b: w == "foo" ? x : y,'#10'    c: z'#10'}');
    bt('x=a?b?c?d:e:f:g;', 'x = a ? b ? c ? d : e : f : g;');
    bt('x=a?b?c?d:{e1:1,e2:2}:f:g;', 'x = a ? b ? c ? d : {'#10'    e1: 1,'#10'    e2: 2'#10'} : f : g;');
    bt('function void(void) {}');
    bt('if(!a)foo();', 'if (!a) foo();');
    bt('a=~a', 'a = ~a');  
    bt('a;/*comment*/b;', 'a; /*comment*/'#10'b;');
    bt('a;/* comment */b;', 'a; /* comment */'#10'b;');
    test_fragment('a;/*'#10'comment'#10'*/b;', 'a;'#10'/*'#10'comment'#10'*/'#10'b;'); // simple comments don't get touched at all
    bt('a;/**'#10'* javadoc'#10'*/b;', 'a;'#10'/**'#10' * javadoc'#10' */'#10'b;');
    bt('if(a)break;', 'if (a) break;');
    bt('if(a){break}', 'if (a) {'#10'    break'#10'}');
    bt('if((a))foo();', 'if ((a)) foo();');
    bt('for(var i=0;;)', 'for (var i = 0;;)');
    bt('a++;', 'a++;');
    bt('for(;;i++)', 'for (;; i++)');
    bt('for(;;++i)', 'for (;; ++i)');
    bt('return(1)', 'return (1)');
    bt('try{a();}catch(b){c();}finally{d();}', 'try {'#10'    a();'#10'} catch (b) {'#10'    c();'#10'} finally {'#10'    d();'#10'}');
    bt('(xx)()'); // magic function call
    bt('a[1]()'); // another magic function call
    bt('if(a){b();}else if(c) foo();', 'if (a) {'#10'    b();'#10'} else if (c) foo();');
    bt('switch(x) {case 0: case 1: a(); break; default: break}', 'switch (x) {'#10'case 0:'#10'case 1:'#10'    a();'#10'    break;'#10'default:'#10'    break'#10'}');
    bt('switch(x){case -1:break;case !y:break;}', 'switch (x) {'#10'case -1:'#10'    break;'#10'case !y:'#10'    break;'#10'}');
    bt('a !== b');
    bt('if (a) b(); else c();', 'if (a) b();'#10'else c();');
    bt('// comment'#10'(function something() {})'); // typical greasemonkey start
    bt('{'#10''#10'    x();'#10''#10'}'); // was: duplicating newlines
    bt('if (a in b) foo();');
    //bt('var a, b');
    bt('{a:1, b:2}', '{'#10'    a: 1,'#10'    b: 2'#10'}');
    bt('a={1:[-1],2:[+1]}', 'a = {'#10'    1: [-1],'#10'    2: [+1]'#10'}');
    bt('var l = {''a'':''1'', ''b'':''2''}', 'var l = {'#10'    ''a'': ''1'','#10'    ''b'': ''2'''#10'}');
    bt('if (template.user[n] in bk) foo();');
    bt('{{}/z/}', '{'#10'    {}'#10'    /z/'#10'}');
    bt('return 45', 'return 45');
    bt('If[1]', 'If[1]');
    bt('Then[1]', 'Then[1]');
    bt('a = 1e10', 'a = 1e10');
    bt('a = 1.3e10', 'a = 1.3e10');
    bt('a = 1.3e-10', 'a = 1.3e-10');
    bt('a = -1.3e-10', 'a = -1.3e-10');
    bt('a = 1e-10', 'a = 1e-10');
    bt('a = e - 10', 'a = e - 10'); 
    bt('a = 11-10', 'a = 11 - 10');
    bt('a = 1;// comment'#10'', 'a = 1; // comment');
    bt('a = 1; // comment'#10'', 'a = 1; // comment');
    bt('a = 1;'#10' // comment'#10, 'a = 1;'#10'// comment');

    bt('if (a) {'#10'    do();'#10'}'); // was: extra space appended
    bt('if'#10'(a)'#10'b();', 'if (a) b();'); // test for proper newline removal

    bt('if (a) {'#10'// comment'#10'}else{'#10'// comment'#10'}', 'if (a) {'#10'    // comment'#10'} else {'#10'    // comment'#10'}'); // if/else statement with empty body
    bt('if (a) {'#10'// comment'#10'// comment'#10'}', 'if (a) {'#10'    // comment'#10'    // comment'#10'}'); // multiple comments indentation
    bt('if (a) b() else c();', 'if (a) b()'#10'else c();');
    bt('if (a) b() else if c() d();', 'if (a) b()'#10'else if c() d();');

    bt('{}');
    bt('{'#10''#10'}');
    bt('do { a(); } while ( 1 );', 'do {'#10'    a();'#10'} while (1);');
    bt('do {} while (1);');
    bt('do {'#10'} while (1);', 'do {} while (1);');
    bt('do {'#10''#10'} while (1);');
    bt('var a = x(a, b, c)');
    bt('delete x if (a) b();', 'delete x'#10'if (a) b();');
    bt('delete x[x] if (a) b();', 'delete x[x]'#10'if (a) b();');
    bt('for(var a=1,b=2)', 'for (var a = 1, b = 2)');
    bt('for(var a=1,b=2,c=3)', 'for (var a = 1, b = 2, c = 3)');
    bt('for(var a=1,b=2,c=3;d<3;d++)', 'for (var a = 1, b = 2, c = 3; d < 3; d++)');
    bt('function x(){(a||b).c()}', 'function x() {'#10'    (a || b).c()'#10'}');
    bt('function x(){return - 1}', 'function x() {'#10'    return -1'#10'}');
    bt('function x(){return ! a}', 'function x() {'#10'    return !a'#10'}');

    // a common snippet in jQuery plugins
    bt('settings = $.extend({},defaults,settings);', 'settings = $.extend({}, defaults, settings);');

    bt('{xxx;}()', '{'#10'    xxx;'#10'}()');

    bt('a = ''a'''#10'b = ''b''');
    bt('a = /reg/exp');
    bt('a = /reg/');
    bt('/abc/.test()');
    bt('/abc/i.test()');
    bt('{/abc/i.test()}', '{'#10'    /abc/i.test()'#10'}');
    bt('var x=(a)/a;', 'var x = (a) / a;');

    bt('x != -1', 'x != -1');

    bt('for (; s-->0;)', 'for (; s-- > 0;)');
    bt('for (; s++>0;)', 'for (; s++ > 0;)');
    bt('a = s++>s--;', 'a = s++ > s--;');
    bt('a = s++>--s;', 'a = s++ > --s;');

    bt('{x=#1=[]}', '{'#10'    x = #1=[]'#10'}');
    bt('{a:#1={}}', '{'#10'    a: #1={}'#10'}');
    bt('{a:#1#}', '{'#10'    a: #1#'#10'}');

    test_fragment('{a:1},{a:2}', '{'#10'    a: 1'#10'}, {'#10'    a: 2'#10'}');
    test_fragment('var ary=[{a:1}, {a:2}];', 'var ary = [{'#10'    a: 1'#10'},'#10'{'#10'    a: 2'#10'}];');

    test_fragment('{a:#1', '{'#10'    a: #1'); // incomplete
    test_fragment('{a:#', '{'#10'    a: #'); // incomplete

    test_fragment('}}}', '}'#10'}'#10'}'); // incomplete

    test_fragment('<!--'#10'void();'#10'// -->', '<!--'#10'void();'#10'// -->');

    test_fragment('a=/regexp', 'a = /regexp'); // incomplete regexp

    bt('{a:#1=[],b:#1#,c:#999999#}', '{'#10'    a: #1=[],'#10'    b: #1#,'#10'    c: #999999#'#10'}');

    bt('a = 1e+2');
    bt('a = 1e-2');
    bt('do{x()}while(a>1)', 'do {'#10'    x()'#10'} while (a > 1)');

    bt('x(); /reg/exp.match(something)', 'x();'#10'/reg/exp.match(something)');

    test_fragment('something();(', 'something();'#10'(');

    bt('function namespace::something()');

    test_fragment('<!--'#10'something();'#10'-->', '<!--'#10'something();'#10'-->');
    test_fragment('<!--'#10'if(i<0){bla();}'#10'-->', '<!--'#10'if (i < 0) {'#10'    bla();'#10'}'#10'-->');

    test_fragment('<!--'#10'something();'#10'-->'#10'<!--'#10'something();'#10'-->', '<!--'#10'something();'#10'-->'#10'<!--'#10'something();'#10'-->');
    test_fragment('<!--'#10'if(i<0){bla();}'#10'-->'#10'<!--'#10'if(i<0){bla();}'#10'-->', '<!--'#10'if (i < 0) {'#10'    bla();'#10'}'#10'-->'#10'<!--'#10'if (i < 0) {'#10'    bla();'#10'}'#10'-->');

    bt('{foo();--bar;}', '{'#10'    foo();'#10'    --bar;'#10'}');
    bt('{foo();++bar;}', '{'#10'    foo();'#10'    ++bar;'#10'}');
    bt('{--bar;}', '{'#10'    --bar;'#10'}');
    bt('{++bar;}', '{'#10'    ++bar;'#10'}');

    // regexps
    bt('a(/abc\/\/def/);b()', 'a(/abc\/\/def/);'#10'b()');
    bt('a(/a[b\\[\\]c]d/);b()', 'a(/a[b\\[\\]c]d/);'#10'b()');
    test_fragment('a(/a[b\\[', 'a(/a[b\\['); // incomplete char class
    // allow unescaped / in char classes
    bt('a(/[a/b]/);b()', 'a(/[a/b]/);'#10'b()');

    bt('a=[[1,2],[4,5],[7,8]]', 'a = ['#10'    [1, 2],'#10'    [4, 5],'#10'    [7, 8]'#10']');
    bt('a=[a[1],b[4],c[d[7]]]', 'a = [a[1], b[4], c[d[7]]]');
    bt('[1,2,[3,4,[5,6],7],8]', '[1, 2, [3, 4, [5, 6], 7], 8]');

    bt('[[[''1'',''2''],[''3'',''4'']],[[''5'',''6'',''7''],[''8'',''9'',''0'']],[[''1'',''2'',''3''],[''4'',''5'',''6'',''7''],[''8'',''9'',''0'']]]',
        '['#10'    ['#10'        [''1'', ''2''],'#10'        [''3'', ''4'']'#10'    ],'#10'    ['#10'        [''5'', ''6'', ''7''],'#10'        [''8'', ''9'', ''0'']'#10'    ],'#10'    ['#10'        [''1'', ''2'', ''3''],'#10'        [''4'', ''5'', ''6'', ''7''],'#10'        [''8'', ''9'', ''0'']'#10'    ]'#10']');

    bt('{[x()[0]];indent;}', '{'#10'    [x()[0]];'#10'    indent;'#10'}');

    bt('return ++i', 'return ++i');
    bt('return !!x', 'return !!x');
    bt('return !x', 'return !x');
    bt('return [1,2]', 'return [1, 2]');
    bt('return;', 'return;');
    bt('return'#10'func', 'return'#10'func');
    bt('catch(e)', 'catch (e)');

    bt('var a=1,b={foo:2,bar:3},c=4;', 'var a = 1,'#10'    b = {'#10'        foo: 2,'#10'        bar: 3'#10'    },'#10'    c = 4;');
    bt_braces('var a=1,b={foo:2,bar:3},c=4;', 'var a = 1,'#10'    b ='#10'    {'#10'        foo: 2,'#10'        bar: 3'#10'    },'#10'    c = 4;');

    // inline comment
    bt('function x(/*int*/ start, /*string*/ foo)', 'function x( /*int*/ start, /*string*/ foo)');

    // javadoc comment
    bt('/**'#10'* foo'#10'*/', '/**'#10' * foo'#10' */');
    bt('    /**'#10'     * foo'#10'     */', '/**'#10' * foo'#10' */');
    bt('{'#10'/**'#10'* foo'#10'*/'#10'}', '{'#10'    /**'#10'     * foo'#10'     */'#10'}');

    bt('var a,b,c=1,d,e,f=2;', 'var a, b, c = 1,'#10'    d, e, f = 2;');
    bt('var a,b,c=[],d,e,f=2;', 'var a, b, c = [],'#10'    d, e, f = 2;');
    bt('function () {'#10'    var a, b, c, d, e = [],'#10'        f;'#10'}');

    bt('x();'#10''#10'function(){}', 'x();'#10''#10'function () {}');

    bt('do/regexp/;'#10'while(1);', 'do /regexp/;'#10'while (1);'); // hmmm

    bt('var a = a,'#10'a;'#10'b = {'#10'b'#10'}', 'var a = a,'#10'    a;'#10'b = {'#10'    b'#10'}');

    bt('var a = a,'#10'    /* c */'#10'    b;');
    bt('var a = a,'#10'    // c'#10'    b;');

    bt('foo.(''bar'');'); // weird element referencing


    bt('if (a) a()'#10'else b()'#10'newline()');
    bt('if (a) a()'#10'newline()');

    flags.space_after_anon_function := true;

    test_fragment('// comment 1'#10'(function()', '// comment 1'#10'(function ()'); // typical greasemonkey start
    bt('var a1, b1, c1, d1 = 0, c = function() {}, d = '''';', 'var a1, b1, c1, d1 = 0,'#10'    c = function () {},'#10'    d = '''';');
    bt('var o1=$.extend(a);function(){alert(x);}', 'var o1 = $.extend(a);'#10''#10'function () {'#10'    alert(x);'#10'}');

    flags.space_after_anon_function := false;  

    test_fragment('// comment 2'#10'(function()'); // typical greasemonkey start
    bt('var a2, b2, c2, d2 = 0, c = function() {}, d = '''';', 'var a2, b2, c2, d2 = 0,'#10'    c = function() {},'#10'    d = '''';');
    bt('var o2=$.extend(a);function(){alert(x);}', 'var o2 = $.extend(a);'#10''#10'function() {'#10'    alert(x);'#10'}');

    bt('{''x'':[{''a'':1,''b'':3},7,8,8,8,8,{''b'':99},{''a'':11}]}', '{'#10'    ''x'': [{'#10'        ''a'': 1,'#10'        ''b'': 3'#10'    },'#10'    7, 8, 8, 8, 8,'#10'    {'#10'        ''b'': 99'#10'    },'#10'    {'#10'        ''a'': 11'#10'    }]'#10'}');

    bt('{''1'':{''1a'':''1b''},''2''}', '{'#10'    ''1'': {'#10'        ''1a'': ''1b'''#10'    },'#10'    ''2'''#10'}');
    bt('{a:{a:b},c}', '{'#10'    a: {'#10'        a: b'#10'    },'#10'    c'#10'}');

    bt('{[y[a]];keep_indent;}', '{'#10'    [y[a]];'#10'    keep_indent;'#10'}');

    bt('if (x) {y} else { if (x) {y}}', 'if (x) {'#10'    y'#10'} else {'#10'    if (x) {'#10'        y'#10'    }'#10'}');

    bt('if (foo) one()'#10'two()'#10'three()');
    bt('if (1 + foo() && bar(baz()) / 2) one()'#10'two()'#10'three()');
    bt('if (1 + foo() && bar(baz()) / 2) one();'#10'two();'#10'three();');

    flags.indent_size := 1;
    flags.indent_char := ' ';
    bt('{ one_char() }', '{'#10' one_char()'#10'}');

    bt('var a,b=1,c=2', 'var a, b = 1,'#10'    c = 2');

    flags.indent_size := 4;
    flags.indent_char := ' ';
    bt('{ one_char() }', '{'#10'    one_char()'#10'}');

    flags.indent_size := 1;
    flags.indent_char := #9;
    bt('{ one_char() }', '{'#10#9'one_char()'#10'}');
    bt('x = a ? b : c; x;', 'x = a ? b : c;'#10'x;');

    flags.indent_size := 4;
    flags.indent_char := ' ';

    flags.preserve_newlines := false;
    bt('var'#10'a=dont_preserve_newlines;', 'var a = dont_preserve_newlines;');

    // make sure the blank line between function definitions stays
    // even when preserve_newlines = false
    bt('function foo() {'#10'    return 1;'#10'}'#10''#10'function foo() {'#10'    return 1;'#10'}');
    bt('function foo() {'#10'    return 1;'#10'}'#10'function foo() {'#10'    return 1;'#10'}',
       'function foo() {'#10'    return 1;'#10'}'#10''#10'function foo() {'#10'    return 1;'#10'}'
      );
    bt('function foo() {'#10'    return 1;'#10'}'#10''#10''#10'function foo() {'#10'    return 1;'#10'}',
       'function foo() {'#10'    return 1;'#10'}'#10''#10'function foo() {'#10'    return 1;'#10'}'
      );


    flags.preserve_newlines := true;
    bt('var'#10'a=do_preserve_newlines;', 'var'#10'a = do_preserve_newlines;');

    flags.keep_array_indentation := true;

    bt('var x = [{}'#10']', 'var x = [{}'#10']');
    bt('var x = [{foo:bar}'#10']', 'var x = [{'#10'    foo: bar'#10'}'#10']');
    bt('a = [''something'','#10'''completely'','#10'''different''];'#10'if (x);', 'a = [''something'','#10'    ''completely'','#10'    ''different''];'#10'if (x);');
    bt('a = [''a'',''b'',''c'']', 'a = [''a'', ''b'', ''c'']');
    bt('a = [''a'',   ''b'',''c'']', 'a = [''a'', ''b'', ''c'']');

    bt('x = [{''a'':0}]', 'x = [{'#10'    ''a'': 0'#10'}]');

    bt('{a([[a1]], {b;});}', '{'#10'    a([[a1]], {'#10'        b;'#10'    });'#10'}');

    bt('a = //comment'#10'/regex/;');

    test_fragment('/*'#10' * X'#10' */');
    test_fragment('/*'#13#10' * X'#13#10' */', '/*'#10' * X'#10' */');

    bt('if (a)'#10'{'#10'b;'#10'}'#10'else'#10'{'#10'c;'#10'}', 'if (a) {'#10'    b;'#10'} else {'#10'    c;'#10'}');

    flags.braces_on_own_line := true;

    bt('if (a)'#10'{'#10'b;'#10'}'#10'else'#10'{'#10'c;'#10'}', 'if (a)'#10'{'#10'    b;'#10'}'#10'else'#10'{'#10'    c;'#10'}');
    test_fragment('if (foo) {', 'if (foo)'#10'{');
    test_fragment('foo {', 'foo'#10'{');
    test_fragment('return {', 'return {'); // return needs the brace. maybe something else as well: feel free to report.
    // test_fragment('return'#10'{', 'return'#10'{'); // can't support this, but that's an improbable and extreme case anyway.
    test_fragment('return;'#10'{', 'return;'#10'{');
    Sl.free;
end;

end.
