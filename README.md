# PSCalculette
Just a toy progamming language in powershell

Code exemple\
Simple calcul:
```
2 + 3
3 * 2
5 / 4
```
Function definition:
```
f(x) = 3*x-5
```
And to apply the funciton f to the value 4
```
f(4)
> 7
```
Or you can use the dot or the pipe or even the `de`  operator:
```
f.4
> 7
4 | f
> 7
f de 4
> 7
```
You can simulate multiple arguments with lambdas:
```
add(x) = _(y) = x+y
```
To apply add to 2 and 3
```
add(2)(3)
> 5
```

```
f(x) = 3*x-5
g(x) = 2*x
derive(f)=_(x)= ( epsilon=1/1000 ; ((f(x+epsilon) - f(x)) / epsilon ) )

derive(f)(3)
> 3.0000000000001137

derive(f)(5)
> 3.0000000000001137

derive(g)(2)
> 1.9999999999997797
```
One can use partial evaluation:
```
f' = derive(f)
f'(3)
> 3.0000000000001137
```
Boolean:
0 is false, I know, it's a bad design!

Conditional:
```
1 ? "true" : "false"
> true

0 ? "true" : "false"
> false
```

Conditional exemple with factorial (warning calculette does not implement tail recursion)
```
fact(n) = n ? n * fact(n-1) : 1
fact(5)
> 120
```
One can also write the factorial without the conditional:
```
fact(n) = n * fact(n-1)
fact(0) = 1
> 1

fact(5)
> 120
```
Another way to define factorial is to use the range operator ```..``` the reduce operator ```&``` and the multiplication function ```\*```
```
fact(n) = 1..n & \*
fact(5)
> 120
```
Instead of these operators one can use functions to write a point free definition of the factorial.
- ```\R``` the function for the range operator
- ```\*``` the function for the ```*``` operator
- ```\&``` the function for the ```&``` operator but instead of ```\&``` we use ```'&``` defined as ```'&(x)=_(y)=(y&x)```
- ```@``` the operator defined as ```(f @ g)(x) = (f(g(x)))```
```
fact = '&.\* @ \R(1)
fact(5)
> 120
```

Calculette implements custom operators
```
insert(what)=_(prefix)=_(suffix)= "" + prefix + what + suffix

comma <- insert.", "
```
comma is now a new operator
```
"a" comma "b"
> a, b
3 comma 4
> 3, 4
"a" comma 3 comma "b"
> a, 3, b
```

Operators:\

#Basic operators\
## +
```
+
3 + 2
> 5

"a" + "b"
> ab3 + 2
> 5

"a" + "b"
> ab3 + 2
> 5

"a" + "b"
> ab
```
-
/
*
%%
.
|
..
,
%
&
!
!!
@
```
