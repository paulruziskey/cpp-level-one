# Fixed-width Types

It's hard to reason about how big integer types are since they change per system. The fact that different systems have
different memory layouts makes sense, but the fact that `int` can mean more than one thing on different systems is hard to
deal with. This is where fixed-width integer types come in!

## What Are Fixed-width Integer Types?

Fixed-width integer types are integer types that have a fixed-width! It's that simple! This means when we use them, we know how many bits they'll need, and if they don't exist on a particular machine, we'll get a compilation error. This is much more ideal!

## Using Fixed-width Integer types

To get fixed-width integer types, we need to include `<cstdint>`. This header includes the C++ versions of C's fixed-width
types that C++ inherited. Let's take a look at defining an integer using a fixed-width type.

```c++
constexpr std::int32_t num{5};
std::cout << "num: " << num << '\n';
```

From the type, we can tell that `std::int32_t` is 32 bits wide. This type is also signed since it's just `int`. The `_t` on
the end of the type is how C denotes C types that aren't keywords. This suffix is reserved in C and C++, so no custom types
are allowed to use it. Even though `std::int32_t` is longer than `int`, it's already much clearer, and it's what we want
from a systems programming language.

It's important to note that while `std::int32_t` will be our default integer type when we don't have a reason to use
anything else, it isn't necessarily synonymous with `int`. This is because `int` may be 16 bits on some systems, for
example, in which case it would be synonymous with `std::int16_t` on those systems. That's the benefit of fixed-width
integer types: we know exactly how wide they are, and that will always be the case if our code compiles!

What if we want an unsigned integer?

```c++
constexpr std::uint32_t num{5};
std::cout << "num: " << num << '\n';
```

It's as simple as adding a `u` in front of the type!

The following list shows the available fixed-width integer types that are part of the C++ standard.

* `std::int8_t`
* `std::int16_t`
* `std::int32_t`
* `std::int64_t`
* `std::uint8_t`
* `std::uint16_t`
* `std::uint32_t`
* `std::uint64_t`

## Things to Watch Out for

Let's try picking one and looking at another example!

```c++
std::cout << "Enter your age: ";
std::uint8_t age{};
std::cin >> age;
std::cout << "Your age is " << age << " year(s) old\n";
```

The above code outputs the following to the console.

```text
Enter your age: 26
Your age is 2 year(s) old
```

Well that's strange. 26 is perfectly storable in an unsigned 8-bit integer type, so no issues there. Investigating further,
it turns out `std::uint8_t` is actually a *type alias* for `unsigned char` on my machine! A type alias is a data type that
actually represents a different type. On my system, `unsigned char` is an unsigned 8-bit integer type, so it was simply
aliased to `std::uint8_t` since they mean the same thing from a memory standpoint. The only issue with this is that 
`unsigned char` values are treated as characters by C++ by default. This is true both when using `std::cin` and `std::cout`.
Even though characters are integral types in C++, they don't act like regular integer types. This means we need to use the
same trick we used before if we want to output characters as their integer values, and it means we can't use `std::uint8_t`
or `std::int8_t` with `std::cin` on systems where they are simply aliases of character types.

This is definitely a downside of using fixed-width integer types. It's one of the few, but it does exist. Unfortunately,
this isn't the only place where C++ treats character types differently from integer types even though it shouldn't since
character types are integral types. We'll see another one when discussing generating random numbers.

That being said, fixed-width integer types are still a much needed improvement over the wishy washy integer types. So,
what's the solution for the age code? Simply switch to the next biggest type `std::uint16_t`.

```c++
std::cout << "Enter your age: ";
std::uint16_t age{};
std::cin >> age;
std::cout << "Your age is " << age << " year(s) old\n";
```

The code now works as expected, outputting the following to the console.

```text
Enter your age: 26
Your age is 26 year(s) old
```
