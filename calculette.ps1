Import-Module ./MicroParser.psm1

#Calculette20:
# - Ajout de la possibilite d'utiliser
#   f(x,y) = x + y
#   en plus de f(x) = _(y) = x + y
#   (en cours) Toujours en cours ...

#Calculette19:
# - Ajout de l'operateur FOLD (~)
#   + On ajoute Vide (dans FOLD (temporaire car il faudrait avoir un mot reserve))
# - Ajout de l'operateur ADDARRAY (++)
# - On continue le refactoring

#Calculette18:
# - Refactoring, utilisation de New-ASTError en lieu et place d'un PSObject
#   Idem pour New-ASTInteger

#Calculette17:
# - Ajout des fonction \+ \* et \@
#           qui sont simplement les pendants des operateurs + * et @

#Calculette16:
#  - Ajout de l'operateur (..), pour avoir a..b -> liste des chiffres de a jusqu'a b
#  - Integration de New-LexerID dans le code (il existe aussi dans le module) pour
#          ajouter les identifiants etendus (comme \+ \- ...)

#Calculette15:
#  - Ajout de l'operateur (,) tel que a,b,c,d -> liste de 4 elements

#Calculette14:
#  - Refactoring
#  - Ajout de l'operateur (#) tel que f # 3 -> liste des 3 premiers elements
#  - Ajout de l'operateur (@) applique tel que f@3 -> f(3)

#Calculette13:
#  - Ajout de l'operateur (|) tel que f(x) equivaut a x|f (en cours)

#Calculette12:
#  - Debug de CalculADDITION

#Calculette11:
#  - Ajout de l'operateur REDUCE (&)
#  - Transformer les calculs en resultat !

#Calculette10: Ajout de l'operateur MAP (%)

#Calculette9: Pouvoir utiliser f(0) = quelque chose
#sans avoir precedemment definit f(x)

#Calculette8: Tansformer [...?...:...]
#En operateurs
#operateur ? et operateur :

#Calculette7: Ajout memorisation function
# exemple f(0) = 1
# - Modification parser AssignationFunction pour inclure le type integer dans la definition de function
# - Modification du context pour inclure la memorisation
#       + Context.Memory

#Calculette4: Modification du context pour inclure:
# Context.Element.Type
# Context.Element.Value
# Context.Parent

function New-LexerID{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $index = $In.Index
        $txt   = $In.Text
        [string]$Value = ''

        #Petit HACK pour les extended ID!
        #if($txt[$index] -eq '\'){
        if($txt[$index] -eq '\' -or $txt[$index] -eq "'"){
            $n = $txt[$index + 1]
            if($n -eq '+' -or $n -eq '*' -or $n -eq '-' -or $n -eq '/' -or $n -eq '@' -or $n -eq '.' -or $n -eq '?' -or $n -eq '=' -or $n -ceq 'S' -or $n -eq '|' -or $n -ceq 'K' -or $n -ceq 'Z' -or $n -ceq 'z' -or $n -ceq 'I' -or $n -eq '~' -or $n -eq '&' -or $n -eq '%' -or $n -eq 'C' -or $n -eq 'O' -or $n -eq 'W' -or $n -eq 'P' -or $n -eq 'R' -or $n -eq 'B'){
                $Value = $txt[$index] + $txt[$index + 1]
            }
            return [PSCustomObject]@{
                Text  = $In.Text
                Index = $index + 2
                Value = $Value
            }
        }
        if($txt[$index] -eq '{' -and $txt[$index+1] -eq '}'){
            return [PSCustomObject]@{
                Text  = $In.Text
                Index = $index + 2
                Value = $txt[$index] + $txt[$index + 1]
            }
        }
        #Fin du HACK

        if($txt[$index] -notmatch "[a-zA-Z_!']"){ return }
        #BUG?: le caractere ']' passe a travers le notmatch
        if($txt[$index] -eq ']'){ return }
#Write-Host "LEXERID: Value '$($txt[$index])' OK"
        $Value = $txt[$index]
        for($i = 1; $i -lt $txt.Length;$i++){
            if($txt[$index + $i] -notmatch "[a-zA-z0-9_!']"){ break }
            #BUG?: le caractere ']' passe a travers le notmatch
            if($txt[$index + $i] -eq ']'){ break }
#Write-Host "LEXERID: Value '$($txt[$index + $i])' OK"
            $Value += $txt[$index + $i]
        }
        if($Value -eq ''){ return }

        return [PSCustomObject]@{
            Text  = $In.Text
            Index = $index + $i
            Value = $Value
        }
    }.GetNewClosure()
}
function DoParseExecutable{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        $In | &((DoParseSemicolon)  |New-ParserAnd (Skip-Parser (New-ParserEOL)) -Transformer {
            param($left, $In, $right)
            [PSCustomObject]@{
                Text  = $left.Text
                Index = $right.Index
                Value = $left.Value
            }
        })
    }.GetNewClosure()
}

function DoParseAssignation{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        #Une assignation est de la forme ID = calcul
        $EQUAL  = New-ParserChar -Char '='
        $ASSIGN = (New-ParserID) | New-ParserAnd $EQUAL -Transformer {
            param($left, $In, $right)
            [PSCustomObject]@{
                Text  = $left.Text
                Index = $right.Index
                Value = $left.Value
            }
        }
        $Assignation = $ASSIGN | New-ParserAnd (DoParseSum) -Transformer {
            param($left, $In, $right)
            [PSCustomObject]@{
                Text  = $left.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'ASSIGNATION'
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }
        $In |&$Assignation
    }.GetNewClosure()
}

function DoParseAssigationFunction {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        
        $OPENPAREN  = New-ParserChar -Char '('
        $CLOSEPAREN = New-ParserChar -Char ')'
        $EQUAL      = New-ParserChar -Char '='
        $COMMA      = New-ParserChar -Char ','

        $SKIPRIGHT  = {
            param($left, $In, $right)
            [PSCustomObject]@{
                Text  = $left.Text
                Index = $right.Index
                Value = $left.Value
            }
        }


        #Une fonction est de la forme:
        #f(x) = ... (x est un identifiant)
        #f(3) = ... (x est un numerique)
        #f("a") =   (x est un string)
        $Id_Num_Ou_String = (New-ParserID | New-ParserOr (New-ParserInteger) |New-ParserOr (New-ParserString))

        $Plusieurs_Id_Num_Ou_String =
            $Id_Num_Ou_String | New-ParserStar (
                $COMMA | New-ParserAnd  $Id_Num_Ou_String) -Transformer {}

        #Par defaut ParserAnd fait Skip du left
        $ASSIGN = (New-ParserID) | New-ParserAnd $OPENPAREN -Transformer $SKIPRIGHT |
                    New-ParserAnd $Id_Num_Ou_String -Transformer {
                        param($left, $In, $right)
                        [PSCustomObject]@{
                            Text  = $right.Text
                            Index = $right.Index
                            Value = [PSCustomObject]@{
                                Left  = $left
                                Right = $right
                            }
                        }
                    } |
                    New-ParserAnd ($CLOSEPAREN) -Transformer $SKIPRIGHT |
                    New-ParserAnd $EQUAL -Transformer $SKIPRIGHT | New-ParserAnd (DoParseSum) -Transformer {
                        param($left, $In, $right)
                        [PSCustomObject]@{
                            Text  = $right.Text
                            Index = $right.Index
                            Value = [PSCustomObject]@{
                                Type  = 'ASSIGNATIONFUNCTION'
                                Left  = $left.Value.Left.Value
                                Right = [PSCustomObject]@{
                                    Type       = 'FUNCTION'
                                    Parameters = $left.Value.Right.Value
                                    Body       = $right.Value
                                }
                            }
                        }
                    }

        $In |&$ASSIGN
    }.GetNewClosure()
}


function DoParseSemicolon {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($I, $left, $right)
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'SEMICOLON'
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }
        $ET        = (Get-Item 'function:New-ParserAnd').ScriptBlock
        $Semicolon = New-ParserChar -Char ';'
        $Suite     = (DoParseComma)

        $ZeroOrMoreSums =
            New-ParserStar ($Semicolon |&$ET $Suite -Transformer $operationTransformer)

        $SemicolonParser = $Suite |&$ET $ZeroOrMoreSums

        $In | &$SemicolonParser
    }.GetNewClosure()
}

function DoParseComma {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($I, $left, $right)
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'COMMA'
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }
        $ET        = (Get-Item 'function:New-ParserAnd').ScriptBlock
        $Operator  = New-ParserChar -Char ','
        $Suite     = (DoParseMapReduce)

        $ZeroOrMoreSuite =
            New-ParserStar ($Operator |&$ET $Suite -Transformer $operationTransformer)

        $OperatorParser = $Suite |&$ET $ZeroOrMoreSuite

        $In | &$OperatorParser
    }.GetNewClosure()
}

function DoParseMapReduce {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($I, $left, $right)
            switch ( $I.Value.Value ) {
                '%%' { $type = 'MODULO'          }
                '%'  { $type = 'MAP'             }
                '&'  { $type = 'REDUCE'          }
                '|'  { $type = 'PIPE'            }
                '#'  { $type = 'FIRSTELEMENTS'   }
                '@'  { $type = 'ROND'        }
                '.'  { $type = 'APPLIQUE'        }
                'de' { $type = 'APPLIQUE'        }
                '~'  { $type = 'FOLD'            }
                '++' { $type = 'ADDARRAY'        }
                '`'  { $type = 'OPERATORFUNCTION'}
                '!!' { $type = 'BOUCLE'          }
                '!'  { $type = 'ZIP'             }
                '??' { $type = 'FILTER'          }
            }
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type = $type
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }
        $ET        = (Get-Item 'function:New-ParserAnd').ScriptBlock
#        $Operator = New-ParserOr -LeftParser (New-ParserChar '!') -RightParser ( New-ParserOr -LeftParser (New-ParserChar '`') -RightParser (New-ParserOr -LeftParser (New-ParserWord 'de') -RightParser (New-ParserOr -LeftParser (New-ParserWord '++') -RightParser (New-ParserOr -LeftParser (New-ParserChar '~') -RightParser (New-ParserOr -LeftParser (New-ParserChar '|') -RightParser ( New-ParserOr -LeftParser (New-ParserChar -Char '%') -RightParser (New-ParserOR -LeftParser (New-ParserChar -Char '&') -RightParser (New-ParserOR -LeftParser (New-ParserChar -Char '#') -RightParser (New-ParserChar -Char '@'))) ) )))))
        $Operator = New-ParserOr -LeftParser (New-ParserWord '??') -RightParser( New-ParserOr -LeftParser (New-ParserWord '!!') -RightParser( New-ParserOr -LeftParser (New-ParserWord '%%') -RightParser( New-ParserOr -LeftParser (New-ParserChar '.') -RightParser ( New-ParserOr -LeftParser (New-ParserChar '!') -RightParser ( New-ParserOr -LeftParser (New-ParserChar '`') -RightParser (New-ParserOr -LeftParser (New-ParserWord 'de') -RightParser (New-ParserOr -LeftParser (New-ParserWord '++') -RightParser (New-ParserOr -LeftParser (New-ParserChar '~') -RightParser (New-ParserOr -LeftParser (New-ParserChar '|') -RightParser ( New-ParserOr -LeftParser (New-ParserChar -Char '%') -RightParser (New-ParserOR -LeftParser (New-ParserChar -Char '&') -RightParser (New-ParserOR -LeftParser (New-ParserChar -Char '#') -RightParser (New-ParserChar -Char '@'))) ) )))))))))
        $Suite     = (DoParseQuestionMark)

        $ZeroOrMoreSums =
            New-ParserStar ($Operator |&$ET $Suite -Transformer $operationTransformer)

        $SemicolonParser = $Suite |&$ET $ZeroOrMoreSums

        $In | &$SemicolonParser
    }.GetNewClosure()
}

function DoParseQuestionMark {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($I, $left, $right)
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'QUESTIONMARK'
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }

        $ET           = (Get-Item 'function:New-ParserAnd').ScriptBlock
        $QuestionMark = New-ParserChar -Char '?'
        $Colon        = DoParseColon

        $ZeroOrMoreQuestionMark =
            New-ParserStar ($QuestionMark |&$ET $Colon -Transformer $operationTransformer)

        $QuestionMarkParser = $Colon |&$ET $ZeroOrMoreQuestionMark

        $In | &$QuestionMarkParser
    }.GetNewClosure()
}

function DoParseColon {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($I, $left, $right)
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'COLON'
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }

        $ET    = (Get-Item 'function:New-ParserAnd').ScriptBlock
        $Colon = New-ParserChar -Char ':'
        $Sum   = DoParseIntList

        $ZeroOrMoreSums =
            New-ParserStar ($Colon |&$ET $Sum -Transformer $operationTransformer)

        $ColonParser = $Sum |&$ET $ZeroOrMoreSums

        $In | &$ColonParser
    }.GetNewClosure()
}

function DoParseIntList {
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($I, $left, $right)
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'INTLIST'
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }

        $ET    = (Get-Item 'function:New-ParserAnd').ScriptBlock
        $Operator = New-ParserWord -Word '..'
        $Suite    = DoParseSum

        $ZeroOrMoreSuites =
            New-ParserStar ($Operator |&$ET $Suite -Transformer $operationTransformer)

        $OperatorParser = $Suite |&$ET $ZeroOrMoreSuites

        $In | &$OperatorParser
    }.GetNewClosure()
}
function DoParseSum{
    {
        #Un calcul est de la forme:
		#  Sum     -> Product { ('+' | '-') Product }
		#  Product -> Value { ('*' | '/') Value }
		#  Value   -> [0-9]+ | Variable | '(' Expr ')'
        # cf: https://www.mql5.com/en/articles/8027
        # et: https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

		#  Sum     -> Product { ('+' | '-') Product }
        # Donc Sun et un ET(Product (ET(OR('+','-') Product)))
        $operationTransformer = {
            param($I, $left, $right)
            switch ( $I.Value.Value ) {
                '+' { $type = 'ADDITION'      }
                '-' { $type = 'SOUSTRACTION'  }
                '>' { $type = 'COMPARAISONSUP'}
                '<' { $type = 'COMPARAISONINF'}
            }
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = $type
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }

        $OU = (Get-Item 'function:New-ParserOr').ScriptBlock
        $ET = (Get-Item 'function:New-ParserAnd').ScriptBlock

        $product = DoParseProduct
        $plus  = New-ParserChar -Char '+'
        $minus = New-ParserChar -Char '-'
        $sup   = New-ParserChar -Char '>'
        $inf   = New-ParserChar -Char '<'

        $ZeroOrMoreProducts =
            New-ParserStar (($plus |&$OU $minus |&$OU $sup |&$OU $inf) |&$ET $product -Transformer $operationTransformer)

        $sum = $product |&$ET $ZeroOrMoreProducts
        $In | &$sum
    }.GetNewClosure()
}


function DoParseProduct{
    #Un calcul est de la forme:
    #  Sum     -> Product { ('+' | '-') Product }
    #  Product -> Value { ('*' | '/') Value }
    #  Value   -> [0-9]+ | '(' Expr ')'
    #  Value   -> Assignation | Value
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        #  Product -> Value { ('*' | '/') Value }
        # Donc Sun et un ET(Product (ET(OR('+','-') Product)))
        $operationTransformer = {
            param($In, $left, $right)
            if($In.Value.Value -eq '*'){
                $type = 'MULTIPLICATION'
            }else{
                $type = 'DIVISION'
            }
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = $type
                    Left  = $left.Value
                    Right = $right.Value
                }
            }
        }

        $OU = (Get-Item 'function:New-ParserOr' ).ScriptBlock
        $ET = (Get-Item 'function:New-ParserAnd').ScriptBlock

        $mult   = New-ParserChar '*'
        $div    = New-ParserChar '/'

        $FunctEval = DoParseFunctionEval
        $ZeroOrMoreFunctionEval =
            New-ParserStar (($mult |&$OU $div) |&$ET $FunctEval -Transformer $operationTransformer)

        $product = $FunctEval |&$Et $ZeroOrMoreFunctionEval
        $In | &$product
    }.GetNewClosure()
}

function DoParseFunctionEval{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $operationTransformer = {
            param($In, $left, $right)
            [PSCustomObject]@{
                Text  = $right.Text
                Index = $right.Index
                Value = [PSCustomObject]@{
                    Type  = 'FUNCTIONEVAL'
                    Left  = $left.Value
#                    Right = $right.Value  #Je ne sais pas pourquoi cela ne fonctionne pas
                    Right = $In.Value      #Je ne sais pas pourquoi cela fonctionne !
                }
            }
        }

        $OU          = (Get-Item 'function:New-ParserOr' ).ScriptBlock
        $ET          = (Get-Item 'function:New-ParserAnd').ScriptBlock
        $ENTIER      = (New-ParserInteger)
        $VARIABLE    = (New-ParserID)
        $STRING      = (New-ParserString)
        $OPENPAREN   = New-ParserChar -Char '('
        $CLOSEPAREN  = New-ParserChar -Char ')'

        $ASSIGNATION = (DoParseAssignation) |&$OU (DoParseAssigationFunction)

        $parenthese  = (Skip-Parser (New-ParserChar '(') |&$ET (DoParseSemicolon)) |New-ParserAnd (Skip-Parser (New-ParserChar ')')) -Transformer {
            #param Operator Before After
            param($left, $In, $right)
            [PSCustomObject]@{
                Text  = $left.Text
                Index = $right.Index
                Value = $left.Value
            }
        }

        $Valeur = $ASSIGNATION |&$OU $ENTIER |&$OU $VARIABLE |&$OU $STRING |&$OU $parenthese

        $ZeroOrMoreValeur =
            New-ParserStar ($OPENPAREN |&$ET (DoParseSemicolon) |&$ET (Skip-Parser $CLOSEPAREN) -Transformer $operationTransformer)
        
        $functionEvaluation = $Valeur |&$ET $ZeroOrMoreValeur
        $In | &$functionEvaluation
    }.GetNewClosure()
}

function CreateSimpleFunction {
    param(
        $Context,
        $Operator,
        [Switch]$switch
    )

    $OperatorLeft = [PSCustomObject]@{
        Type  = 'IDENTIFIANT'
        Value = 'x'
    }

    $OperatorRight = [PSCustomObject]@{
        Type  = 'IDENTIFIANT'
        Value = 'y'
    }

    if($switch) { $OperatorLeft, $OperatorRight = $OperatorRight, $OperatorLeft}

    $InnerClosure = [PSCustomObject]@{
        Type = 'CLOSURE'
        Context = [PSCustomObject]@{
            Parent = $null
            Values = $Context
            Memory = @{}
        }
        Parameters = [PSCustomObject]@{Type = 'IDENTIFIANT'; Value = 'y'}
        Body       = [PSCustomObject]@{Type = $Operator; Left = $OperatorLeft; Right = $OperatorRight}
        Value      = $InnerClosure
    }

    $Closure = [PSCustomObject]@{
        Type  = 'CLOSURE'
        Context = [PSCustomObject]@{
            Parent = $null
            Values = $Context
            Memory = @{}
        }
        Parameters = [PSCustomObject]@{Type = 'IDENTIFIANT'; Value = 'x'}
        Body       = $InnerClosure
        Value      = $Closure
    }
    return $Closure
}

function affiche {
  param(
    $value
  )
  Write-Host $value
}

function Object2Text{
  param(
    $object
  )

  if($object.Type -cne 'CLOSURE'){
    return $object.Value
  }

  $memory = $object.Context.Memory
  if($memory.values.Count -eq 0){
    return ""
  }

  $txt = "("
  $memory.values | %{
    $txt += "$(Object2Text $_), "
  }
  $txt = $txt.substring(0, $txt.Length - 2)
  $txt += ")"
  return $txt
}

function Calculette {
    param($Text = "(2+3)*4")
    $Context = [PSCustomObject]@{
        Parent = $null
        Values = @{
            'toto' = New-ASTInteger -Value 13
            'tron' = New-ASTInteger -Value 0
            '_AUTOINIVARIABLE' = New-ASTInteger -Value 0
            'Vide' = New-ASTEnsembleVide
            '{}'   = New-ASTEnsembleVide
        }
    }

    $Initialisation = @(
        "\+(x)=_(y)=x+y"
        "'+(x)=_(y)=y+x"
        "\-(x)=_(y)=x-y"
        "'-(x)=_(y)=y-x"
        "\*(x)=_(y)=x*y"
        "'*(x)=_(y)=y*x"
        "\/(x)=_(y)=x/y"
        "'/(x)=_(y)=y/x"
        "\@(x)=_(y)=(x@y)"
        "'@(x)=_(y)=(y@x)"
        "\|(x)=_(y)=(x|y)"
        "'|(x)=_(y)=(y|x)"
        "\=(x)=_(y)=(x-y?0:1)"
        "\S(f)=_(x)=_(y)=(f(y)(x))"
        "\Z(f)=_(g)=_(h)=_(x)=(g(f de x)(h de x))"
        #"\z(l)=_(x)= ( l(1)( l(0)(x) ) ( l(2)(x) ) ) "
        "\I(x)=x"
        "\K(f)=_(x)=_(y)=f(x)"
        "\C(x)=_(y)=x"
        "'C(x)=_(y)=y"
        "longueur(liste) = (liste ~ ( 0 : ( 1 | \+ | \K ) ) )"
        "\~(liste)=_(accu_fn)= (liste ~ (accu_fn(0) : accu_fn(1) ))"
        "'~(accu_fn)=_(liste)= (liste ~ (accu_fn(0) : accu_fn(1) ))"
        "\&(liste)=_(fn)= (liste & fn)"
        "'&(fn)=_(liste)= (liste & fn)"
        "\%(liste)=_(fn)= (liste % fn)"
        "'%(fn)=_(liste)= (liste % fn)"
        "\O(f)=_(g)=_(x)=(f(g(x)))"
        "'O(g)=_(f)=_(x)=(f(g(x)))"
        #\W est le rond pour 2 variables
        "\W(f)=_(g)=_(x)=_(y)=_(z)=(f(g(x)(y))(z))"
        #Modulo
        "MOD(x)=_(y)=( x %% y )"
        #Range
        "\R(x)=_(y)=(x..y)"
        "'R(x)=_(y)=(y..x)"
        "RANGE(x)=_(y)=(x..y)"
        #Renvoie une paire
        "\P(x)=_(y)=(x,y)"
        "'P(x)=_(y)=(y,x)"
        #Boolean
        "\B(x)=(x?1:0)"
    )
    #taille = ( ('&(\+))`\O:('%(\C(1)))  )
    # lonngueur = ('~ (0 , 1|\+|\K))
    # somme = ('&(\+))
    # moyenne = (\Z. somme. \/ .taille  )
    # moyenne = (\Z. ('&(\+)) .\/. ('~(0, 1|\+|\K)))
    # moyenne = (\Z.'&(\+) .\/. '~(0, 1|\+|\K)) 
    foreach($calcul in $Initialisation){
        $resultat = ($calcul | Convert-TextToParserInput | &(DoParseExecutable))
        $res = ComputeAST -AST $resultat.Value -Context $Context
        $Context = $res.Context
    }

    While($true){
        $calcul = Read-Host '>'
        if($calcul -match '^\s*(exit|quit|bye|sayonara|ciao)\s*$')                { return }
        if($calcul -cmatch '^\s*CONTEXT\s*$')   { Show-Context -Context $Context; Continue }
        if($calcul -cmatch '^\s*TRON\s*$')   { $Context.Values['tron'].Value = 1; Continue }
        if($calcul -cmatch '^\s*TROFF\s*$')  { $Context.Values['tron'].Value = 0; Continue }
        if($calcul -match '^\s*$')                                              { Continue }
        #if($calcul -match '^\s*$') {}
        if($calcul -match '^\s*LIST\s*$') {
                                          Get-ChildItem -Path . | ?{$_.name -match "\.cal$"}
                                                                                  Continue }
        if($calcul -cmatch '\s*SAVE\s*$')
                         { $Context | ConvertTo-Json -Depth 100 > 'Context.json'; Continue }
        if($calcul -cmatch '\s*LOAD(\s+(.+))?\s*$') { 
                    $Fichier = $Matches[2] ?? 'prog1.cal'
                    Write-Host "Chargement de **$($Fichier)**"
                        $Context = LoadFile2 -FileName $Fichier -Context $Context; Continue }


        $resultat = ($calcul | Convert-TextToParserInput | &(DoParseExecutable))
        if($null -eq $resultat){
            Write-Host "No comprendo la palabra !" -ForegroundColor Red
        }

        if($resultat.Index -ne $resultat.Text.Length){
            Write-Host "Syntax error at char $($resultat.Index + 1)"
            Write-Host $calcul
            Write-Host "$(' ' * $resultat.Index)^" -ForegroundColor Red
            Continue
        }

        if($Context.Values['tron'].Value){
            Write-Host "Dans Calculette:"
            Write-Host "Resultat = $($resultat)"
            Write-Host "AST = $($resultat.Value)"
            $resultat.Value | DiveIntoObject -depth 1
        }

        $res = ComputeAST -AST $resultat.Value -Context $Context
        $Context = $res.Context
        if($Context.Values['tron'].Value){
            Write-Host "RES:"
            DiveIntoObject -Object $res -depth 2
        }

        if($Context.Values['context'].Value){
            Show-Context -Context $Context
        }
#        if($res.Computation.Type -ne 'CLOSURE'){
#          Write-Host $res.Computation.Value
#        }
        Write-Host (Object2Text $res.Computation)
    }
}

function LoadFile{
    param(
        $FileName = 'prog1.cal',
        $Context
    )

    $content = Get-Content -Path $FileName


    #foreach($index in (0..($content.Length - 1))){
    :BOUCLE for($index = 0; $index -lt ($content.Length); $index++){
        #Write-Host "$($index + 1) `t $($content[$index])"

        $txt = ""
        while((($calcul = $content[$index]) -notmatch "^\s*$") -or (($calcul = $content[$index]) -notmatch "^\s*#")){
          Write-Host "$($index + 1) `t $($content[$index])"
          #if($calcul -match "^\s*#"){ continue BOUCLE}
          $txt += $calcul
          $index++
          if($index -ge $context.Length){ continue }
        }
        #$calcul = $content[$index]
        #if($calcul -match "^\s*$"){ continue }
        #if($calcul -match "^\s*#"){ continue }
        #$resultat = ($calcul | Convert-TextToParserInput | &(DoParseExecutable))

        $resultat = ($txt | Convert-TextToParserInput | &(DoParseExecutable))
        if($null -eq $resultat){
            Write-Host "No comprendo la palabra !" -ForegroundColor Red
            Write-Host "Line: $($index + 1)"       -ForegroundColor DarkGreen
            Write-Host "$($content[$index])"       -ForegroundColor DarkYellow
            return $Context
        }
        if($resultat.Index -ne $resultat.Text.Length){
            Write-Host "Syntax error at char $($resultat.Index + 1)"
            Write-Host $calcul
            Write-Host "$(' ' * $resultat.Index)^" -ForegroundColor Red
            return $Context
        }
        $res = ComputeAST -AST $resultat.Value -Context $Context
        $Context = $res.Context
    }

    return $Context
}

function ligne_valide{
  param(
    $ligne
  )
  return ($ligne -notmatch "^\s*$") 
}

function LoadFile2{
    param(
        $FileName = 'prog1.cal',
        $Context
    )

    $content = Get-Content -Path $FileName

    for($index = 0; $index -lt ($content.Length); $index++){
        $txt = ""
        while(ligne_valide -ligne ($calcul = $content[$index])){
          Write-Host "$($index + 1 ) `t $($content[$index])"
          if($calcul -notmatch '^\s*#'){ $txt += $calcul }
          $index++
          if($index -ge $content.Length){ continue }
        }

        if($txt -match "^\s*$"){ continue }
        Write-Host "Analyse de $txt"
        $resultat = ($txt | Convert-TextToParserInput | &(DoParseExecutable))
        
        if($null -eq $resultat){
            Write-Host "No comprendo la palabra !" -ForegroundColor Red
            Write-Host "Line: $($index + 1)"       -ForegroundColor DarkGreen
            Write-Host "$($content[$index])"       -ForegroundColor DarkYellow
            return $Context
        }

        if($resultat.Index -ne $resultat.Text.Length){
            Write-Host "Syntax error at char $($resultat.Index + 1)"
            Write-Host $calcul
            Write-Host "$(' ' * $resultat.Index)^" -ForegroundColor Red
            return $Context
        }
        $res = ComputeAST -AST $resultat.Value -Context $Context
        $Context = $res.Context
    }

    return $Context
}

function New-ASTEnsembleVide {
    [PSCustomObject]@{
        Type    = 'CLOSURE'
        Context = [PSCustomObject]@{
            Parent = $null
            Values = @{'toto' = New-ASTInteger -Value 42}
            Memory = @{}
        }
        Parameters = (New-ASTIdentifiant -Identifiant 'x')
        Body       = (New-ASTError -Value 'VALEUR INDEFINIE')
        Value      = 'ENSEMBLE VIDE'
    }
}
function New-ASTGENERIC{
    param(
        $Type,
        $Value
    )
    [PSCustomObject]@{
        Type  = $Type
        Value = $Value
    }
}

function New-ASTError{
    param($Value)
    New-ASTGENERIC -Type 'ERROR' -Value $Value
}

function New-ASTInteger{
    param($Value)
    New-ASTGENERIC -Type 'INTEGER' -Value $Value
}

function New-ASTString{
    param($Value)
    New-ASTGENERIC -Type 'STRING' -Value $Value
}

function New-ASTIdentifiant{
    param($Identifiant)
    New-ASTGENERIC -Type 'IDENTIFIANT' -Value $Identifiant
}

function ComputeAST{
    param(
        $Context,
        [Parameter(ValueFromPipeline)]
        $AST
    )

    if( ($AST.Type -eq 'INTEGER') -or
        ($AST.Type -eq 'STRING' ) -or
        ($AST.Type -eq 'CLOSURE') -or
        ($AST.Type -eq 'ERROR')){
        return [PSCustomObject]@{
            Context = $Context
            Computation = $AST
        }
    }

    #ATTENTION:
    #Pas un operateur
    if($AST.Type -eq 'IDENTIFIANT'){
        return ComputeIDENTIFIANT -AST $AST -Context $Context
    }

    #Pas un operateur
    if($AST.Type -eq 'ASSIGNATION'){
        return ComputeASSIGNATION -lhs $AST.Left -rhs $AST.Right -Context $Context
    }

    #Ceci n'est pas un operateur!
    if($AST.Type -eq 'CONDITION'){
        return ComputeCONDITION -AST $AST -Context $Context
    }
    #Ceci n'est pas un operateur!
    if($AST.Type -eq 'QUESTIONMARK'){
        return ComputeQUESTIONMARK -lhs $AST.Left -rhs $AST.Right -Context $Context
    }

    #N'est pas traite comme un operateur
    if($AST.Type -eq 'FOLD'){
        return ComputeFOLD -lhs $AST.Left -rhs $AST.Right -Context $Context
    }
    
    #N'est pas traite comme un operateur
    if($AST.Type -eq 'OPERATORFUNCTION') {
        return ComputeOPERATORFUNCTION -lhs $AST.Left -rhs $AST.Right -Context $Context
    }

    #N'est pas traite comme un operateur
    if($AST.Type -eq 'BOUCLE') {
        return ComputeBOUCLE -lhs $AST.Left -rhs $AST.Right -Context $Context
    }

    #N'est pas traite comme un operateur
    if($AST.Type -eq 'ZIP') {
        return ComputeZIP -lhs $AST.Left -rhs $AST.Right -Context $Context
    }

    #Pas un operateur
    if($AST.Type -eq 'ASSIGNATIONFUNCTION'){
        return (ComputeASSIGNATIONFUNCTION -lhs $AST.Left -rhs $AST.Right -Context $Context)
    }

    #Un operateur bien particulier
    if($AST.Type -eq 'COMMA') {
        return ComputeCOMMA -lhs $AST.Left -rhs $AST.Right -Context $Context
    }

    #Pour les operateurs binaires, nous faisons les tests en amont
    $Left  = ComputeAST -Context $Context -AST $AST.Left
    if( $Left.Computation.Type -eq 'ERROR'){ return $Left }
    $Right = ComputeAST -Context $Left.Context -AST $AST.Right
    if($Right.Computation.Type -eq 'ERROR'){ return $Right }
    $NewContext = $Right.Context
    $Left  = $Left.Computation
    $Right = $Right.Computation

    #Operateurs binaires

    if($AST.Type -eq 'MODULO'){
        return (ComputeModulo -lhs $Left -rhs $Right -Context $NewContext)
    }

    if($AST.Type -eq 'ADDITION'){
        return (ComputeADDITION -lhs $Left -rhs $Right -Context $NewContext)
    }

    if($AST.Type -eq 'SOUSTRACTION'){
        return (ComputeSOUSTRACTION -lhs $Left -rhs $Right -Context $NewContext)
    }

    if($AST.Type -eq 'MULTIPLICATION'){
        return (ComputeMULTIPLICATION -lhs ($Left) -rhs ($Right) -Context $NewContext)
    }

    if($AST.Type -eq 'DIVISION'){
        return (ComputeDIVISION -lhs $Left -rhs $Right -Context $NewContext)
    }

    if($AST.Type -eq 'COMPARAISONSUP'){
        return ComputeCOMPARAISONSUP -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'COMPARAISONINF'){
        return ComputeCOMPARAISONINF -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'SEMICOLON'){
        return ComputeSEMICOLON -lhs $Left -rhs $Right -Context $NewContext
    }


    if($AST.Type -eq 'QUESTIONMARK'){
        return ComputeQUESTIONMARK -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'PIPE') {
        return (ComputeFUNCTIONEVAL -lhs $Right -rhs $Left -Context $NewContext)
    }

    if($AST.Type -eq 'FUNCTIONEVAL'){
        return (ComputeFUNCTIONEVAL -lhs $Left -rhs $Right -Context $NewContext)
    }

    if($AST.Type -eq 'MAP'){
        return ComputeMAP -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'REDUCE'){
        return ComputeREDUCE -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'FIRSTELEMENTS'){
        return ComputeFIRSTELEMENTS -lhs $Left -rhs $Right -context $NewContext
    }

    if($AST.Type -eq 'APPLIQUE'){
        return (ComputeFUNCTIONEVAL -lhs $Left -rhs $Right -Context $NewContext)
    }

    if($AST.Type -eq 'INTLIST') {
        return ComputeINTLIST -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'ADDARRAY') {
        return ComputeADDARRAY -lhs $Left -rhs $Right -Context $NewContext
    }

    if($AST.Type -eq 'ROND') {
        return ComputeROND -lhs $Left -rhs $Right -Context $NewContext
    }

    DiveIntoObject -Object $AST -depth 4
    [PSCustomObject]@{
        Context = $Context
        Computation = New-ASTError -Value "AST INCONNU **$($AST.Type)**"
    }
}

function ComputeOperation {
    param(
        $Operations,
        $lhs,
        $rhs
    )
}

function ComputeIDENTIFIANT {
    param(
        $AST,
        $Context
    )
    if($null -eq $Context.Values[$AST.Value]){
        if($Context.Values['_AUTOINITVARIABLE'].Value -eq 1){
            return [PSCustomObject]@{
                Context     = $Context
                Computation = New-ASTInteger -Value 0
            }
        }
        else{
            return [PSCustomObject]@{
                Context     = $Context
                Computation = New-ASTError -Value "$($AST.Value) EST INDEFINI"
            }
        }
    }
    else{
        if($Context.Values['tron'].Value){
            Write-Host "COMPUTE IDENTITIANT - AST Value : $($AST.Value) = $($Context.Values[$AST.Value]) Value = $($Context.Values[$AST.Value].Value)"
        }
        return [PSCustomObject]@{
            Context     = $Context
            Computation = $Context.Values[$AST.Value]
        }
    }
}

function ComputeASSIGNATIONFUNCTION {
    param(
        $lhs,
        $rhs,
        $Context
    )
    #HACK Temporaire, on copie le context parent plus tard faire
    #Une fonction Search-Variable -Context $context
    $NewValues = @{}
    $Context.Values.Keys |%{
        $NewValues[$_] = $Context.Values[$_]
    }
    if(($rhs.Parameters.Type -eq 'INTEGER') -or ($rhs.Parameters.Type -eq 'STRING')){
        #On recherche la function
        $fonction = $Context.Values[$lhs.Value]
        if(!($fonction)){
            #ATTENTION: Copie de block tout pourri juste pour voir si ca marche!
            $closure = [PSCustomObject]@{
                    Type  = 'CLOSURE'
                    Context = [PSCustomObject]@{
                        Parent = $Context
                        Values = $NewValues
                        Memory = @{}
                    }
                    Parameters = $rhs.Parameters
                    Body       = $rhs.Body
                    Value      = $closure #Le pire des megahack!
            }
            if($lhs.Value -ne '_'){ #Les fonctions anonymes sont anonymes!
                $Context.Values[$lhs.Value] = $closure
            }
            $closure.Context.Values[$lhs.Value] = $closure
            $closure.Context.Values['_'] = $closure
            $fonction = $closure
        }
        $Computation = (ComputeAST -AST $rhs.Body -Context $Context)
        $fonction.Context.Memory[$rhs.Parameters.Value] = $computation.Computation
        
        return $Computation
    }
    $closure = [PSCustomObject]@{
            Type  = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $Context
                Values = $NewValues
                Memory = @{}
            }
            Parameters = $rhs.Parameters
            Body       = $rhs.Body
            Value      = $closure #Le pire des megahack!
    }
    if($lhs.Value -ne '_'){ #Les fonctions anonymes sont anonymes!
        $Context.Values[$lhs.Value] = $closure
    }
    $closure.Context.Values[$lhs.Value] = $closure
    $closure.Context.Values['_'] = $closure
    return [PSCustomObject]@{
        Context = $Context
        Computation = $closure
    }
}

function ComputeFUNCTIONEVAL{
    param(
        $lhs,
        $rhs,
        $Context
    )

    $func  = $lhs
    $Right = $rhs

    if($func.Type -eq 'INTEGER'){
        $AST = [PSCustomObject]@{
            Type  = 'MULTIPLICATION'
            Left  = $func
            Right = $Right
        }
        return (ComputeAST -Context $Context -AST $AST)
    }

    if($func.Type -eq 'STRING'){
        if($Right.Type -ne 'INTEGER'){
            return [PSCustomObject]@{
                Context     = $Context
                Computation = New-ASTError -Value "INDEX DE TEXTE NON ENTIER"
            }
        }
        if(($Right.Value -ge $func.Value.Length) -or ($Right.Value -lt 0)){
            return [PSCustomObject]@{
                Context     = $Context
                Computation = New-ASTError -Value "INDEX POUR TEXT HORS DES LIMITES"
            }
        }

        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTString -Value ($func.Value[$Right.Value])
        }
    }

    if($func.Type -eq 'EXTERNALFUNC'){
      
    }

    if($func.Type -ne 'CLOSURE'){
DiveIntoObject -Object $func
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "EVAL FUNCTION TYPE **$($func.Type)** not CLOSURE"
        }
    }

        $param          = $func.Parameters
        $EvalParam      = (ComputeAST -AST $rhs -Context $func.Context)
        $func.Context.Values[$param.Value] = $EvalParam.Computation
        #Recherche si la valeur n'est pas cachee en memoire:
        $EvalParamValue = $EvalParam.Computation.Value

        if($Null -ne $EvalParamValue){
            $Memory = $func.Context.Memory[$EvalParamValue]
            if($Memory.Type -eq 'CLOSURE'){
#Write-Host "DiveIntoMemory"
#DiveIntoObject -Object $Memory
#Write-Host "DiveIntoParameter"
#DiveIntoObject -Object $param
                $Memory.Context.Values[$param.Value] = $EvalParam.Computation
            }
            if($Null -ne $Memory){
                return [PSCustomObject]@{
                    Context = $Context
                    Computation = $Memory
                }
            }
        }

#        $func.Context.Values[$param.Value] = $EvalParam.Computation
        $EvalBody   = (ComputeAST -AST $func.Body -Context $func.Context)
        return [PSCustomObject]@{
            Context = $Context
            Computation = $EvalBody.Computation
        }
}

#ATTENTION: FOLD devra avoir le meme type que les condition
# l'operateur est tilde
# LISTE ~ ACCU : FUNCTION
function ComputeFOLD {
    param(
        $lhs,
        $rhs,
        $Context
    )
    $LeftComputation = (ComputeAST -Context $Context -AST $lhs)
    $Left = $LeftComputation.Computation
    if($Left.Type -eq 'ERROR'){ return $LeftComputation }
    
    if($rhs.Type -ne 'COLON'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTError -Value "AST **$($rhs.Type)** n'est pas (':') apres FOLD ('~')"
        }
    }
    if($Left.Type -eq 'INTEGER' -or $rhs.Type -eq 'INTEGER' -or $rhs.Type -eq 'STRING'){
        DiveIntoObject -Object $AST -depth 4
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "UNABLE TO FOLD ON **$($Left.Type)**"
        }
    }

    if($Left.Type -eq 'STRING'){
        $Left = Convert-STRINGtoCLOSURE -ASTString $Left
    }

    if($Left.Type -ne 'CLOSURE'){
        Write-Host "DIVE LEFT:" -ForegroundColor Red
        DiveIntoObject -Object $LeftComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "FOLD FUNCTION TYPE **$($Left.Type)** not CLOSURE"
        }
    }

    $AccuAst         = $rhs.Left
#    if($AccuAst.Type -eq 'IDENTIFIANT' -and $AccuAst.Value -eq 'Vide'){
#        $AccuComputation = [PSCustomObject]@{
#            Context     = $Context
#            Computation = New-ASTEnsembleVide
#        }
#    }else{
        $AccuComputation = ComputeAst -Ast $AccuASt -Context $LeftComputation.Context
#    }
    if($AccuComputation.Computation.Type -eq 'ERROR'){
        return [PSCustomObject]@{
            Context = $LeftComputation.Context
            Computation = $AccuComputation
        }
    }

    $FunctionFoldAst = $rhs.Right
    $FunctionComputation = ComputeAST -Ast $FunctionFoldAst -Context $AccuComputation.Context
    if($FunctionComputation.Computation.Type -eq 'ERROR'){
        return [PSCustomObject]@{
            Context = $LeftComputation.Context
            Computation = $FunctionComputation
        }
    }

    $accu    = $AccuComputation.Computation
    $Memoire = $Left.Context.Memory
    $rest    = $Memoire.Keys | Sort-Object
    
    if($null -eq $rest){
        return $AccuComputation
    }

    foreach($clef in $rest){
        $ValeurClef = $Memoire[$clef] 
        #Evaluons lambda = function($valeurClef)
        $fonction = $FunctionComputation.Computation
        $EvaluationFonction = [PSCustomObject]@{
            Type  = 'FUNCTIONEVAL'
            Left  = $fonction
            Right = $accu
        }

        $lambda = ComputeAST -Context $AccuComputation.Context -AST $EvaluationFonction
        if($lambda.Computation.Type -eq 'ERROR'){ return $lambda }
        if($lambda.Computation.Type -ne 'CLOSURE'){
            return [PSCustomObject]@{
                Context = $AccuComputation.Context
                Computation = New-ASTError -Value "REDUCE ERROR PARAM2 TYPE **$($lambda.Computation.Type)** NON CLOSURE"
            }
        }
        
        $EvaluationLambda = [PSCustomObject]@{
            Type  = 'FUNCTIONEVAL'
            Left  = $lambda.Computation
            Right = $ValeurClef
        }
        $resultat = ComputeAST -Context $lambda.Context -AST $EvaluationLambda
        if($resultat.Computation.Type -eq 'ERROR'){ return $resultat }

        $accu = $resultat.Computation
    }

    [PSCustomObject]@{
        Context     = $Context
        Computation = $accu
    }
}


function ComputeFIRSTELEMENTS {
    param(
        $lhs,
        $rhs,
        $Context
    )

    $LeftComputation  = $lhs
    $RightComputation = $rhs

    if($RightComputation.Type -ne 'INTEGER'){
        Write-Host "DIVE RIGHT:" -ForegroundColor Red
        DiveIntoObject -Object $RightComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "FIRSTSELEMENTS NUMBER OF ELEMENTS TYPE **$($RightComputation.Type)** not INTEGER"
        }
    }

    if($LeftComputation.Type -eq 'STRING'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTString -Value ($LeftComputation.Value.Substring(0,$RightComputation.Value))
        }
    }

    if($LeftComputation.Type -ne 'CLOSURE'){
        Write-Host "DIVE LEFT:" -ForegroundColor Red
        DiveIntoObject -Object $LeftComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "FIRSTSELEMENTS FUNCTION TYPE **$($LeftComputation.Type)** not CLOSURE"
        }
    }

    $NewMemory = @{}
    foreach($index in 0..($RightComputation.Value - 1)){
        $EvaluationAST = [PSCustomObject]@{
            Type  = 'FUNCTIONEVAL'
            Left  = $LeftComputation
            Right = New-ASTInteger -Value $index
        }
        $Evaluation = ComputeAST -Context $Context -AST $EvaluationAST
        $NewMemory.Add($index, $Evaluation.Computation)
    }
    return [PSCustomObject]@{
        Context     = $Context
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $LeftComputation.Context.Parent
                Values = $LeftComputation.Context.Values
                Memory = $NewMemory
            }
            Parameters = $LeftComputation.Parameters
            Body       = $LeftComputation.Body
            Value      = $LeftComputation.Value
        }
    }
}

function ComputeREDUCE {
    param(
        $lhs,
        $rhs,
        $Context
    )
    if($lhs.Type -eq 'INTEGER' -or $rhs.Type -eq 'INTEGER' -or $rhs.Type -eq 'STRING'){
        DiveIntoObject -Object $AST -depth 4
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "UNABLE TO REDUCE ON **$($AST.Type)**"
        }
    }

    $LeftComputation = $(if($lhs.Type -eq 'STRING'){Convert-STRINGtoCLOSURE -ASTString $lhs}else{$lhs})
    $RightComputation = $rhs

    if($LeftComputation.Type -ne 'CLOSURE'){
    Write-Host "DIVE LEFT:" -ForegroundColor Red
    DiveIntoObject -Object $LeftComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "REDUCE FUNCTION TYPE **$($LeftComputation.Type)** not CLOSURE"
        }
    }
    if($RightComputation.Type -ne 'CLOSURE'){
        Write-Host "DIVE RIGHT:" -ForegroundColor Red
        DiveIntoObject -Object $RightComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "REDUCE FUNCTION TYPE **$($RightComputation.Type)** not CLOSURE"
        }
    }

    $Memoire       = $LeftComputation.Context.Memory
    $accu, $rest   = $Memoire.Keys | Sort-Object
    
    $ValeurAccu = $Memoire[$accu]
    if($null -eq $rest){
        return [PSCustomObject]@{
            Context = $LeftComputation.Context
            Computation = $ValeurAccu
        }
    }

    foreach($clef in $rest){
        $ValeurClef = $Memoire[$clef] 
        $fonction = $RightComputation
        $EvaluationFonction = [PSCustomObject]@{
            Type  = 'FUNCTIONEVAL'
            Left  = $fonction
            Right = $ValeurAccu
        }

        $lambda = ComputeAST -Context $Context -AST $EvaluationFonction
        if($lambda.Computation.Type -eq 'ERROR')  { return $lambda }
        if($lambda.Computation.Type -ne 'CLOSURE'){
            return [PSCustomObject]@{
                Context = $Context
                Computation = New-ASTError -Value "REDUCE ERROR PARAM2 TYPE **$($lambda.Computation.Type)** NON CLOSURE"
            }
        }
        
        $EvaluationLambda = [PSCustomObject]@{
            Type  = 'FUNCTIONEVAL'
            Left  = $lambda.Computation
            Right = $ValeurClef
        }
        $resultat = ComputeAST -Context $lambda.Context -AST $EvaluationLambda
        if($resultat.Computation.Type -eq 'ERROR'){ return $resultat }

        $ValeurAccu = $resultat.Computation
    }

    [PSCustomObject]@{
        Context     = $Context
        Computation = $ValeurAccu
    }
}

function Convert-STRINGtoCLOSURE {
    param(
        $ASTString
    )
    $Memory = @{}
    foreach($index in (0..($ASTString.Value.length - 1))){
        $Memory[$index] = New-ASTString -Value $ASTString.Value[$index]
    }
    $closure = [PSCustomObject]@{
        Type       = 'CLOSURE'
        Context    = [PSCustomObject]@{
            Parent = $null
            Values = $null
            Memory = $Memory
        }
        Parameters = [PSCustomObject]@{Type = 'IDENTIFIANT'; Value = 'x'}
        Body       = New-ASTError  -Value 'VALEUR INDEFINIE'
        Value      = $ASTString.Value
    }
    return $closure
}
function ComputeMAP{
    param(
        $lhs,
        $rhs,
        $Context
    )

    $LeftComputation  = $lhs
    $RightComputation = $rhs

    if($LeftComputation.Type -eq 'INTEGER' -or $RightComputation.Type -eq 'INTEGER'){
        DiveIntoObject -Object $AST -depth 4
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "UNABLE TO MAP ON **$($AST.Type)**"
        }
    }

    if($LeftComputation.Type -eq 'STRING'){
        $LeftComputation = Convert-STRINGtoCLOSURE -ASTString $LeftComputation
    }

    if($LeftComputation.Type -ne 'CLOSURE'){
    Write-Host "DIVE LEFT:" -ForegroundColor Red
    DiveIntoObject -Object $LeftComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "MAP FUNCTION TYPE **$($LeftComputation.Type)** not CLOSURE"
        }
    }

    if(!($RightComputation.Type -eq 'CLOSURE' -or $RightComputation.Type -eq 'STRING')){
    Write-Host "DIVE RIGHT:" -ForegroundColor Red
    DiveIntoObject -Object $RightComputation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "MAP FUNCTION TYPE **$($RightComputation.Type)** not CLOSURE"
        }
    }

    $NewMemory = @{}
    $LeftComputation.Context.Memory.Keys | Sort-Object |%{
        $EvaluationAST = [PSCustomObject]@{
            Type  = 'FUNCTIONEVAL'
            Left  = $RightComputation
            Right = $LeftComputation.Context.Memory[$_]
        }
        $Evaluation = ComputeAST -Context $Context -AST $EvaluationAST
        $NewMemory.Add($_, $Evaluation.Computation)
    }

    return [PSCustomObject]@{
        Context     = $Context
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $LeftComputation.Context.Parent
                Values = $LeftComputation.Context.Values
                Memory = $NewMemory
            }
            Parameters = $LeftComputation.Parameters
            Body       = $LeftComputation.Body
            Value      = $LeftComputation.Value
        }
    }
}

function ComputeZIP {
    param(
        $lhs,
        $rhs,
        $Context
    )

    if($lhs.Type -ne 'COLON'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTError -Value "ZIP: AST **$($lhs.Type)** n'est pas (':') avant EXCLAMATION ('!')"
        }
    }
    
    $ASTList1   = $lhs.Left
    $ASTList2   = $lhs.Right
    $ASTZipFunc = $rhs
    
    $List1Comp = ComputeAST -AST $ASTList1 -Context $Context
    if($List1Comp.Computation.Type -eq 'ERROR'){ return $List1Comp }
    $List1   = $List1Comp.Computation
    $Context = $List1Comp.Context
    
    $List2Comp = ComputeAST -AST $ASTList2 -Context $Context
    if($List2Comp.Computation.Type -eq 'ERROR'){ return $List2Comp }
    $List2   = $List2Comp.Computation
    $Context = $List2Comp.Context

    $ZipFuncComp = ComputeAST -AST $ASTZipFunc -Context $Context
    if($ZipFuncComp.Computation.Type -eq 'ERROR'){ return $ZipFuncComp }
    $ZipFunc = $ZipFuncComp.Computation
    $Context = $ZipFuncComp.Context

#    $Memory1 = $List1.Context.Memory.Keys | Sort-Object
#    $Memory2 = $List2.Context.Memory.Keys | Sort-Object
    $Memory1 = $List1.Context.Memory
    $Memory2 = $List2.Context.Memory

    $MemMin = ($Memory1.Count -lt $Memory2.Count ? $Memory1.Count : $Memory2.Count) - 1

    $NewMemory = @{}
    foreach($index in (0..$MemMin)){
        $Func1Comp = ComputeFUNCTIONEVAL -lhs $ZipFunc -rhs ($Memory1[$index]) -Context $Context
        if($Func1Comp.Computation.Type -eq 'ERROR'){ return $Func1Comp }
        $Func1   = $Func1Comp.Computation
        $Context = $Func1Comp.Context

        $Func2Comp = ComputeFUNCTIONEVAL -lhs $Func1 -rhs ($Memory2[$index]) -Context $Context
        $Func2   = $Func2Comp.Computation
        $Context = $Func2Comp.Context

        $NewMemory.Add($index, $Func2)
    }

    return [PSCustomObject]@{
        Context     = $Context
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $Context.Parent
                Values = $Context.Values
                Memory = $NewMemory
            }
            Parameters = [PSCustomObject]@{Type = 'IDENTIFIANT'; Value = 'x'}
            Body       = New-ASTError  -Value 'VALEUR INDEFINIE'
            Value      = ''
        }
    }
    
}
function ComputeBOUCLE {
    param(
        $lhs,
        $rhs,
        $Context
    )

    if($lhs.Type -ne 'COLON'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTError -Value "BOUCLE: AST **$($lhs.Type)** n'est pas (':') avant EXCLAMATIONS ('!!')"
        }
    }
    
    $ASTList1   = $lhs.Left
    $ASTList2   = $lhs.Right
    $ASTZipFunc = $rhs
    
    $List1Comp = ComputeAST -AST $ASTList1 -Context $Context
    if($List1Comp.Computation.Type -eq 'ERROR'){ return $List1Comp }
    $List1   = $List1Comp.Computation
    $Context = $List1Comp.Context
    
    $List2Comp = ComputeAST -AST $ASTList2 -Context $Context
    if($List2Comp.Computation.Type -eq 'ERROR'){ return $List2Comp }
    $List2   = $List2Comp.Computation
    $Context = $List2Comp.Context

    $ZipFuncComp = ComputeAST -AST $ASTZipFunc -Context $Context
    if($ZipFuncComp.Computation.Type -eq 'ERROR'){ return $ZipFuncComp }
    $ZipFunc = $ZipFuncComp.Computation
    $Context = $ZipFuncComp.Context

    $Memory1 = $List1.Context.Memory
    $Memory2 = $List2.Context.Memory

    $MemMin = ($Memory1.Count -lt $Memory2.Count ? $Memory1.Count : $Memory2.Count) - 1

    $NewMemory = @{}
#    foreach($index in (0..$MemMin)){
#        $Func1Comp = ComputeFUNCTIONEVAL -lhs $ZipFunc -rhs ($Memory1[$index]) -Context $Context
#        if($Func1Comp.Computation.Type -eq 'ERROR'){ return $Func1Comp }
#        $Func1   = $Func1Comp.Computation
#        $Context = $Func1Comp.Context
#
#        $Func2Comp = ComputeFUNCTIONEVAL -lhs $Func1 -rhs ($Memory2[$index]) -Context $Context
#        $Func2   = $Func2Comp.Computation
#        $Context = $Func2Comp.Context
#
#        $NewMemory.Add($index, $Func2)
#    }

    foreach($x in (0..($Memory1.Count - 1))){
        #Write-Host "BCLx: $x"
        $Func1Comp = ComputeFUNCTIONEVAL -lhs $ZipFunc -rhs ($Memory1[$x]) -Context $Context
        if($Func1Comp.Computation.Type -eq 'ERROR'){ return $Func1Comp }
        $Func1   = $Func1Comp.Computation
        $Context = $Func1Comp.Context
        foreach($y in (0..($Memory2.Count - 1))){
            #Write-Host "BCLy: $y"
            $Func2Comp = ComputeFUNCTIONEVAL -lhs $Func1 -rhs ($Memory2[$y]) -Context $Context
            $Func2   = $Func2Comp.Computation
            #$Context = $Func2Comp.Context

            $NewMemory.Add($x * $Memory1.Count + $y , $Func2)
        }
    }

    return [PSCustomObject]@{
        Context     = $Context
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $Context.Parent
                Values = $Context.Values
                Memory = $NewMemory
            }
            Parameters = [PSCustomObject]@{Type = 'IDENTIFIANT'; Value = 'x'}
            Body       = New-ASTError  -Value 'VALEUR INDEFINIE'
            Value      = ''
        }
    }
    
}

function ComputeOPERATORFUNCTION {
    param(
        $lhs,
        $rhs,
        $Context
    )

    if($rhs.Type -ne 'COLON'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTError -Value "AST **$($rhs.Type)** n'est pas (':') apres TILDE ('`')"
        }
    }
    
    $FirstArgumentComputation = ComputeAST -AST $lhs -Context $Context
    if($FistArgumentComputation.Computation.Type -eq 'ERROR'){ return $FirstArgumentComputation }
    $FirstArgument = $FirstArgumentComputation.Computation
    $Context = $FirstArgumentComputation.Context

    $FComputation = ComputeAST -AST $rhs.Left -Context $Context
    if($FComputation.Computation.Type -eq 'ERROR'){ return $FComputation }
    $func    = $FComputation.Computation
    $Context = $Fcomputation.Context

    $tempFuncComputation = ComputeFUNCTIONEVAL -lhs $func -rhs $FirstArgument -Context $Context
    if($tempFuncComputation.Computation.Type -eq 'ERROR'){ return $tempFuncComputation }
    $func2   = $tempFuncComputation.Computation
    $Context = $tempFuncComputation.Context

    $SecondArgumentComputation = ComputeAST -AST $rhs.right -Context $Context
    if($SecondArgumentComputation.Computation.Type -eq 'ERROR'){ return $SecondArgumentComputation}
    $SecondArgument = $SecondArgumentComputation.Computation
    $Context        = $SecondArgumentComputation.Context
    
    ComputeFUNCTIONEVAL -lhs $func2 -rhs $SecondArgument -Context $Context
}

function ComputeADDARRAY {
    param(
        $lhs,
        $rhs,
        $Context
    )
    
    if($lhs.Type -ne 'CLOSURE') {
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTError -Value "ADDARRAY (++): ON NE PEUT AJOUTER UN ELEMENT A UN $($lhs.Type): $($lhs.Value)"
        }
        #Write-Host -ForegroundColor Red "ADDARRAY (++): ON NE PEUT AJOUTER UN ELEMENT A UN $($lhs.Type)"
    }

    $NewMemory = @{} + $lhs.Context.Memory
    $NewMemory.Add($lhs.Context.Memory.Count, $rhs)
    
    return [PSCustomObject]@{
        Context     = $Context
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $lhs.Context.Parent
                Values = $lhs.Context.Values
                Memory = $NewMemory
            }
            Parameters = $lhs.Parameters
            Body       = $lhs.Body
            Value      = "$($lhs.Value), $($rhs.Value)"
        }
    }
}

function CommaToTab{
    param($ASTComma)
    if($ASTComma.Type -ne 'COMMA'){
        return [array]($ASTComma)
    }
    [array](CommaToTab -ASTComma $ASTComma.Left) + [array](CommaToTab -ASTComma $ASTComma.Right)
}

function ComputeINTLIST {
    param(
        $lhs,
        $rhs,
        $Context
    )

    $Left = $lhs
    if($Left.Type -ne 'INTEGER'){
        DiveIntoObject -Object $Left.Computation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "LISTE D'ENTIERS: $($Left.Computation.Type) N'EST PAS ENTIER"
        }
    }

    $Right = $rhs
    if($Right.Type -ne 'INTEGER'){
        DiveIntoObject -Object $Right.Computation
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "LISTE D'ENTIERS: $($Right.Computation.Type) N'EST PAS ENTIER"
        }
    }

    $NewMemory = [ordered]@{}
    foreach($index in 0..($Right.Value - $Left.Value)){
        $NewMemory.Add($index, (New-ASTInteger -Value ($Left.Value + $index)))
    }

    return [PSCustomObject]@{
        Context = $Context
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $Context.Parent
                Values = $Context.Values
                Memory = $NewMemory
            }
            Parameters = [PSCustomObject]@{
                Type  = 'IDENTIFIANT'
                Value = 'x'
            }
            Body       = New-ASTError -Value 'VALEUR INDEFINIE'
            Value      = $null
        }
    }
}

function ComputeCOMMA {
    param(
        $lhs,
        $rhs,
        $Context
    )

    $TabAST = [array](CommaToTab -ASTComma $lhs) + [array](CommaToTab -ASTComma $rhs)
    $NewMemory = @{}
    $CurrentContext = $Context

    foreach($index in 0..($TabAST.Length - 1)){
        $element = $TabAST[$index]
        $Evaluation = (ComputeAST -AST $element -Context $CurrentContext)
        $CurrentContext = $Evaluation.Context
        if($Evaluation.Computation.Type -eq 'ERROR'){ return $Evaluation }
        $NewMemory.Add($index, $Evaluation.Computation)
    }

    return [PSCustomObject]@{
        Context = $CurrentContext
        Computation = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $CurrentContext.Parent
                Values = $CurrentContext.Values
                Memory = $NewMemory
            }
            Parameters = [PSCustomObject]@{
                Type  = 'IDENTIFIANT'
                Value = 'x'
            }
            Body       = New-ASTError -Value 'VALEUR INDEFINIE'
            Value      = $null
        }
    }
}

function ComputeASSIGNATION {
    param(
        $lhs,
        $rhs,
        $Context
    )
    if($lhs.Type -eq 'IDENTIFIANT'){
        $computation = (ComputeAST -AST $rhs -Context $Context)
        $NeoContext  = $computation.Context
        $NeoContext.Values[$lhs.Value] = $computation.Computation
        return $computation
    }
    return New-ASTError -Value "Le LHS d'une ASSIGNATION doit etre un IDENTIFIANT"
}

function ComputeSEMICOLON {
    param(
        $lhs,
        $rhs,
        $Context
    )
    return [PSCustomObject]@{
        Context     = $Context
        Computation = $rhs
    }
}

function ComputeCONDITION {
    param(
        $AST,
        $Context
    )
    $condComputation = (ComputeAST -AST $AST.Condition -Context $Context)
    $NeoContext = $condComputation.Context
    $cond = $condComputation.Computation.Value
    if($cond){
        $computation = (ComputeAST -AST $AST.SI    -Context $NeoContext)
        $NeoContext  = $computation.Context
    }else{
        $computation = (ComputeAST -AST $AST.SINON -Context $NeoContext)
        $NeoContext  = $computation.Context
    }
    return $computation
}

function ComputeQUESTIONMARK {
    param(
        $lhs,
        $rhs,
        $Context
    )
    if($rhs.Type -ne 'COLON'){
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTError -Value "AST **$($rhs.Type)** is not COLON after QUESTIONMARK"
        }
    }
#    return ComputeAST -Context $Context -AST ([PSCustomObject]@{
    return ComputeCONDITION -Context $Context -AST ([PSCustomObject]@{
        Type      = 'CONDITION'
        Condition = $lhs
        SI        = $rhs.Left
        SINON     = $rhs.Right
    })
}
function ComputeCOMPARAISONSUP {
    param(
        $lhs,
        $rhs,
        $Context
    )
    $TmpValue = $lhs.Value -gt $rhs.Value
    return [PSCustomObject]@{
        Context = $Context
        Computation = New-ASTInteger -Value $(if($TmpValue){1}else{0})
    }
}

function ComputeCOMPARAISONINF {
    param(
        $lhs,
        $rhs,
        $Context
    )
    $TmpValue = $lhs.Value -lt $rhs.Value
    return [PSCustomObject]@{
        Context     = $Context
        Computation = New-ASTInteger -Value $(if($TmpValue){1}else{0})
    }
}

function ComputeROND{
    param(
        $lhs,
        $rhs,
        $Context
    )
    # Compose $lhs et $rhs

    # On fera les test du type (if($lhs.Type -ne 'CLOSURE')...) apres
    # Donc $lhs.Type -eq 'CLOSURE'
    # et   $rhs.Type -eq 'CLOSURE'
    #

    $closure = [PSCustomObject]@{
        Type    = 'CLOSURE'
        Context = [PSCustomObject]@{
            Parent = $Context
	    Values = $Context.Values
            Memory = @{}
        }
        Parameters = (New-ASTIdentifiant -Identifiant 'x')
	Body       = [PSCustomObject]@{
		Type  = 'FUNCTIONEVAL'
		Left  = $lhs
		Right =	[PSCustomObject]@{
			Type  = 'FUNCTIONEVAL'
			Left  = $rhs
			Right = New-ASTIdentifiant -Identifiant 'x'
		}
	}
        Value      = "Fonction composee de $($lhs.Value) et de $($rhs.Value)"
    }

    return [PSCustomObject]@{
        Context     = $Context
        Computation = $closure
    }
    

}

function ComputeMULTIPLICATION {
    param(
        $lhs,
        $rhs,
        $Context
    )
# La ligne suivante est buggee ! et celle d'en dessous non !
#    $ResultatLeft  = (ComputeAST -AST $lhr  -Context $Context)
#    $ResultatLeft  = (ComputeAST -AST $lhs -Context $Context)
    
    if($lhs.Type -eq 'INTEGER' -and $rhs.Type -eq 'STRING'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTString -Value ($rhs.Value * $lhs.Value)
        }
    }

    if($lhs.Type -eq 'STRING' -and $rhs.Type -eq 'INTEGER'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTString -Value ($lhs.Value * $rhs.Value)
        }
    }

    if($lhs.Type -eq 'INTEGER' -and $rhs.Type -eq 'INTEGER'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTInteger -Value ($lhs.Value * $rhs.Value)
        }
    }

    return [PSCustomObject]@{
        Context     = $Context
        Computation = New-ASTError -Value "IMPOSSIBLE DE MULTIPLIER **$($lhs.Type)** PAR **$($rhs.Type)**"
    }
}

function ComputeDIVISION {
    param(
        $lhs,
        $rhs,
        $Context
    )

    $Left  = $lhs
    $Right = $rhs

    if($left.Type -eq 'INTEGER' -and $right.Type -eq 'INTEGER'){
        if($right.Value -eq 0){
            return [PSCustomObject]@{
                Context = $Context
                Computation = New-ASTError -Value 'ERREUR DIVISION PAR ZERO'
            }
        }
        return [PSCustomObject]@{
            Context = $Context
            Computation = New-ASTInteger -Value ($left.Value / $right.Value)
        }
    }

    if($left.Type -eq 'STRING' -and $right.Type -eq 'STRING'){
        #ATTENTION il faut gerer le cas ou $tabresult est vide !
        if($right.Value -eq ''){
#            Write-Host "Right Value = ''"
            $tabresult = @()
            ($left.Value -split '') | %{
                if($_ -ne ''){
                    $tabresult += $_
                }
            }
#            foreach($e in $tabresult){
#                Write-Host "$e"
#            }
        }
        else{
            $tabResult = $left.Value.Split($right.Value)
        }
#        $tabResult = $left.Value.Split($right.Value)
        $Memory = @{}
        0..($tabResult.Length - 1)|%{
            $Memory[$_] = New-ASTString -Value $tabResult[$_]
        }
        $closure = [PSCustomObject]@{
            Type    = 'CLOSURE'
            Context = [PSCustomObject]@{
                Parent = $Context.Parent
                Values = $Context.Values
                Memory = $Memory
            }
            Parameters = [PSCustomObject]@{Type='IDENTIFIANT';Value='x'}
            Body       = New-ASTInteger -Value 0
            Value      = $closure
        }
        return [PSCustomObject]@{
            Context     = $Context
            Computation = $closure
        }
    }

    [PSCustomObject]@{
        Context = $Context
        Computation = New-ASTError -Value "UNABLE TO DIVIDE $($left.Type) WITH $($right.Type)"
    }
}

function ComputeSOUSTRACTION {
    param(
        $lhs,
        $rhs,
        $Context
    )

    $left  = $lhs
    $right = $rhs

    if($left.Type -eq 'STRING' -and $right.Type -eq 'STRING'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTInteger -Value $(if($left.Value -eq $right.Value){0}else{1})
        }
    }

    if($left.Type -eq 'INTEGER' -and $right.Type -eq 'INTEGER'){
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTInteger -Value ($left.Value - $right.Value)
        }
    }

    if($left.Type -eq 'CLOSURE' -and $right.Type -eq 'CLOSURE'){
        #Pour l'instant on ne teste que l'ensemble vide
        if(($left.Context.Memory.Count -eq 0) -and ($right.Context.Memory.Count -eq 0)){
            return [PSCustomObject]@{
                Context     = $Context
                Computation = New-ASTInteger -Value 0
            }
        }
        return [PSCustomObject]@{
            Context     = $Context
            Computation = New-ASTInteger -Value 1
        }
    }

    Write-Host -ForegroundColor DarkRed "Error de soustraction:"
    Write-Host -ForegroundColor DarkRed "Dive Left"
    DiveIntoObject -Object $left
    Write-Host -ForegroundColor DarkRed "Dive Right"
    DiveIntoObject -Object $right
    return [PSCustomObject]@{
        Context     = $Context
        Computation = New-ASTError -Value "Left type: $($left.Type) et Right type: $($right.Type)"
    }
}

#MODULO
function ComputeModulo {
    param(
        $lhs,
        $rhs,
        $Context
    )
    return [PSCustomObject]@{
        Context = $Context
        Computation = New-ASTInteger -Value ($lhs.Value % $rhs.Value)
    }
}
function ComputeADDITION {
    param(
        $lhs,
        $rhs,
        $Context
    )
    #Dirties HACK
    if($Context.Values['tron'].Value -eq 1){
        Write-Host "Dans ComputeADDITION:" -ForegroundColor Red
        Write-Host "LHS = $($lhs)" -ForegroundColor DarkRed
        $lhs | DiveIntoObject -depth 1
        Write-Host "RHS = $($rhs)" -ForegroundColor DarkRed
        $rhs | DiveIntoObject -depth 1
    }

    #FIXME:
    #ATTENTION lorsque l'on fait un 
    #   (ComputeAST -AST $lhs -Context $Context)
    # d'un IDENTIFIANT et que sa valeur est un STRING
    # La valeur retournee est de Type null ! plutot que string
    #HACK pour une correction rapide mais il faudrait trouver la source du probleme
    #if($null -eq $lhs.Type){ $lhs.Type = 'STRING' }
    #if($null -eq $rhs.Type){ $rhs.Type = 'STRING' }


    $Left = $lhs
    $Right = $rhs
    #Quick and dirty HACK
    if(($Left.Type -eq 'INTEGER') -and ($Right.Type -eq 'STRING')){
        $StrAST = ($Right.Value | Convert-TextToParserInput | &(DoParseExecutable))
        #Calcul de la valeur:
        $leftValue = $Left
        $leftContext = $Context
        $rightValue = ComputeAST -AST $StrAST.Value -Context $leftContext
        if($rightValue.Computation.Type -eq 'STRING'){
            if($Context.Values.tron.Value){ Write-Host "RightValue still STRING!"}
            return (ComputeADDITION -lhs $leftValue.Computation -rhs $rightValue.Computation -Context $rightValue.Context)
        }
        return [PSCustomObject]@{
            Context = $rightValue.Context
            Computation = New-ASTInteger -Value ($leftValue.Computation.Value + $rightValue.Computation.Value)
        }
    }

    if($Left.Type -eq 'STRING') { $Type = 'STRING' } else { $Type = 'INTEGER' }
    $Type = $(if($Left.Type -eq 'STRING') {'STRING'} else {'INTEGER'})
    return [PSCustomObject]@{
        Context = $Context
        Computation = New-ASTGENERIC -Type $Type -Value ($Left.Value + $Right.Value)
    }
}

function Operation{
    param(
        $operation,
        $lhs,
        $rhs
    )
    $tab = @(@('ADDITION','INTEGER','INTEGER'), {param($lhs, $rhs) $lhs.Computation.Value + $rhs.Computation.Value})
    $tab+= @(@('ADDITION','INTEGER','STRING' ), {param($lhs, $rhs) [string]$lhs.Computation.Value + $rhs.Computation.Value})
    $tab+= @(@('ADDITION','STRING' ,'INTEGER'), {param($lhs, $rhs) $lhs.Computation.Value + [string]$rhs.Computation.Value})

    Write-Host "DANS OPERATION"
    Write-Host $operation
    Write-Host $lhs
    Write-Host $rhs
}

function TabEqual{
    param(
        $tab1, $tab2
    )
    if($tab1.length -ne $tab2.length){ return $False }
    for($i = 0; $i -lt $tab1.length; $i++){
        if($tab1[$i] -ne $tab2[$i]){ return $False }
    }
    return $True
}

function Show-Context{
    param(
        [Parameter(ValueFromPipeline)]
        $Context
    )
    $Context.Values.Keys | %{
        Write-Host "$_ = $($Context.Values[$_]) (TYPE)->$($Context.Values[$_].GetType().Name)"
        DiveIntoObject -Object $Context.Values[$_] -depth 1
    }
}

function DiveIntoObject{
    param(
        [Parameter(ValueFromPipeline=$true)]
        $Object,
        $depth
    )
    if($null -eq $Object){
        Write-Host "Dive Object NULL"
        return
    }
    $tab = ' ' * $depth
    if($Object.GetType().Name -ne 'PSCustomObject'){
        Write-Host "$($tab)$Object -> Type: $($Object.GetType().Name)"
        return
    }

    $Names = $Object | Get-Member -MemberType NoteProperty | Select -ExpandProperty Name
    $Names |%{
        if($null -eq $Object.$_){
            Write-Host "$($tab)$($_) -> $null" -ForegroundColor Red
        }else{
            if($Object.$_.GetType().Name -ne 'PSCustomObject'){
                Write-Host "$($tab)$($_) : $($Object.$_) -> $($Object.$_.GetType().Name)"
            }else{
                Write-Host "$($tab)$($_) : -> $($Object.$_.GetType().Name)"
                $Object.$_ | DiveIntoObject -depth ($depth + 1)
            }
        }
    }
}

Calculette
