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

what_to_do(element1)=_(element2)=(element1, element2)

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

The `@` operator enables you to seamlessly combine two functions, let's call them `f` and `g`, to create a new function that applies `f` to the result of applying `g` to its input.

Here's how you would use the "@" operator:

```
new_function = f @ g
result = new_function(x)
```
In the above code:

- `f` is a function that you want to apply after `g`.
- `g` is a function that takes an input and produces an intermediate result.
- `f @ g` creates a new function that represents the composition of `f` after `g`.
- When you call `new_function(x)`, it's equivalent to first applying `g` to `x`, then applying `f` to the result of `g(x)`.

`@` lets you compose functions together to create a data processing pipeline
```
pipeline = analyze_data @ clean_data @ load_data
result = pipeline(data)
```

### Operator `++`
The append operator


In the calculette programming language, you can use the "append" operator denoted as `++` to add an element to the end of a list. This operator is useful for extending lists dynamically.

To use the "append" operator:

```
newlist = list ++ element
```

- `list` is the existing list to which you want to add an element.
- `element` is the value you want to append to the end of the list.
- `newlist` is the resulting list after the `element` has been added.

For example, if you have a list of numbers `(1, 2, 3)` and you want to append the value `4`, you would use the `++` operator like this:

```
newlist = (1, 2, 3) ++ 4
```

After this operation, `newlist` would become `(1, 2, 3, 4)`.

The "append" operator simplifies the process of adding elements to lists in the calculette language, making list manipulation more intuitive and straightforward.

### Operator `~`
The fold operator

The fold operator, denoted as `~`, is a powerful tool for aggregating values in a list. The fold operation has the form: `list ~ accu : _([element]) = [action]`.

- `list` is the list you want to perform the fold operation on.
- `accu` is an accumulator that holds the result of the fold operation.
- `[element]` is the current element being processed from the list.
- `[action]` is the action you want to perform on the element and the accumulator.

For example:
```
list ~ initial_accumulator : _(accumulator)=_(element) = updated_accumulator(accumulator)(element)
```
In this fold operation, `element` is iterated through the list, and for each element, `updated_accumulator(accumulator)(element)` is performed while updating the `initial_accumulator` based on the action.

Here is a more concrete example:

Suppose you have a list of numbers, and you want to calculate the sum of all the numbers using the fold operator.

Let's say your list is `(1, 2, 3, 4, 5)`, and you want to use the fold operator to calculate the sum. The fold operation will look like this:

```
sum = (1, 2, 3, 4, 5) ~ 0 : _(acc) = _(element) = acc + element
```

In this fold operation:
- `sum` is the resulting sum of all the numbers.
- `(1, 2, 3, 4, 5)` is the list you're working with.
- `0` is the initial accumulator, starting from zero.
- `_(acc)` defines a lambda with the accumulator parameter.
- `_(element)` defines a lambda with the element parameter.
- `acc + element` is the action to update the accumulator by adding the current element to it.

As the fold operation proceeds, the accumulator starts from `0`, and for each element in the list, it adds the element to the accumulator. After processing all the elements, the final `sum` will hold the value `15`, which is the sum of all the numbers in the list.

Another example:\
Suppose you have a list of numbers `(1, 2, 3, 4, 5)` and you want to filter out the even numbers and then append each even number with an exclamation mark.

Here's how you can achieve this using the fold operator `~`, the append operator `++`, and the ternary conditional:

```
filtered_and_appended = (1, 2, 3, 4, 5) ~ {} : _(acc) = _(element) = (element %% 2 ? acc : acc ++ ("" + element + "!") )
```

In this operation:
- `filtered_and_appended` will hold the final result.
- `(1, 2, 3, 4, 5)` is the original list.
- `{}` is the initial accumulator, representing an empty list.
- `_(acc)` defines a lambda with the accumulator parameter.
- `_(element)` defines a lambda with the current element being processed.
- `element %% 2 ? acc : acc ++ ( "" + element + "!")` uses the ternary conditional to concatenate even elements with an exclamation mark (the `"" + element` is used to cast the number into a string) and drop odd elements.

In the "calculette" language, you use `{}` to represent an empty list.

After the fold operation, `filtered_and_appended` will hold the value `(2!, 4!)`, which are the even numbers from the list, concatenated with exclamation marks.

This example showcases how you can use the fold operator `~`, the append operator `++`, and the `+` operator for string concatenation to perform complex transformations on lists in the "calculette" language.


!!
