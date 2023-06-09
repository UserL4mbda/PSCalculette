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
You can simulate multiple arguments with lambdas:
```
add(x) = _(y) = x+y
```
To apply add to 2 and 3
```
add(2)(3)
> 5
```

Warning: There is a bug with function definition so in most case use ( ) after =
```
f(x) = (3*x-5)
g(x) = (2*x)
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
0 ? "true" : "false"
```

Conditional exemple with factorial (warning calculette does not implement tail recursion)
```
fact(n) = (n ? (n * fact(n-1)) : 1)
fact(5)
> 120
```
One can also write the factorial without the conditional:
```
fact(n) = (n * fact(n-1))
fact(0) = 1
> 1

fact(5)
> 120
```
Another way to define factorial is to use the range operator ```..``` the reduce operator ```&``` and the multiplication function ```\*```
```
fact(n) = (1..n & \*)
fact(5)
> 120
```
Instead of the operators one can use functions to write a point free definition of the factorial.
- ```\R``` the function for the range operator
- ```\*``` the function for the ```*``` operator
- ```\&``` the function for the ```&``` operator but instead of ```\&``` we use ```'&``` defined as ```'&(x)=_(y)=(y&x)```
- ```\O``` the function defined as ```\O(f)=_(g)=_(x)=(f(g(x)))```
```
fact = (('&.\*)`\O:(\R.1))
```
