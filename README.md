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
And to apply the function f to the value 4
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

## Operators:

### Operator `+`
```
3 + 2
> 5

"a" + "b"
> ab

f(x) = x + 2
g(x) = 2 * x

h = f + g

h(1)
> 5

h(2)
> 8

m = 2 + g

m(1)
> 4

k = 1..5
> (1, 2, 3, 4, 5)

l = 6..10
> (6, 7, 8, 9, 10)

k + l
> (7, 9, 11, 13, 15)
```

### Operator `/`
The same as `+` except for strings
```
"abc:efg" / ":"
> (abc, efg)
```
`/` is a kind of split

### Operator `*`
The same as `+` except you can't multiply 2 strings

### Operator `-`
The same as `*`

### Operator `%%`
The modulo operator
```
11 %% 7
> 4
```

### Operator `..`
The range operator\
It creates a list
```
4..8
> (4, 5, 6, 7, 8)
```

### Operator `,`
It creates a list
```
2,8,7,"Hello","world!",5
> (2, 8, 7, Hello, world!, 5)
```

### Operator `.`, `|`, `()`
These operators apply an argument to a function, or at least something that looks like a function.\
Be careful of operator precedence. `.`,`|` have the same precedence and `()` has the highest precedence
```
f(x) = 3 * x + 2

f(3)
> 11

f.3
> 11

3 | f
> 11

(1..5)(3)
> 4

(1..5).3
> 4

3|(1..5)
> 4

(2,8,7,"Hello","world!",5)(3)
> Hello

(2,8,7,"Hello","world!",5).3
> Hello

3 | (2,8,7,"Hello","world!",5)
> Hello

3 (2+1)
> 9

3 (3)
> 9

3(3)
> 9

3.3
> 9

3|3
> 9

"Hello World!"(6)
> W

"Hello World!".6
> W

6 |"Hello World!"
W
```

### Operator `%`
The map operator.\
It takes a list and a function and applies the function to each element of the list

```
f(x) = 3 * x + 2

1..5 % f
> (5, 8, 11, 14, 17)

(2,8,7,"Hello","world!",5) % f
> (8, 26, 23, HelloHelloHello2, world!world!world!2, 17)

1..5 % _(x)= x*3
> (3, 6, 9, 12, 15)

1..5 % \*(3)
> (3, 6, 9, 12, 15)

star(x)= "*" + x + "*"

"Hello world!" % star
> (*H*, *e*, *l*, *l*, *o*, * *, *w*, *o*, *r*, *l*, *d*, *!*)
```

### Operator `&`
The reduce operator.

```
1..5 & _(a)=_(b)= a + b
> 15

1..5 & \+
> 15

max(a)=_(b)= a > b ? a : b

(5, 8, 11, 14, 17) & max
> 17

f(x) = 3 * x + 2

1..5 % f & max
> 17

"Hello world!" & '+
> !dlrow olleH

```

### Operator `!`
The zip operator

```
list1 = (1..6)
> (1, 2, 3, 4, 5, 6)
list2 = (3..8)
> (3, 4, 5, 6, 7, 8)
> what_to_do(e1)=_(e2)=(e1, e2)

list1 : list2 ! what_to_do
> ((1, 3), (2, 4), (3, 5), (4, 6), (5, 7), (6, 8))

(1,2,3) : (4,5,6) ! \P
> ((1, 4), (2, 5), (3, 6))

list1 : list2 ! \+
> (4, 6, 8, 10, 12, 14)

```

### Operator `??`
The filter operator

```
```

### Operator `@`
The composition operator

```
```

### Operator `~`
The fold operator

```
```

!!
