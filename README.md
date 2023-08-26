# PSCalculette
Just a toy progamming language in powershell (according to me!).

Here a ChatGPT thought about calculette:
"Calculette is a programming language that combines mathematical notation and functional programming concepts to provide a concise and expressive way of performing computations and data manipulation. It features a range of built-in operators and operator functions that allow developers to compose, manipulate, and transform data in an intuitive and efficient manner. The language emphasizes the use of functions and operators as building blocks for creating complex operations, and it provides mechanisms for defining custom operators, lambdas with multiple parameters, and operator functions. With its focus on operator-driven programming, "calculette" aims to enhance code readability, encourage concise expression of algorithms, and offer a unique perspective on computation through a blend of mathematical notation and functional programming constructs."

## Introduction to Calculette

Welcome to Calculette, a unique programming language that merges mathematical notation with functional programming principles to provide an intuitive and expressive way of performing computations and data manipulation. In Calculette, the focus is on creating elegant and concise code using a combination of operators, functions, and lambdas.

Let's dive into some code examples that showcase the key features of Calculette:

### Simple Calculations
You can perform basic arithmetic operations like addition, multiplication, and division in Calculette:

```calculette
2 + 3
3 * 2
5 / 4
```

### Function Definitions and Application
Define functions using the traditional notation and apply them to values:

```calculette
f(x) = 3 * x - 5
f(4)
> 7
```

### Flexible Function Application
Calculette offers various ways to apply functions, such as using the dot, pipe, or `de` operator:

```calculette
f.4
> 7
4 | f
> 7
f de 4
> 7
```

### Lambdas for Multiple Arguments
You can simulate functions with multiple arguments using lambdas:

```calculette
add(x) = _(y) = x + y
add(2)(3)
> 5
```

### Usage of Multiple Arguments and Partial Evaluation
Calculette supports partial evaluation:

```calculette
f(x) = 3 * x - 5
g(x) = 2 * x
derivative(f) = _(x) = (epsilon = 1 / 1000; ((f(x + epsilon) - f(x)) / epsilon))

derivative(f)(3)
> 3.0000000000001137

f' = derivative(f)
f'(3)
> 3.0000000000001137
```

### Boolean and Conditionals
Boolean values and conditionals can be used as well:

```calculette
1 ? "true" : "false"
> true

0 ? "true" : "false"
> false
```

### Factorial Example
Implement factorials with conditionals, recursion, and point-free notation:

```calculette
fact(n) = n ? n * fact(n - 1) : 1
fact(5)
> 120

fact(n) = n * fact(n - 1)
fact(0) = 1
> 1
fact(5)
> 120

fact(n) = 1..n & \*
fact(5)
> 120

fact = '&.\* @ \R(1)
fact(5)
> 120
```

### Custom Operators
Calculette allows you to define and use custom operators:

```calculette
insert(what) = _(prefix) = _(suffix) = "" + prefix + what + suffix

comma <- insert.", "

"a" comma "b"
> a, b
3 comma 4
> 3, 4
"a" comma 3 comma "b"
> a, 3, b
```

With its unique approach to mathematical notation and functional programming, Calculette provides an intriguing platform for concise and expressive coding. The language's emphasis on operators, functions, and lambdas empowers developers to craft elegant solutions to a wide range of computational challenges.

## Functions:

### Notation
In the "calculette" programming language, the approach to defining functions closely mirrors mathematical notation. This design choice provides a clear and intuitive way to create functions and express computations.

In mathematical notation, functions are often defined using symbols and equations. "Calculette" embraces this concept by allowing you to define functions using a syntax that resembles mathematical equations. Here's how function definitions work in "calculette":

```calculette
function_name(parameter) = expression
```

- `function_name` is the name of the function you're defining.
- `parameter` is the input variable that the function accepts.
- `expression` is the mathematical expression that defines the function's behavior.

For example, if you want to define a function `f(x)` that doubles the input value `x`, you can do so using this notation:

```calculette
f(x) = 2 * x
```

This approach not only makes function definitions more concise but also aligns with how functions are presented in mathematical contexts. It allows programmers to focus on the logic of the computation rather than the intricacies of programming syntax.

By using mathematical notation for function definitions, "calculette" makes it easier for developers, especially those familiar with mathematics, to transition into writing code and expressing complex operations in a more natural and intuitive manner.

In the "calculette" programming language, functions are designed to have only one parameter. This design choice simplifies function definitions and aligns with the language's goal of using concise and intuitive mathematical notation.

Each function in "calculette" takes a single parameter, which is specified within the function's definition. For instance, defining a function `f(x)` would look like this:

```calculette
f(x) = expression
```

However, there are scenarios where you might want to work with functions that appear to take multiple parameters. In "calculette," you can achieve this by using lambdas.

Lambdas in "calculette" are functions defined inline, often to perform specific operations on data. By nesting lambdas, you can emulate functions that take multiple parameters. Here's how it works:

Suppose you want to define a function that calculates the sum of two numbers, `add(x, y)`. In "calculette," you can achieve this using nested lambdas:

```calculette
add = _(x) = _(y) = x + y
```

In this example:
- `_(x)` defines a lambda that takes the first parameter `x`.
- `_(y)` defines a nested lambda that takes the second parameter `y`.
- `x + y` is the expression that performs the addition.

You can also use the notation:
```
add(x) = _(y) = x + y
```

Now, you can use the `add` function as if it takes two parameters:

```calculette
result = add(3)(5)
> 8
```
You can also use the dot `.` and the pipe `|` operators to acheave the same result
```
add("a")."b"
> ab

add."a"("b")
> ERROR

add."a"."b"
> ab

"b" | add("a")
> ab

"a" | add."b"
> ab
```

While functions in "calculette" are designed to accept a single parameter, the ability to nest lambdas provides a way to achieve the effect of functions with multiple parameters. This approach maintains the simplicity and elegance of the language's syntax while offering flexibility in defining complex operations.

### Function as operator

In the "calculette" programming language, functions are typically defined with a single parameter. However, there's a convenient notation that allows you to use a two-parameter function as an operator to perform operations on values.

Using the notation ``` `function: value ```, you can apply the two-parameter function to a specific value. This effectively treats the function as an operator that takes one value as its second argument. Here's how it works:

Suppose you have a two-parameter function `add(x)=_(y)` that calculates the sum of `x` and `y`. In "calculette," you can use this function as an operator by applying it to a specific value:

```calculette
result = 3 `add: 5
```

In this example:
- `add` is the two-parameter function you want to use as an operator.
- `3` is the first argument for the function.
- `5` is the second argument for the function, provided using the `function: value` notation.

The result of this operation will be `8`, which is the sum of `3` and `5`.

This notation allows you to treat two-parameter functions as operators, making your code more concise and expressive. It's a powerful feature of the "calculette" language that enables you to work with functions in a flexible and intuitive way.

In the "calculette" programming language, the `function: value` notation allows you to use functions with multiple parameters as operators. Let's consider a scenario where you have a function `derivative(n)= _(f)= _(x)` that calculates the derivative of another function at a specific point and for a given degree of differentiation.

Suppose you have the following three-parameter function:
```calculette
derivative = _(n) = _(f) = _(x) = do_derivative_n_f_x
```

And you want to calculate the first derivative of the `square` function at `x = 2` using this `derivative` function. You can use the notation `function: value` as follows:

```calculette
result = square `derivative(1): 2
```

In this example:
- `square` is the function you want to differentiate.
- `derivative(1)` is the two-parameter function for calculating the first derivative.
- `2` is the value at which you want to calculate the derivative.

The result of this operation will be the value of the first derivative of the `square` function at `x = 2`.

### Partial evaluation

Introducing a remarkable feature, the "calculette" programming language introduces partial evaluation for functions with multiple parameters. This functionality empowers programmers to efficiently construct new specialized functions by supplying only a subset of the necessary arguments. With partial evaluation, specific arguments within a function can be fixed, leading to the creation of a new function that requires fewer parameters, while retaining other arguments as constants. This concept closely mirrors mathematical principles and offers substantial advantages in terms of both code reusability and optimization. As an illustration, consider the `power` function, which computes the nth power of a number. Leveraging partial evaluation, developers can effortlessly create a new function named `square` by pre-setting the exponent value to 2 in the `power` function. This streamlined process enables the generation of custom-tailored functions for specific use cases. By embracing partial evaluation, programmers can streamline complex functions into more concise forms, dynamically generate specialized functions, and significantly enhance both the flexibility and efficiency of the language.

**Example:**

```calculette
power = _(exponent) = _(base) = base ^ exponent
# Partially evaluate power with exponent fixed to 2
square = power(2)
# This computes 5^2, resulting in 25
result = square(5)
```

In this example, the `square` function is produced through the partial evaluation of the `power` function, with the exponent fixed at 2. When applied to the value `5`, it computes the square of `5`, yielding the result `25`. This vividly demonstrates how partial evaluation simplifies the creation of specialized functions, effectively improving code efficiency and clarity.

### More about Function Definition

In the world of programming languages, the way we define functions and handle conditionals often involves a fair amount of syntax and boilerplate code. Consider the following JavaScript example:

```javascript
function f(x) {
  if (x == 3) {
    return 5;
  }
  return x + 1;
}
```

This is a common pattern in many languages. However, Calculette takes a different approach, leveraging its unique mathematical notation to streamline these processes while maintaining readability.

In Calculette, function definitions become remarkably concise and intuitive. The equivalent `f(x)` function can be elegantly defined as `f(x) = x + 1`. But what's truly intriguing is how Calculette handles conditionals. Where other languages require explicit `if` statements, Calculette adopts a more direct approach:

```calculette
f(x) = x + 1
f(3) = 5
```

Here, the condition `x == 3` directly yields a return value of `5`. This concise representation eliminates the need for branching `if` statements and complex logic. By using this approach, Calculette demonstrates its commitment to marrying mathematics with programming, resulting in a syntax that's not only elegant but also insightful.

This unique feature in Calculette streamlines the coding process, allowing developers to focus on the core mathematical essence of their algorithms without getting bogged down in syntactic details. The comparison with traditional languages highlights the power of Calculette's notation, showcasing how the language reimagines function definitions and conditionals with a fresh perspective.

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
#### The modulo operator
```
11 %% 7
> 4
```

### Operator `..`
#### The range operator
It creates a list
```
4..8
> (4, 5, 6, 7, 8)
```

### Operator `,`
#### The list operator
It creates a list
```
2,8,7,"Hello","world!",5
> (2, 8, 7, Hello, world!, 5)
```

### Operator `.`, `|`, `()`
#### The apply and pipe operators
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
#### The map operator.

In the realm of the "calculette" programming language, the `%` operator takes on the role of the map operator, serving as a powerful tool for applying a function to each element of a list. This operator is designed to transform a given list by systematically executing a specified function on each individual element within it. The syntax for using the map operator is as follows:

```calculette
new_list = original_list % _(element) = transformed_element
```

- `new_list` is the resulting list after the mapping operation.
- `original_list` is the list that you intend to transform.
- `_(element)` defines a lambda with the element parameter.
- `transformed_element` represents the output of applying a transformation function to each element of the list.

For instance, suppose you have a list of numbers `(1, 2, 3, 4)` and you want to square each number. You can utilize the map operator `%` in the following way:

```calculette
squared_list = (1, 2, 3, 4) % _(element) = element * element
```

In this example, the lambda `_(element) = element * element` signifies that each element of the original list should be squared. The resulting `squared_list` will then contain `(1, 4, 9, 16)`.

The `%` map operator in "calculette" streamlines the process of applying transformations to list elements, showcasing its significance in simplifying list manipulation and promoting efficient coding practices.

Other examples:
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

#### The modulo operator

For numerics, `%` is the modulo operator
```
11 % 7
> 4
```

### Operator `&`
#### The reduce operator.

Within the "calculette" programming language, the `&` operator assumes the role of the reduce operator—a valuable tool for iteratively combining elements of a list into a single value. This operator is instrumental in condensing a list by applying a specified function sequentially to each element, cumulatively accumulating the result. The syntax for utilizing the reduce operator is as follows:

```calculette
result = list & _(accumulator) = _(element) = updated_accumulator
```

- `result` holds the final outcome of the reduction.
- `list` is the list subjected to reduction.
- `_(accumulator)` defines a lambda with the accumulator parameter.
- `_(element)` defines a nested lambda with the element parameter.
- `updated_accumulator` symbolizes the updated value of the accumulator after each iteration.

To illustrate, imagine a scenario where you have a list of numbers `(1, 2, 3, 4)` and you intend to calculate their product. You can harness the power of the reduce operator `&` in the following manner:

```calculette
product = (1, 2, 3, 4) & _(acc) = _(element) = acc * element
```

In this example, the `_(acc) = _(element) = acc * element` nested lambdas represent the cumulative multiplication of each element with the accumulator. The `product` will yield the final result, which in this case would be `24` (1 * 2 * 3 * 4).

By employing the `&` reduce operator, "calculette" significantly simplifies the process of iteratively combining elements to yield a single value, thereby showcasing its prowess in efficient list manipulation.


Other examples:
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
#### The zip operator

In the "calculette" programming language, the `!` operator serves as the zip operator, facilitating the merging of two lists element-wise to create a new list. This operator enables you to concurrently process corresponding elements from two lists while applying a specified function. The syntax for employing the zip operator is as follows:

```calculette
new_list = list1 : list2 ! _(element1) = _(element2) = what_to_do_with_elements
```

- `new_list` represents the resultant list after the zip operation.
- `list1` and `list2` are the two lists intended for merging.
- `_(element1)` defines a lambda with the parameter representing an element from `list1`.
- `_(element2)` defines a nested lambda with the parameter representing an element from `list2`.
- `what_to_do_with_elements` signifies the action or function to be applied to corresponding elements from both lists.

For instance, imagine you have the following lists:
```calculette
names = "Alice", "Bob", "Charlie"
ages = "25", "30", "28"
```

To pair each name with its corresponding age and generate descriptive statements, you can utilize the zip operator `!` as follows:

```calculette
name_age_pairs = names : ages ! _(name) = _(age) = name + " is " + age + " years old"
```

In this example, the nested lambdas `_(name) = _(age) = name + " is " + age + " years old"` work together to produce name-age pairs with descriptive text. The resulting `name_age_pairs` list will contain elements such as `"Alice is 25 years old"` and `"Bob is 30 years old"`.

By harnessing the `!` zip operator, "calculette" simplifies the merging of elements from two lists, creating a new list with processed outcomes. This showcases the language's ability to parallelly process multiple lists, enhancing its versatility and effectiveness.

Other examples:
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
#### The filter operator

In the "calculette" programming language, the `??` operator is the filter operator. It allows you to filter elements from a list based on a specified condition. The operator works as follows:

```calculette
new_list = original_list ?? _(element) = condition
```

- `new_list` is the resulting list containing elements that satisfy the condition.
- `original_list` is the list you want to filter.
- `_(element)` defines a lambda with the element parameter.
- `condition` is the filtering condition that determines whether an element should be included in the new list.

For example, suppose you have a list of numbers `(1, 2, 3, 4, 5)` and you want to filter out the even numbers. You can use the `??` operator like this:

```calculette
filtered_list = (1, 2, 3, 4, 5) ?? _(element) = element %% 2
```

In this example, `(element) = element %% 2` is the condition that checks if an element is even (returns 0, which is considered false in "calculette") or odd (returns non-zero, which is considered true in "calculette"). The resulting `filtered_list` will be `(1, 3, 5)`.

Similarly, you can use the `??` operator to filter elements based on various conditions, making it easy to extract subsets of data from a list.

The `??` filter operator is a powerful tool in the "calculette" language for selectively extracting elements that meet specific criteria from a list.


### Operator `@`
#### The composition operator

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

This approach ensures data flows through the functions in the order they are composed. However, "calculette" introduces an elegant way to enhance the readability of such pipelines. By employing custom operators and embracing the notion of operators as functions (which will be elaborated upon later), you can redefine the composition operator as:
```calculette
then <- '@
```
This enables you to express the pipeline in a more human-friendly manner:
```calculette
pipeline = load_data then clean_data then analyze_data
```
Here, the `then` operator mirrors the `@` operator, preserving the flow of data through functions but presenting a cleaner, more intuitive syntax. This exemplifies "calculette's" commitment to empowering developers with flexible and readable code constructs. The concept of operators as functions further enriches the language's expressive power and showcases its adaptability to various coding styles.

### Operator `++`
#### The append operator


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
#### The fold operator

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

### Operator `;`
#### The Sequential Evaluation Operator 
**Controlling Expression Flow in Calculette**

In Calculette, even the semicolon `;` serves as a distinctive operator that orchestrates the sequential evaluation of expressions. This operator allows developers to control the flow of computation by computing the first argument, subsequently evaluating the second argument, and finally discarding the result of the first computation while retaining the outcome of the second computation.

Consider the following explanation and example of how the sequential evaluation operator operates in Calculette:

**Explanation:**
The sequential evaluation operator `;` focuses on executing a series of expressions in a step-by-step manner. When used, it ensures that the expressions are processed sequentially, with the first computation serving as a preliminary step that doesn't influence the final result. This operator is particularly useful in scenarios where you want to ensure certain side effects or intermediate computations occur before the main result is calculated.

**Example:**
Let's say we want to compute the sum of two numbers but also print a message displaying the values being added. In traditional programming languages, this might involve separate lines of code. However, Calculette's sequential evaluation operator enables a concise approach:

```calculette
add_and_print(x) = _(y) = (print("Adding " + x + " and " + y); x + y)

result = add_and_print . 3 . 4
> Adding 3 and 4

print("Result: " + result)
> Result: 7
```

In this example, the `add_and_print` function leverages the `;` operator to first print the addition message, then calculate the sum. The print statement is a side effect that occurs before the main computation. This showcases how Calculette's sequential evaluation operator enhances code clarity by allowing developers to express both computation and side effects within a concise, sequential structure.

The sequential evaluation operator `;` demonstrates Calculette's commitment to providing a unique blend of mathematical notation and functional programming concepts to streamline code expression while maintaining control over computation flow.

### Custom operators

In the dynamic landscape of the "calculette" programming language, an intriguing capability allows for the creation of operators at runtime, further enhancing its versatility. This is made possible through the notation `new_operator <- _(a) = _(b) = do_something_with(a)(b)`, enabling developers to craft custom operators tailored to specific functionalities. This versatile approach allows for the creation of operators using the nested lambdas notation with two parameters, or alternatively, by providing a calculation that results in a two-parameter function. This newfound operator can then be seamlessly integrated into your code, just like any other built-in operator. For instance, consider the scenario where a novel operator called `combine` is defined using the dynamic operator creation notation. Once created, the `combine` operator can be effortlessly employed in expressions, as exemplified by `result = x combine y`. This innovative feature empowers programmers to adapt the language to their unique needs, showcasing the flexibility and adaptability inherent to "calculette."

### Operators as function

In the realm of the "calculette" programming language, an intriguing feature exists where each operator is accompanied by a corresponding function. This function's name is formed by prepending the operator with a backslash (`\`). This design allows for enhanced flexibility in manipulating operations and their arguments. For instance, consider the subtraction operator `-`. In "calculette," not only can you use the operator directly (`a - b`), but you can also leverage the `\-(a)(b)` function to achieve the same result. Additionally, "calculette" introduces another level of versatility by offering the `'-` function. This function ingeniously swaps the order of the arguments before applying the operator. For example, `'-(a)(b)` would execute `b - a`. This approach underscores "calculette's" commitment to providing developers with a comprehensive toolkit, enhancing code readability, and facilitating innovative problem-solving through intuitive constructs.

In the "calculette" programming language, the use of operator functions provides an elegant way to streamline code while maintaining its readability. Consider a scenario where you have a list of numbers `(1, 2, 3, 4, 5)` and you want to calculate the product of all its elements. Traditionally, you could accomplish this using the following syntax:
```calculette
result = (1, 2, 3, 4, 5) & _(element1) = _(element2) = element1 * element2
```
However, "calculette" offers a more concise approach by introducing operator functions. The operator function corresponding to multiplication, denoted by `\*`, can be used in place of the lambda expressions. Here's the enhanced code:
```calculette
result = (1, 2, 3, 4, 5) & \*
```
In this example, the `\*` operator function effectively replaces the longer lambda expressions. This demonstrates how "calculette" empowers programmers to write code that is both compact and expressive. This feature not only enhances code efficiency but also encourages the adoption of intuitive and succinct programming practices.

Additionally, in "calculette," strings are considered as lists of characters. The `+` operator performs concatenation on strings, allowing you to combine their characters. For instance, `'+("a")("b")` would yield `ba`. Interestingly, you can exploit this behavior to invert a string. By using the operator function `'+`, you can reverse a string's characters. For example, `"string" & '+` would yield the result `gnirts`, effectively inverting the string. This innovative approach to string manipulation further exemplifies "calculette's" commitment to providing versatile and powerful tools for developers.

In the "calculette" programming language, the concept of function operators naturally paves the way for concise function definitions where parameters are implicitly understood. For instance, consider the task of defining a `reverse` function that, given a string, returns its reversed form.

Traditionally, one might define the `reverse` function like this:
```calculette
reverse(text) = text & '+
```
Here, `&'+` swaps the characters in the string, effectively reversing it.

However, "calculette" offers a more compact expression of the `reverse` function by leveraging function operators and their associated features. In this case, you can define the `reverse` function using the following notation:
```calculette
reverse = '&.'+
```
This seemingly intricate definition encapsulates a series of operator functions. To break it down:
- `'&` represents the parameters swapped function for the reduce operator `&`
- `.` denotes the apply operator with slightly lower precedence than `(` and `)`. This operation `'&.'+` is the same as `'&('+)`
- `'+` signifies the reversed function for the `+` operator, which, when applied to strings, concatenates them in reverse order.

These examples showcase how the integration of function operators into function definitions leads to intuitive and succinct code structures in "calculette." The language's design encourages developers to embrace a powerful, operator-driven approach to create functions with implicit parameters, enhancing code conciseness and readability.

## Example of code and explanation:

```calculette
# Global Definitions
and <- '@; by <- '|; to <- '|

# Calculation of the length of a list
replace_each_element = '% @ \C

calculate_sum = '&.\+

length = (replace_each_element by 1) and calculate_sum

# Intersection of 2 sets calculation

are_equal = \=

keep_elements_that <- \?

belong(set_to_check)=_(element) = \B(length of (set_to_check keep_elements_that (are_equal to element)))

intersection(set1)=_(set2) = set1 keep_elements_that (belong to set2)
```

Explanation of the provided "calculette" code, along with the usage of specific operator functions and notations:

```calculette
# Global Definitions
and <- '@; by <- '|; to <- '|

# Calculation of the length of a list
replace_each_element = '% @ \C

calculate_sum = '&.\+

length = (replace_each_element by 1) and calculate_sum
```

This portion of the code sets up some global definitions and calculates the length of a list. The `and` operator is the reversed composition operator `'@`, allowing you to compose functions in reverse order. The `by` operator is the apply function `'|`, used to apply a function to its arguments. The `to` operator is also the apply function `'|`.

The function `replace_each_element` is defined using the operator `%`, which applies a given function to each element of a list. In this case, the function `\C` is a constant function that takes two arguments and always returns the first one.

The function `calculate_sum` is defined using the operator `&`, which is used to reduce a list using a given function. Here, the function `\+` is used, which effectively sums the elements of the list.

The function `length` calculates the length of a list by first replacing each element with `1` using `replace_each_element`, and then calculating the sum of the resulting list using `calculate_sum`.

Moving on to the next part of the code:

```calculette
# Intersection of 2 sets calculation

are_equal = \=

keep_elements_that <- \?

belong(set_to_check)=_(element) = \B(length of (set_to_check keep_elements_that (are_equal to element)))

intersection(set1)=_(set2) = set1 keep_elements_that (belong to set2)
```

This section of the code focuses on calculating the intersection of two sets. The `are_equal` function is defined using the operator `\=`, which checks if two values are equal.

The function `keep_elements_that` is defined using the operator `\?`, which filters a list based on a given function. This function essentially selects elements that meet a certain criteria.

The function `belong` checks if an element belongs to a set. It uses the `length` function (which we defined earlier) along with the `keep_elements_that` function and the `are_equal` function to determine membership.

Finally, the `intersection` function calculates the intersection of two sets (`set1` and `set2`). It utilizes the `keep_elements_that` function to keep elements that `belong` to `set2`.

The code exemplifies the power of custom operators, function compositions, operator functions, and logical functions in the "calculette" programming language. It elegantly showcases how these elements can be combined to perform meaningful operations such as calculating lengths and set intersections.

!!
