# Data-type Details

Since basic C++ data types change from machine to machine, whether it be their sizes or their implementations, it's
important to be able to figure out those details on a particular system. That's where the following functions and
constructs come in!

## Size of Data Types

C++ inherited the `sizeof` operator from C which returns the size of a particular value if used on a value, or the size of 
values of a particular data type if used on a data type. The following code demonstrates this.

```c++
std::cout << "Size of `int`: " << sizeof(int) << '\n';
std::cout << "Size of `double`: " << sizeof(double) << '\n';
```

The above code outputs the following to the console.

```text
Size of `int`: 4
Size of `double`: 8
```

This means that integers take up four bytes, and doubles take up eight bytes.

There are a couple of things to note. The first is that the `sizeof` operator requires parentheses when used with a data
type. The second is that the sizes may be different on your computer or other computers. This is system dependent, so
don't be surprised if your numbers are different! These are the most common values for `int` and `double` when it comes to
desktop and laptop computers.

We can also use the `sizeof` operator to get the size of a value.

```c++
constexpr int num{4};
std::cout << "Size of `num`: " << sizeof num << '\n';
```

The above code outputs the following to the console.

```text
Size of `num`: 4
```

We can see that this agrees with what C++ told us the size of integers is. Also note that now that we're getting the size
of a value instead of a data type, we no longer need parentheses.

## Numeric Information

C++ provides the `std::numeric_limits` class which contains different methods and constants which tell us information
about the values of particular numeric data types. This class comes from the `<limits>` header, so that must be included
before `std::numeric_limits` can be used.

Let's start by getting the minimum and maximum possible values we can store in an `int` variable.

```c++
std::cout << "`int` min value: " << std::numeric_limits<int>::min() << '\n';
std::cout << "`int` max value: " << std::numeric_limits<int>::max() << '\n';
```

The above code outputs the following to the console.

```text
`int` min value: -2147483648
`int` max value: 2147483647
```

This makes sense since we know `int` values take up four bytes on my machine. If you want this information for other
numeric types, simply swap out `int` for whichever numeric type you want information for!

Let's take a look at getting information specific to floating-point types. One thing we might want to know is whether they 
follow the IEEE-754 specification. We'll be discussing this spec in more detail later.

```c++
std::cout << "Using IEEE-754: " << std::numeric_limits<double>::is_iec559 << '\n';
```

The above code outputs the following to the console.

```text
Using IEEE-754: 1
```

The first thing to note is that C++ refers to the IEEE-754 spec as the IEC-559 spec. This is because there are multiple 
regulatory bodies for this sort of thing, and many of them have the same specifications for things like floating-point
numbers.
C++ happens to reference IEC, but IEEE-754 and IEC-559 outline the same requirements.

The second thing to note is that the console reports a `true` as `1`. This is normal for `std::cout`, and we'll learn how
to change this behavior in a future project. Whenever you see `1` in a boolean context in the console, it means `true`, so
that means my machine follows the IEEE-754 spec! This is typical for most modern desktops and laptops, so you should
expect this for your machine, too, but it's not necessarily guaranteed.

Another thing we might want to do is get the number of digits of accuracy for a particular floating-point type. This is
the most important metric when it comes to deciding which floating-point data type is right for your project.

```c++
std::cout << "Accurate digits for `double`: " << std::numeric_limits<double>::digits10 << '\n';
```

The above code outputs the following to the console.

```text
Accurate digits for `double`: 15
```

Keep in mind that this is the number of accurate digits for the *whole number*, not just the decimal part. This means you
can only store six decimal digits accurately if the whole-number part of the number needs nine digits.

You may wonder why the constant for the number of accurate digits is `digits10`. This is because we are asking for the
number of *decimal* digits of accuracy rather than the number of *binary* digits of accuracy because that's what matters
to us.

Speaking of which, we can confirm that `float`, `double`, and `long double` are binary floating-point types by using the 
`radix` constant.

```c++
std::cout << "Radix of `float`: " << std::numeric_limits<float>::radix << '\n';
std::cout << "Radix of `double`: " << std::numeric_limits<double>::radix << '\n';
std::cout << "Radix of `long double`: " << std::numeric_limits<long double>::radix << '\n';
```

The above code outputs the following to the console.

```text
Radix of `float`: 2
Radix of `double`: 2
Radix of `long double`: 2
```

If your target system is using the IEEE-754 spec, this will be two for the primitive floating-point types, so this only 
matters if you're targeting a system where some other specification is being used.

The last thing to discuss is something to keep in mind when getting the minimum representable value with floating-point
types. The `max` method works as expected for floating-point types, but the `min` function may show something strange.
Let's take a look at the minimum value for `double`.

```c++
std::cout << "Min value for `double`: " << std::numeric_limits<double>::min() << '\n';
```

The above code outputs the following to the console.

```text
Min value for `double`: 2.22507e-308
```

That's a very small number, but it's still positive! The IEEE-754 standard has different classifications of numbers with 
"normal" being most numbers and "subnormal" being special cases of how binary floating-point numbers are represented.
These subnormal numbers are why floating-point numbers around zero get a bit strange. It's not important right now what
this means. The main thing to take away from this is that the `min` method behaves differently for some floating-point
types than it does for integral types. The `min` method returns the minimum *positive normalized value* for floating-point
types that support subnormal numbers, like IEEE-754 types, rather than the minimum value which is the value with no values
smaller than it.

So, how can we get the actual minimum value for floating-point types? We use the `lowest` method!

```c++
std::cout << "Actual min value for `double`: " << std::numeric_limits<double>::lowest() << '\n';
```

The above code outputs the following to the console.

```text
Actual min value for `double`: -1.79769e+308
```

That certainly looks like the proper minimum value. For integral types and floating-point types that don't support
subnormal values, `lowest` returns the same thing as `min`. `min` should be preferred unless you need the actual minimum
value of a floating-point type that supports subnormal numbers or unless you aren't sure whether your type supports them,
and you need the minimum value regardless!
