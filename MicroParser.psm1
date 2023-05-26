
function Remove-LexerSpace{
    param(
        [Parameter(ValueFromPipeline)]
        $In
    )
    $txt   = $In.Text
    $index = $In.Index
    while($index -lt $txt.length -and $txt[$index] -match '\s'){
        $index++
    }
    $In.Index = $index
    return [PSCustomObject]@{
        Text  = $txt
        Index = $Index
        Value = $In.Value
    }
}

function New-SpaceRemoval{
    param(
        [Parameter(ValueFromPipeline)]
        $Lexer
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        $In | Remove-LexerSpace | &$Lexer
    }.GetNewClosure()
}


function New-LexerOr{
    param(
        $RightLexer,
        [Parameter(ValueFromPipeline)]
        $LeftLexer
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        $left = $In | &$LeftLexer
        if($null -ne $left){ return $left }

        $In | &$RightLexer
    }.GetNewClosure()
}

function New-LexerAnd{
    param(
        $RightLexer,
        [Parameter(ValueFromPipeline)]
        $LeftLexer
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        $left = $In | &$LeftLexer
        if($null -eq $left)  { return }
        $right = $left | &$RightLexer
        if($null -eq $right) { return }
        [PSCustomObject]@{
            Text  = $right.Text
            Index = $right.Index
            Value = $left.Value + $right.Value
        }
    }.GetNewClosure()
}

function New-LexerEOL{
    param(
        [Parameter(ValueFromPipeline)]
        $Char
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        if(($In.Index -eq $In.Text.Length)-or($In.Text[$In.Index] -eq "`n")){
            [PSCustomObject]@{
                Text  = $In.Text
                Index = $In.Index
                Value = "`n"
            }
        }
    }.GetNewClosure()
}

function New-LexerChar{
    param(
        [Parameter(ValueFromPipeline)]
        $Char
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        $txt     = $In.Text
        $index   = $In.Index
        if(($null -eq $In) -or ($index -ge $txt.Length)){ return }
        if($txt[$index] -eq $Char){
            [PSCustomObject]@{
                Text  = $In.Text
                Index = $index + 1
                Value = $Char
            }
        }
    }.GetNewClosure()
}

function New-LexerWord{
    param(
        [Parameter(ValueFromPipeline)]
        $Word
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        $txt     = $In.Text
        $index   = $In.Index
        for($i = 0; $i -lt $Word.length; $i++){
            if($txt[$index + $i] -ne $Word[$i]){
                return
            }
        }
        return [PSCustomObject]@{
            Text  = $In.Text
            Index = $index + $i
            Value = $Word
        }
    }.GetNewClosure()
}

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
        if($txt[$index] -eq '\'){
            $n = $txt[$index + 1]
            if($n -eq '+' -or $n -eq '*' -or $n -eq '-' -or $n -eq '/' -or $n -eq '@' -or $n -eq '.'){
                $Value = $txt[$index] + $txt[$index + 1]
            }
            return [PSCustomObject]@{
                Text  = $In.Text
                Index = $index + 2
                Value = $Value
            }
        }

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
function New-LexerInteger{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $txt     = $In.Text
        $index   = $In.Index
        [string]$Value   = ''

        for($i = 0; $i -lt $txt.length; $i++){
            if($txt[$index + $i] -notmatch '\d'){ break }
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

function New-LexerString{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $txt   = $In.Text
        $index = $In.Index
        [string]$Value = ''

        if($txt[$index] -ne '"'){ return}
        $index++

        While($txt[$index] -ne '"'){
            $Value += $txt[$index]
            $index++
        }
        [PSCustomObject]@{
            Text  = $In.Text
            Index = $index+1
            Value = $Value
        }
    }.GetNewClosure()
}
function New-ParserStar{
    #Pour info Star = 0 ou plus
    param(
        $Parser,
        $Transformer = {
            #Par default, ParserStar
            #Fait simplement un
            #$result | &(New-ParserStar -Parser $Parser)
            #Cad prend le resultat du parser precedent
            #et l'envoie dans le prochain
            param(
                $Accu,
                $Value
            )
            $Value
        }
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $result = $In | &$Parser
        if($null -eq $result){ return $In}

        [PSCustomObject]@{
            Text = $result.Text
            Index = $result.Index
            Value = &$Transformer -Accu $In.Value -Value $result.Value
        } | &(New-ParserStar -Parser $Parser -Transformer $Transformer)
    }.GetNewClosure()
}

function Skip-Parser{
    param(
        [Parameter(ValueFromPipeline)]
        $Parser
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        
        $suite = $In | &$Parser
        if($null -eq $suite){ return }
        
        [PSCustomObject]@{
            Text  = $suite.Text
            Index = $suite.Index
            Value = [PSCustomObject]@{
                Type  = $In.Value.Type
                Value = $In.Value.Value
            }
        }
    }.GetNewClosure()
}

function New-ParserAnd{
    param(
        $RightParser,
        $Transformer = {
            #param Operator Before After
            param($left, $In, $right)
            $right
        },
        [Parameter(ValueFromPipeline)]
        $LeftParser
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        
        $left = $In | &$LeftParser
        if($null -eq $left){ return }

        $right = $left | &$RightParser
        if($null -eq $right){ return }

        &$Transformer $left $In $right
    }.GetNewClosure()
}

function New-ParserOr{
    param(
        $RightParser,
        [Parameter(ValueFromPipeline)]
        $LeftParser
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        $left = $In | &$LeftParser
        if($null -ne $left){ return $left}

        $In | &$RightParser
    }.GetNewClosure()
}

function New-ParserEOL{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        $Lexer = (New-LexerEOL)
        $eol = $In | &(New-SpaceRemoval -Lexer $Lexer)
        if($null -eq $eol){ return }
        [PSCustomObject]@{
            Text  = $eol.Text
            Index = $eol.Index
            Value = [PSCustomObject]@{
                Type  = 'EOL'
                Value = $eol.Value
            }
        }
    }.GetNewClosure()
}

function New-ParserChar{
    param(
        [Parameter(ValueFromPipeline)]
        $Char
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $LexerChar = New-LexerChar -Char $Char
        $c = $In | &(New-SpaceRemoval -Lexer $LexerChar)

        if($null -eq $c){ return }
        [PSCustomObject]@{
            Text  = $c.Text
            Index = $c.Index
            Value = [PSCustomObject]@{
                Type  = 'CHAR'
                Value = $c.Value
            }
        }
    }.GetNewClosure()
}
function New-ParserWord{
    param(
        [Parameter(ValueFromPipeline)]
        $Word
    )
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $LexerWord = New-LexerWord -Word $Word
        $Mot = $In | &(New-SpaceRemoval -Lexer $LexerWord)

        if($null -eq $Mot){ return }
        [PSCustomObject]@{
            Text  = $Mot.Text
            Index = $Mot.Index
            Value = [PSCustomObject]@{
                Type  = 'WORD'
                Value = $Mot.Value
            }
        }
    }.GetNewClosure()
}

function New-ParserInteger{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        $Integer = $In | &(New-SpaceRemoval -Lexer (New-LexerInteger))
        if($null -eq $Integer){ return }
        [PSCustomObject]@{
            Text  = $Integer.Text
            Index = $Integer.Index
            Value = [PSCustomObject]@{
                Type  = 'INTEGER'
                Value = [int]$Integer.Value
            }
        }

    }.GetNewClosure()
}

function New-ParserID{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }
        
        $Id = $In | &(New-SpaceRemoval -Lexer (New-LexerID))
        if($null -eq $Id){ return }

        [PSCustomObject]@{
            Text = $Id.Text
            Index = $Id.Index
            Value = [PSCustomObject]@{
                Type  = 'IDENTIFIANT'
                Value = $Id.Value
            }
        }
    }.GetNewClosure()
}

function New-ParserString{
    {
        param(
            [Parameter(ValueFromPipeline)]
            $In
        )
        if($null -eq $In){ return }

        $str = $In | &(New-SpaceRemoval -Lexer (New-LexerString))
        if($null -eq $str){ return }

        [PSCustomObject]@{
            Text  = $str.Text
            Index = $str.Index
            Value = [PSCustomObject]@{
                Type  = 'STRING'
                Value = $str.Value
            }
        }
    }.GetNewClosure()
}

function Convert-TextToParserInput{
    param(
        [Parameter(ValueFromPipeline)]
        $Text
    )
    [PSCustomObject]@{
        Text  = $Text
        Index = 0
        Value = ''
    }
}
