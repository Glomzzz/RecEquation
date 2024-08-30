# RecEquation
Recursive Equation, with call-by-value and call-by-name impl, in Haskell

From [Partial Evaluation Book](https://www.itu.dk/people/sestoft/pebook/) Exercise.

## Fun staff

When I try to run my call-by-value interpreter which is written in Haskell,

I found that there are something wired occurred:

PEBook told me, when it comes to $h(x,y)=if \quad\quad y\quad\quad<=\quad\quad 1\quad\quad then\quad\quad y\quad\quad else\quad\quad h(\quad h(x+1,y),y-2\quad )$

using call-by-name, h(1,2) evaluates to 0; but call-by-value is undefined($\bot$)

But what I got, in Haskell, is:
- call-by-name => 0
- call-by-value => 0

I realized that it was completely different from what is written in the book.

PEBook's call-by-value was written in ML, and mine Haskell.

Guess what was the problem?

Aha! **ML's Strict evaluation** and **Haskell's Lazy evaluation** !

My call-by-value interpreter, in Lazy evaluation, which delays the evaluation of an expression until its value is needed,

is ACTUALLY a call-by-name interpreter! Haha!

![f](f.png)

By the way, if you don't familiar with call-by-name and call-by-value:

### Call-by-name reduction
- does not impose further restrictions
- $(\lambda x.M)N$ can be reduced immediately by a β-reduction
- Is preferable to call-by-value because of the **completeness property: namely**
- If M can be reduced to a constant c, then the call-by-name reduction order will reduce M to c
### call-by-value reduction
- furter restricts the use of β-reduction to top-level redexes
- $(\lambda x.M)P$ where the argument P is a whnf(const or func).
- Thus, $(\lambda x.M)N$ must be reduced by first reducing the argument N to a whnf P
- Then $(\lambda x.M)P$ is reduced by a β-reduction



