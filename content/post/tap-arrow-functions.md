+++
date = "2017-06-28"
title = "Debugging single expression arrow functions"
[blackfriday]
  smartyPants = false
+++

Here's a neat trick I recently became aware of, that helped ease my pain debugging single expression arrow functions (no curly brackets).  

Anyone who has a more functional style of programming will tend to use a lot of these tiny, concise functions to compose them in bigger functions. They are also heavily used in React functional components.

Consider the following function:

{{< highlight jsx >}}
const add = (a, b) => a + b;
{{< /highlight >}}

It's pretty obvious what it does, but for the sake of the argument, let's suppose we want to add some `console.log` calls in the `add` function to see what `a`, or `a + b` values are.  
I know, `console.log` is not the best debugging tool, but let's admit that most people use it pretty often.

So, one way would be to turn the one-liner into a curly bracket thing;

{{< highlight jsx >}}
const add = (a, b) => {
  console.log(a);
  const sum = a + b;
  console.log(sum);
  return sum;
};
{{< /highlight >}}

Yuck! I had to dirty my beautiful one-liner with curly brackets, `return` and an extra const, just to temporarily (I'm not gonna leave that in the code, am I?!) take a peek at some values.

From the functional programming world here comes `tap`. It's a higher order function, Ramda [has it](http://ramdajs.com/docs/#tap), Lodash [has it](https://lodash.com/docs/#tap) too, so those implementations can be used if you already have a dependency on one of them.  
But maybe you don't, in which case we can write it pretty easily.

{{< highlight jsx >}}
const tap = fn => x => { fn(x); return x };
{{< /highlight >}}

That is all there is to it. `tap` takes a function (called interceptor), and a value, calls the function with the value, and returns the value.  

But why not write it like this?
{{< highlight jsx >}}
const tap = (fn, x) => { fn(x); return x };
{{< /highlight >}}

It's because we need it to be curried, so we can "prefill" the interceptor, with whatever function we want (`console.log` in this case):
{{< highlight jsx >}}
const tapLog = tap(console.log);
{{< /highlight >}}

So `tapLog` is a function that can be called with an argument, logs that argument, then returns it. A nice perk is being able to write this [point-free](https://en.wikipedia.org/wiki/Tacit_programming).

Let's put it to use in our `add` function:
{{< highlight jsx >}}
const add = (a, b) => tapLog(tapLog(a) + b);
{{< /highlight >}}
 
Addmitedly, being a lazy typist I am not 100% satisfied. I wish there was a way to do it without the extra parens, so that when removing the logging I don't have to move the cursor to delete in two places - the `tapLog(` and the final parens.

There are [clever ways](https://stackoverflow.com/questions/35949554/invoking-a-function-without-parentheses) to invoke functions without parantheses in JavaScript, but unfortunately nothing works if we want the respective function to take arguments and return a value at the same time. Please correct me if I'm wrong here, I would love to find a way.  

Here's a small enhancement, to also log a message with the value, might not be to everyone's taste though, and we lose the point-freeness (or is it point-freedom :) ) in `tapLog`:

<script src="https://embed.runkit.com" data-element-id="my-element"></script>
<div id="my-element">
const tap = fn => x => { fn(x); return x };
const tapLog = msg => tap(x => console.log(msg + x));

const add = 
  (a, b) => tapLog('sum=')(tapLog('a=')(a) + b);

add(2, 3);
'cool, huh?'
</div>